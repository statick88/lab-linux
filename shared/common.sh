#!/bin/bash
# Modulo comun - carga todos los modulos compartidos
COURSE_DIR="/shared"
source "${COURSE_DIR}/colors.sh"
source "${COURSE_DIR}/eval.sh"
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

unidad_completada() {
    local total; total=$(get_unit_total_retos "$(get_unit_index "$1")")
    local compl; compl=$(contar_completados "$1" "$total")
    [ "$compl" -eq "$total" ]
}
