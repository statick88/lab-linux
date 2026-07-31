#!/bin/bash
# =============================================================================
# entrypoint.sh - Punto de entrada del contenedor del laboratorio
# =============================================================================

# Cargar biblioteca compartida (common.sh ya carga colors, eval, metrics, menu, banner)
source /shared/common.sh
source /shared/interactive.sh

# ─── Copiar unidades desde /opt si no existen ────────────────────────────────
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

# ─── Crear .bash_aliases para que cada nuevo shell tenga los comandos ────────
cat > ~/.bash_aliases <<'ALIASES'
# Cargar funciones del laboratorio (common.sh incluye todo el chain)
source /shared/common.sh
source /shared/interactive.sh

# Comandos principales
alias menu='menu_interactivo'
alias jugar='jugar_interactivo'
alias retos='ver_retos_unidad'
alias evaluar='evaluar_interactivo'
alias progreso='mostrar_progreso_global'
alias pista='dar_pista'

# Frase secreta
alias revelar-frase='ver_frase'
alias s='ver_frase'
ALIASES

# ─── Script ~/bin/lab ────────────────────────────────────────────────────────
mkdir -p ~/bin
cat > ~/bin/lab <<'SCRIPT'
#!/bin/bash
# ~/bin/lab - Acceso rápido al laboratorio
source /shared/common.sh
source /shared/interactive.sh
menu_interactivo
SCRIPT
chmod 755 ~/bin/lab
export PATH="$HOME/bin:$PATH"

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

# Mantener terminal interactiva
exec bash -i
