#!/bin/bash
# Modulo comun - carga todos los modulos compartidos
COURSE_DIR="/shared"
source "${COURSE_DIR}/colors.sh"
source "${COURSE_DIR}/eval.sh"
source "${COURSE_DIR}/metrics.sh" 2>/dev/null || true
source "${COURSE_DIR}/menu.sh"
source "${COURSE_DIR}/banner.sh"
init_state

CURRENT_UNIT=""
FRASES_OCULTAS=("Toda" "revolution" "comienza" "con" "un" "pass"
                "Los" "administradores" "nunca" "duermen" "!")

get_frase_for_unit() {
    local idx=$1
    [ "$idx" -ge 1 ] && [ "$idx" -le ${#FRASES_OCULTAS[@]} ] && echo "${FRASES_OCULTAS[$((idx-1))]}"
}

get_unit_index() {
    case $1 in
        unit-I)echo 1;;unit-II)echo 2;;unit-III)echo 3;;unit-IV)echo 4;;unit-V)echo 5;;
        unit-VI)echo 6;;unit-VII)echo 7;;unit-VIII)echo 8;;unit-IX)echo 9;;unit-X)echo 10;;unit-XI)echo 11;;*)echo 0;;
    esac
}

mostrar_frase_unidad() {
    local frase; frase=$(get_frase_for_unit "$1")
    [ -n "$frase" ] && echo -e "${AMARILLO}Frase revelada: ${frase}${RESET}"
}

# Mapear número a nombre de directorio (minúsculas como en el filesystem)
get_unit_dir() {
    case $1 in
        1) echo "i" ;;2) echo "ii" ;;3) echo "iii" ;;4) echo "iv" ;;5) echo "v" ;;
        6) echo "vi" ;;7) echo "vii" ;;8) echo "viii" ;;9) echo "ix" ;;10) echo "x" ;;
        11) echo "xi" ;;*) echo "" ;;
    esac
}

# Mapear número a nombre de unidad (necesario por menu.sh)
get_unit_name() {
    case $1 in
        1) echo "unit-I" ;;2) echo "unit-II" ;;3) echo "unit-III" ;;4) echo "unit-IV" ;;
        5) echo "unit-V" ;;6) echo "unit-VI" ;;7) echo "unit-VII" ;;8) echo "unit-VIII" ;;
        9) echo "unit-IX" ;;10) echo "unit-X" ;;11) echo "unit-XI" ;;*) echo "" ;;
    esac
}

# Resolver ruta completa de una unidad
resolve_unit_path() {
    local unit="$1"
    local unit_num; unit_num=$(get_unit_index "$unit")
    local dir_name; dir_name=$(get_unit_dir "$unit_num")
    echo "$HOME/laboratorio/units/$dir_name"
}

unidad_completada() {
    local total; total=$(get_unit_total_retos "$(get_unit_index "$1")")
    local compl; compl=$(contar_completados "$1" "$total")
    [ "$compl" -eq "$total" ]
}
