#!/bin/bash
# Funciones de evaluacion y progreso
# Usa directorio en home del usuario para evitar problemas de permisos
STATE_DIR="${HOME}/.lab_state"
PROGRESS_FILE="${STATE_DIR}/progress"

init_state() { mkdir -p "$STATE_DIR"; touch "$PROGRESS_FILE" 2>/dev/null; }

marcar_completado() {
    local key="${1}:reto:${2}"
    grep -q "^${key}$" "$PROGRESS_FILE" 2>/dev/null || echo "${key}" >> "$PROGRESS_FILE"
}

esta_completado() {
    grep -q "^${1}:reto:${2}$" "$PROGRESS_FILE" 2>/dev/null
}

contar_completados() {
    local unit=$1 total=$2 count=0 i
    for ((i=1; i<=total; i++)); do
        esta_completado "$unit" "$i" && count=$((count+1))
    done
    echo "$count"
}

mostrar_estado_retos() {
    local unit=$1 -n retos_ref=$2 total=${#retos_ref[@]} i
    completados=$(contar_completados "$unit" "$total")
    echo -e "\n${CYAN_B}Estado de retos:${RESET}"
    separador
    for ((i=0; i<total; i++)); do
        if esta_completado "$unit" "$((i+1))"; then
            echo -e "  ${VERDE}✔ Reto $((i+1)): ${retos_ref[$i]}${RESET}"
        else
            echo -e "  ${ROJO}✘ Reto $((i+1)): ${retos_ref[$i]}${RESET}"
        fi
    done
    separador
    echo -ne "  Progreso: "; mostrar_barra_progreso "$completados" "$total"
}

ejecutar_evaluacion() {
    local unit=$1 total=$2; shift 2; local -a v=("$@") pass=0 fail=0 i
    echo ""; titulo "Evaluacion - ${unit}"
    for ((i=0; i<total; i++)); do
        if [ -n "${v[$i]}" ] && "${v[$i]}" >/dev/null 2>&1; then
            marcar_completado "$unit" "$((i+1))"; exito "Reto $((i+1)) completado"; pass=$((pass+1))
        else
            error "Reto $((i+1)) fallido"; fail=$((fail+1))
        fi
    done
    echo ""; separador
    echo -e "Resultados: ${VERDE}${pass} pasados${RESET} | ${ROJO}${fail} fallidos${RESET}"
    separador
    [ "$fail" -eq 0 ] && celebrar "Todos los retos completados"
    return $fail
}

celebrar() {
    echo -e "\n${VERDE_B}╔══════════════════════════════════════════════════╗"
    echo "║   🎉  $1"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
}