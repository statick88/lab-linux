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

# ─── Aliases persistentes (sistema unificado) ────────────────────────────────
cat > ~/.bash_aliases <<'EOF'
# Cargar librerías compartidas (necesario para funciones del menú)
source /shared/common.sh
source /shared/menu.sh

# Sistema unificado 11 unidades × 10 retos = 110 retos
alias menu='menu_interactivo'
alias progreso='mostrar_progreso_global'
alias unidad='bash /shared/unidad.sh'
alias retos='ver_retos_unidad'
alias retos-unidad='ver_retos_unidad'
alias evaluar='evaluar_unidad'
alias evaluar-unidad='evaluar_unidad'
alias jugar='jugar_unidad'
alias revelar-frase='ver_frase'
alias s='ver_frase'

# Funciones interactivas
menu_interactivo() {
    while true; do
        clear
        mostrar_menu_principal
        echo -n "  Selecciona una opción (1-11, s=frase, q=salir): "
        read -r choice
        case "$choice" in
            q|Q|quit|exit) echo "  👋 ¡Hasta luego!"; break ;;
            s|S) ver_frase ;;
            [1-9]|10|11)
                if [ "$choice" -ge 1 ] && [ "$choice" -le 11 ]; then
                    export CURRENT_UNIT="unit-$(get_unit_num_romano $choice)"
                    echo "$CURRENT_UNIT" > ~/.current_unit
                    jugar_unidad "$CURRENT_UNIT"
                else
                    echo "  ❌ Opción inválida"
                fi
                ;;
            *) echo "  ❌ Opción inválida" ;;
        esac
        echo ""
        echo -n "  Presiona Enter para continuar..."
        read -r
    done
}

get_unit_num_romano() {
    case $1 in
        1) echo "I" ;;2) echo "II" ;;3) echo "III" ;;4) echo "IV" ;;5) echo "V" ;;
        6) echo "VI" ;;7) echo "VII" ;;8) echo "VIII" ;;9) echo "IX" ;;10) echo "X" ;;11) echo "XI" ;;
    esac
}

ver_retos_unidad() {
    if [ -z "$CURRENT_UNIT" ]; then
        if [ -f "$HOME/.current_unit" ]; then
            export CURRENT_UNIT=$(cat "$HOME/.current_unit")
        fi
    fi
    if [ -z "$CURRENT_UNIT" ]; then
        echo "  ⚠️  Primero selecciona una unidad: menu"
        return 1
    fi
    bash /shared/retos-unidad.sh
}

evaluar_unidad() {
    if [ -z "$CURRENT_UNIT" ]; then
        if [ -f "$HOME/.current_unit" ]; then
            export CURRENT_UNIT=$(cat "$HOME/.current_unit")
        fi
    fi
    if [ -z "$CURRENT_UNIT" ]; then
        echo "  ⚠️  Primero selecciona una unidad: menu"
        return 1
    fi
    bash /shared/eval.sh "$CURRENT_UNIT" 10
}

ver_frase() {
    if [ -z "$CURRENT_UNIT" ]; then
        echo "  📝 Frases de cada unidad:"
        for i in {1..11}; do
            local u="unit-$(get_unit_num_romano $i)"
            local compl=$(contar_completados "$u" 10 2>/dev/null || echo 0)
            if [ "$compl" -eq 10 ]; then
                local frase=$(get_frase_for_unit $i)
                echo "     Unidad $i: ✅ $frase"
            else
                echo "     Unidad $i: 🔒 (completa la unidad para revelar)"
            fi
        done
    else
        local idx=$(get_unit_index "$CURRENT_UNIT")
        mostrar_frase_unidad "$idx"
    fi
}
EOF

# ─── Script ~/bin/lab ────────────────────────────────────────────────────────
mkdir -p ~/bin
cat > ~/bin/lab <<'SCRIPT'
#!/bin/bash
# lab script — evaluar progreso del laboratorio unificado
source /shared/common.sh
source /shared/eval.sh
echo ""
echo "  📋 Evaluando progreso del laboratorio..."
echo ""
ejecutar_evaluacion
SCRIPT
chmod 755 ~/bin/lab
export PATH="$HOME/bin:$PATH"

# Cargar aliases en la sesión actual
. ~/.bash_aliases

# ─── Mostrar banner de bienvenida y menú interactivo ──────────────────────────
banner_bienvenida
echo ""
echo "  Comandos disponibles:"
echo "    menu          - Menú interactivo"
echo "    retos         - Ver retos de la unidad actual"
echo "    evaluar       - Evaluar progreso"
echo "    jugar         - Modo juego interactivo"
echo "    revelar-frase - Ver la palabra oculta"
echo "    progreso      - Ver progreso global"
echo ""
echo "  👉 Escribe 'menu' para comenzar"
echo ""

# Mantener terminal interactiva abierta
exec bash -i