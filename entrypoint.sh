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
if [ ! -f ~/.bash_aliases ] || ! grep -q "alias menu=" ~/.bash_aliases 2>/dev/null; then
    cat > ~/.bash_aliases <<'EOF'
# Cargar librerías compartidas (necesario para funciones del menú)
source /shared/common.sh
source /shared/menu.sh

# Sistema unificado 11 unidades × 10 retos = 110 retos
alias menu='mostrar_menu_principal'
alias progreso='mostrar_progreso_global'
alias unidad='bash /shared/unidad.sh'
alias retos='bash /shared/retos-unidad.sh'
alias retos-unidad='bash /shared/retos-unidad.sh'
alias evaluar='bash /shared/eval.sh'
alias evaluar-unidad='bash /shared/eval.sh'
alias jugar='jugar_unidad'
alias revelar-frase='mostrar_frase_unidad'
EOF
fi

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

# ─── Mostrar banner de bienvenida ────────────────────────────────────────────
banner_bienvenida
mostrar_menu_principal

# Mantener terminal interactiva abierta
exec bash -i