#!/bin/bash
# =============================================================================
# entrypoint.sh - Punto de entrada del contenedor del laboratorio
# =============================================================================
# Sistema unificado: 11 unidades × 10 retos = 110 retos totales
# =============================================================================

# Cargar biblioteca compartida
source /shared/common.sh
source /shared/menu.sh

# ─── Copiar unidades desde /opt si no existen (primera ejecución) ─────────────
UNITS_MARKER="$HOME/.units_copied"
if [ ! -f "$UNITS_MARKER" ]; then
    info "Copiando unidades del curso al directorio de trabajo..."
    mkdir -p "$HOME/laboratorio/units"
    cp -r /opt/lab-units/* "$HOME/laboratorio/units/" 2>/dev/null || true
    touch "$UNITS_MARKER"
fi

# ─── Detectar primer inicio y limpiar progreso anterior ──────────────────────
MARKER="$HOME/.lab_initialized"
if [ ! -f "$MARKER" ]; then
    rm -f "$HOME/laboratorio/.reto"_completado 2>/dev/null
    rm -f "$HOME/laboratorio/.reto"*"_completado" 2>/dev/null
    rm -f "/shared/.state/progress" 2>/dev/null
    touch "$MARKER"
fi

# ─── Funciones interactivas del laboratorio ───────────────────────────────────

# Menú principal interactivo
menu_interactivo() {
    while true; do
        clear
        mostrar_menu_principal
        echo -n "  Selecciona una opción (1-11, s=frase, q=salir): "
        read -r choice
        case "$choice" in
            q|Q|quit|exit)
                echo "  👋 ¡Hasta luego!"
                break
                ;;
            s|S)
                ver_frase
                ;;
            [1-9]|10|11)
                if [ "$choice" -ge 1 ] && [ "$choice" -le 11 ]; then
                    local romano=$(get_unit_num_romano $choice)
                    export CURRENT_UNIT="unit-$romano"
                    echo "$CURRENT_UNIT" > ~/.current_unit
                    jugar_unidad "$CURRENT_UNIT"
                else
                    echo "  ❌ Opción inválida"
                fi
                ;;
            *)
                echo "  ❌ Opción inválida"
                ;;
        esac
        echo ""
        echo -n "  Presiona Enter para continuar..."
        read -r
    done
}

# Convertir número a romano
get_unit_num_romano() {
    case $1 in
        1) echo "I" ;;2) echo "II" ;;3) echo "III" ;;4) echo "IV" ;;5) echo "V" ;;
        6) echo "VI" ;;7) echo "VII" ;;8) echo "VIII" ;;9) echo "IX" ;;10) echo "X" ;;11) echo "XI" ;;
    esac
}

# Ver retos de la unidad actual (interactivo)
ver_retos_unidad() {
    if [ -z "$CURRENT_UNIT" ]; then
        if [ -f "$HOME/.current_unit" ]; then
            export CURRENT_UNIT=$(cat "$HOME/.current_unit")
        fi
    fi
    if [ -z "$CURRENT_UNIT" ]; then
        echo "  ⚠️  Primero selecciona una unidad:"
        echo ""
        for i in {1..11}; do
            echo "  [$i] Unidad $i"
        done
        echo ""
        echo -n "  Elige (1-11): "
        read -r choice
        if [ "$choice" -ge 1 ] && [ "$choice" -le 11 ]; then
            local romano=$(get_unit_num_romano $choice)
            export CURRENT_UNIT="unit-$romano"
            echo "$CURRENT_UNIT" > ~/.current_unit
        else
            return 1
        fi
    fi
    # Mostrar menú de retos de la unidad
    ejecutar_unidad "$CURRENT_UNIT"
}

# Jugar de forma interactiva
jugar_interactivo() {
    local unit="${1:-}"

    # Si no se pasa unidad, mostrar menú para elegir
    if [ -z "$unit" ]; then
        if [ -f "$HOME/.current_unit" ]; then
            unit=$(cat "$HOME/.current_unit")
        fi
    fi

    if [ -z "$unit" ]; then
        echo ""
        echo -e "${CYAN}🎮 MODO JUGAR - Selecciona una unidad:${RESET}"
        echo ""
        for i in {1..11}; do
            local romano=$(get_unit_num_romano $i)
            local u="unit-$romano"
            local titulo=$(case $i in
                1) echo "Fundamentos" ;;
                2) echo "Gestión de Paquetes" ;;
                3) echo "Scripting Bash" ;;
                4) echo "Usuarios y SSH" ;;
                5) echo "Procesos y systemd" ;;
                6) echo "Almacenamiento y LVM" ;;
                7) echo "Hardening" ;;
                8) echo "Docker" ;;
                9) echo "Nginx" ;;
                10) echo "SSL/HTTPS" ;;
                11) echo "Docker Compose + DB" ;;
            esac)
            local completados=$(contar_completados "$u" 10 2>/dev/null || echo 0)
            echo -e "  ${VERDE}[$i]${RESET} $titulo (${completados}/10)"
        done
        echo ""
        echo -n "  Elige unidad (1-11): "
        read -r choice
        if [ -z "$choice" ]; then
            return 0
        fi
        if [ "$choice" -ge 1 ] && [ "$choice" -le 11 ]; then
            local romano=$(get_unit_num_romano $choice)
            unit="unit-$romano"
        else
            echo "  ❌ Opción inválida"
            return 1
        fi
    fi

    export CURRENT_UNIT="$unit"
    echo "$CURRENT_UNIT" > ~/.current_unit

    # Cargar test.sh de la unidad
    local unit_path; unit_path=$(resolve_unit_path "$unit")
    if [ ! -f "$unit_path/test.sh" ]; then
        echo "  ❌ Unidad no encontrada: $unit"
        return 1
    fi
    source "$unit_path/test.sh" 2>/dev/null || true

    # Bucle de retos
    local total=${#challenge_names[@]}
    local reto=1

    while [ "$reto" -le "$total" ]; do
        # Saltar completados
        if esta_completado "$unit" "$reto" 2>/dev/null; then
            reto=$((reto + 1))
            continue
        fi

        # Jugar el reto
        jugar_reto "$unit" "$reto"
        local result=$?

        if [ $result -eq 0 ]; then
            # Completado, avanzar al siguiente
            reto=$((reto + 1))
        else
            # Salió o falló, preguntar
            echo ""
            echo -ne "${AMARILLO}¿Qué quieres hacer? [n] siguiente, [m] menú, [q] salir: ${RESET}"
            read -r action
            case "$action" in
                m|M) return 0 ;;
                q|Q) return 1 ;;
                *) reto=$((reto + 1)) ;;
            esac
        fi
    done

    echo ""
    echo -e "${VERDE_B}🏆 ¡UNIDAD $unit COMPLETADA!${RESET}"
    mostrar_frase_unidad "$(get_unit_index "$unit")"
}

# Evaluar unidad de forma interactiva
evaluar_interactivo() {
    if [ -z "$CURRENT_UNIT" ]; then
        if [ -f "$HOME/.current_unit" ]; then
            export CURRENT_UNIT=$(cat "$HOME/.current_unit")
        fi
    fi

    if [ -z "$CURRENT_UNIT" ]; then
        echo ""
        echo "  📊 EVALUAR - Selecciona una unidad:"
        echo ""
        for i in {1..11}; do
            local romano=$(get_unit_num_romano $i)
            local u="unit-$romano"
            local completados=$(contar_completados "$u" 10 2>/dev/null || echo 0)
            echo "  [$i] Unidad $i (${completados}/10)"
        done
        echo ""
        echo -n "  Elige (1-11, Enter para todas): "
        read -r choice
        if [ -z "$choice" ]; then
            # Evaluar todas
            mostrar_progreso_global
            return 0
        fi
        if [ "$choice" -ge 1 ] && [ "$choice" -le 11 ]; then
            local romano=$(get_unit_num_romano $choice)
            export CURRENT_UNIT="unit-$romano"
        else
            echo "  ❌ Opción inválida"
            return 1
        fi
    fi

    local unit="$CURRENT_UNIT"
    local unit_path; unit_path=$(resolve_unit_path "$unit")

    if [ ! -f "$unit_path/test.sh" ]; then
        echo "  ❌ Unidad no encontrada: $unit"
        return 1
    fi

    source "$unit_path/test.sh" 2>/dev/null || true

    echo ""
    echo -e "${CYAN}📊 Evaluando $unit...${RESET}"
    echo ""

    local total=${#challenge_names[@]}
    local pass=0 fail=0

    for ((i=1; i<=total; i++)); do
        local name="${challenge_names[$((i-1))]:-Reto $i}"
        local validator="reto${i}"

        if declare -f "$validator" >/dev/null 2>&1; then
            if "$validator" >/dev/null 2>&1; then
                marcar_completado "$unit" "$i"
                echo -e "  ${VERDE}✔ Reto $i: $name${RESET}"
                pass=$((pass+1))
            else
                echo -e "  ${ROJO}✘ Reto $i: $name${RESET}"
                fail=$((fail+1))
            fi
        fi
    done

    echo ""
    separador
    echo -e "  Resultados: ${VERDE}${pass} pasados${RESET} | ${ROJO}${fail} fallidos${RESET}"
    echo -ne "  Progreso: "; mostrar_barra_progreso "$pass" "$total"
    separador

    if [ "$fail" -eq 0 ]; then
        celebrar "¡Todos los retos completados!"
    fi
}

# Ver frases
ver_frase() {
    echo ""
    echo -e "${CYAN}🔑 FRASE SECRETA - Progreso por unidad:${RESET}"
    echo ""

    for i in {1..11}; do
        local romano=$(get_unit_num_romano $i)
        local u="unit-$romano"
        local compl=$(contar_completados "$u" 10 2>/dev/null || echo 0)
        local frase=$(get_frase_for_unit $i)

        if [ "$compl" -eq 10 ]; then
            echo -e "  ${VERDE}✅ Unidad $i: $frase${RESET}"
        else
            echo -e "  ${ROJO}🔒 Unidad $i: ??? ($compl/10 completados)${RESET}"
        fi
    done

    echo ""
}

# ─── Script ~/bin/lab ────────────────────────────────────────────────────────
mkdir -p ~/bin
cat > ~/bin/lab <<'SCRIPT'
#!/bin/bash
source /shared/common.sh
source /shared/menu.sh

# Cargar aliases
source ~/.bash_aliases 2>/dev/null

echo ""
echo "  📋 Laboratorio de Linux Server Admin"
echo ""
echo "  Comandos disponibles:"
echo "    menu          - Menú interactivo principal"
echo "    jugar         - Modo juego interactivo"
echo "    retos         - Ver retos de la unidad"
echo "    evaluar       - Evaluar progreso"
echo "    revelar-frase - Ver frase secreta"
echo "    progreso      - Ver progreso global"
echo ""
SCRIPT
chmod 755 ~/bin/lab
export PATH="$HOME/bin:$PATH"

# ─── Aliases persistentes ─────────────────────────────────────────────────────
cat > ~/.bash_aliases <<'ALIASES'
source /shared/common.sh
source /shared/menu.sh

# Comandos principales interactivos
alias menu='menu_interactivo'
alias jugar='jugar_interactivo'
alias retos='ver_retos_unidad'
alias evaluar='evaluar_interactivo'
alias revelar-frase='ver_frase'
alias s='ver_frase'
alias progreso='mostrar_progreso_global'

ALIASES

# Cargar aliases en la sesión actual
. ~/.bash_aliases

# ─── Mostrar banner de bienvenida ────────────────────────────────────────────
banner_bienvenida
echo ""
echo -e "  ${CYAN}Comandos disponibles:${RESET}"
echo "    ${VERDE}menu${RESET}          - Menú interactivo principal"
echo "    ${VERDE}jugar${RESET}         - Modo juego interactivo"
echo "    ${VERDE}retos${RESET}         - Ver retos de la unidad"
echo "    ${VERDE}evaluar${RESET}       - Evaluar progreso"
echo "    ${VERDE}revelar-frase${RESET} - Ver frase secreta"
echo "    ${VERDE}progreso${RESET}      - Ver progreso global"
echo ""
echo -e "  👉 Escribe ${CYAN}menu${RESET} para comenzar"
echo ""

# Mantener terminal interactiva abierta
exec bash -i
