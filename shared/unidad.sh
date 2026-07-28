#!/bin/bash
# unidad.sh - Cambiar a una unidad del curso (II-XI)
# Uso: unidad <número>

source /shared/common.sh

get_unit_title() {
    case $1 in
        2) echo "Gestion de Paquetes" ;;
        3) echo "Scripting Bash" ;;
        4) echo "Usuarios y SSH" ;;
        5) echo "Procesos y systemd" ;;
        6) echo "Almacenamiento y LVM" ;;
        7) echo "Hardening" ;;
        8) echo "Docker" ;;
        9) echo "Nginx" ;;
        10) echo "SSL/HTTPS" ;;
        11) echo "Docker Compose + DB" ;;
    esac
}

# Mapear número a nombre de directorio (minúsculas como en el filesystem)
get_unit_dir() {
    case $1 in
        2) echo "ii" ;;
        3) echo "iii" ;;
        4) echo "iv" ;;
        5) echo "v" ;;
        6) echo "vi" ;;
        7) echo "vii" ;;
        8) echo "viii" ;;
        9) echo "ix" ;;
        10) echo "x" ;;
        11) echo "xi" ;;
    esac
}

# Mapear número a nombre de unidad para el estado (con prefijo unit-)
get_unit_name() {
    case $1 in
        2) echo "unit-II" ;;
        3) echo "unit-III" ;;
        4) echo "unit-IV" ;;
        5) echo "unit-V" ;;
        6) echo "unit-VI" ;;
        7) echo "unit-VII" ;;
        8) echo "unit-VIII" ;;
        9) echo "unit-IX" ;;
        10) echo "unit-X" ;;
        11) echo "unit-XI" ;;
    esac
}

if [ $# -eq 0 ]; then
    echo -e "${CYAN}Uso: unidad <número>${RESET}"
    echo -e "${CYAN}Unidades disponibles: 2-11${RESET}"
    echo ""
    echo -e "  ${VERDE}2${RESET}  Gestión de Paquetes"
    echo -e "  ${VERDE}3${RESET}  Scripting Bash"
    echo -e "  ${VERDE}4${RESET}  Usuarios y SSH"
    echo -e "  ${VERDE}5${RESET}  Procesos y systemd"
    echo -e "  ${VERDE}6${RESET}  Almacenamiento y LVM"
    echo -e "  ${VERDE}7${RESET}  Hardening"
    echo -e "  ${VERDE}8${RESET}  Docker (DinD)"
    echo -e "  ${VERDE}9${RESET}  Nginx"
    echo -e "  ${VERDE}10${RESET} SSL/HTTPS"
    echo -e "  ${VERDE}11${RESET} Docker Compose + DB"
    echo ""
    echo -e "${AMARILLO}Unidad actual: ${CURRENT_UNIT:-ninguna}${RESET}"
    exit 0
fi

UNIT_NUM=$1

if [ "$UNIT_NUM" -lt 2 ] || [ "$UNIT_NUM" -gt 11 ]; then
    error "Unidad debe estar entre 2 y 11"
    exit 1
fi

UNIT_DIR_NAME=$(get_unit_dir "$UNIT_NUM")
UNIT_NAME=$(get_unit_name "$UNIT_NUM")

# Verificar si la unidad existe (en el directorio del usuario, copiado desde /opt)
UNIT_DIR="$HOME/laboratorio/units/$UNIT_DIR_NAME"
if [ ! -d "$UNIT_DIR" ]; then
    error "Unidad $UNIT_NUM no encontrada en $UNIT_DIR"
    exit 1
fi

# Ejecutar setup.sh si es la primera vez (usando marker)
MARKER="$HOME/.unit_${UNIT_NAME}_initialized"
if [ ! -f "$MARKER" ]; then
    info "Ejecutando configuración inicial para $UNIT_NAME..."
    cd "$UNIT_DIR"
    bash setup.sh
    touch "$MARKER"
    exito "Configuración completada"
else
    info "Unidad $UNIT_NAME ya configurada"
fi

# Establecer unidad actual
export CURRENT_UNIT="$UNIT_NAME"
echo "$UNIT_NAME" > "$HOME/.current_unit"

# Mostrar manual de la unidad
echo ""
banner_unidad "$UNIT_NUM" "$(get_unit_title "$UNIT_NUM")"
bash "$UNIT_DIR/manual.sh"

echo -e "\n${AMARILLO}Comandos disponibles:${RESET}"
echo -e "  ${CYAN}retos-unidad${RESET}  Ver retos de esta unidad"
echo -e "  ${CYAN}evaluar-unidad${RESET}  Evaluar progreso"
echo -e "  ${CYAN}revelar-frase${RESET}   Ver frase oculta"