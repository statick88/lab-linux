#!/bin/bash
# evaluar-unidad.sh - Evaluar la unidad actual

source /shared/common.sh

if [ -z "$CURRENT_UNIT" ]; then
    if [ -f "$HOME/.current_unit" ]; then
        export CURRENT_UNIT=$(cat "$HOME/.current_unit")
    fi
fi

if [ -z "$CURRENT_UNIT" ]; then
    warning "No hay unidad seleccionada. Usa 'unidad <2-11>' para seleccionar una."
    exit 1
fi

# Extraer número de unidad del nombre (unit-II -> II)
UNIT_ROMAN=$(echo "$CURRENT_UNIT" | sed 's/unit-//')

# Mapear romano a directorio lowercase
case "$UNIT_ROMAN" in
    II) UNIT_DIR="ii" ;;
    III) UNIT_DIR="iii" ;;
    IV) UNIT_DIR="iv" ;;
    V) UNIT_DIR="v" ;;
    VI) UNIT_DIR="vi" ;;
    VII) UNIT_DIR="vii" ;;
    VIII) UNIT_DIR="viii" ;;
    IX) UNIT_DIR="ix" ;;
    X) UNIT_DIR="x" ;;
    XI) UNIT_DIR="xi" ;;
    *) UNIT_DIR="" ;;
esac

if [ -z "$UNIT_DIR" ]; then
    error "No se pudo determinar el directorio de la unidad: $CURRENT_UNIT"
    exit 1
fi

TEST_FILE="$HOME/laboratorio/units/$UNIT_DIR/test.sh"

if [ ! -f "$TEST_FILE" ]; then
    error "Test no encontrado: $TEST_FILE"
    exit 1
fi

# Obtener índice para la frase (1-11)
case "$UNIT_ROMAN" in
    II) IDX=2 ;;
    III) IDX=3 ;;
    IV) IDX=4 ;;
    V) IDX=5 ;;
    VI) IDX=6 ;;
    VII) IDX=7 ;;
    VIII) IDX=8 ;;
    IX) IDX=9 ;;
    X) IDX=10 ;;
    XI) IDX=11 ;;
    *) IDX=0 ;;
esac

echo -e "${CYAN_B}Evaluando $CURRENT_UNIT...${RESET}"
echo ""

bash "$TEST_FILE"

# Mostrar frase si la unidad está completada
if [ $IDX -gt 0 ] && unidad_completada "$CURRENT_UNIT"; then
    echo ""
    mostrar_frase_unidad "$IDX"
fi