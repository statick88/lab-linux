#!/bin/bash
# =============================================================================
# Funciones interactivas del laboratorio
# Se cargan desde .bash_aliases para que estén disponibles en cada shell
# =============================================================================

# Convertir número a romano
get_unit_num_romano() {
    case $1 in
        1) echo "I" ;;2) echo "II" ;;3) echo "III" ;;4) echo "IV" ;;5) echo "V" ;;
        6) echo "VI" ;;7) echo "VII" ;;8) echo "VIII" ;;9) echo "IX" ;;10) echo "X" ;;11) echo "XI" ;;
    esac
}

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
    ejecutar_unidad "$CURRENT_UNIT"
}

# Jugar de forma interactiva
jugar_interactivo() {
    local unit="${1:-}"

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

    local unit_path; unit_path=$(resolve_unit_path "$unit")
    if [ ! -f "$unit_path/test.sh" ]; then
        echo "  ❌ Unidad no encontrada: $unit"
        return 1
    fi
    source "$unit_path/test.sh" 2>/dev/null || true

    local total=${#challenge_names[@]}
    local reto=1

    while [ "$reto" -le "$total" ]; do
        if esta_completado "$unit" "$reto" 2>/dev/null; then
            reto=$((reto + 1))
            continue
        fi

        jugar_reto "$unit" "$reto"
        local result=$?

        if [ $result -eq 0 ]; then
            reto=$((reto + 1))
        else
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
