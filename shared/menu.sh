#!/bin/bash
# Sistema de menus y navegacion

UNIDADES=("Unit I: Introduccion" "Unit II: Servicios de Red" "Unit III: Seguridad Basica"
          "Unit IV: Gestion de Usuarios" "Unit V: Almacenamiento" "Unit VI: Paquetes"
          "Unit VII: Procesos y Servicios" "Unit VIII: Docker" "Unit IX: Networking"
          "Unit X: Logs y Auditoria" "Unit XI: Seguridad Avanzada")
ICONOS=("🖥️" "🌐" "🔒" "👥" "💾" "📦" "🔧" "🐳" "🌐" "📋" "🛡️")
RETOS_POR_UNIDAD=(10 10 10 10 10 8 10 10 10 10 10)

mostrar_menu_principal() {
    clear; echo ""
    echo -e "${CYAN_B}╔══════════════════════════════════════════════════╗"
    echo "║     LABORATORIO DE LINUX SERVER ADMIN            ║"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
    mostrar_progreso_global; echo ""
    separador
    for ((i=0; i<${#UNIDADES[@]}; i++)); do
        printf "  ${VERDE}[%2d]${RESET} %s %s\n" "$((i+1))" "${ICONOS[$i]}" "${UNIDADES[$i]}"
    done
    separador
    echo -e "  ${AMARILLO}[s]${RESET} 🔑 Revelar frase  ${AMARILLO}[q]${RESET} 🚪 Salir\n"
}

mostrar_menu_retos() {
    local -n r=$1 ic=$2 unit=$3 total=${#r[@]} i
    echo ""; titulo "Seleccion de Retos"
    for ((i=0; i<total; i++)); do
        if esta_completado "$unit" "$((i+1))" 2>/dev/null; then
            echo -e "  ${VERDE}[✔]${RESET} ${ic[$i]} Reto $((i+1)): ${r[$i]}"
        else
            echo -e "  ${ROJO}[✘]${RESET} ${ic[$i]} Reto $((i+1)): ${r[$i]}"
        fi
    done
    echo -e "\n  ${AMARILLO}[0]${RESET} 🏠 Volver  ${AMARILLO}[p]${RESET} 📊 Progreso  ${AMARILLO}[f]${RESET} 🔑 Frase\n"
}

mostrar_progreso_global() {
    local total=0 completados=0 unit_name i r
    for ((i=0; i<${#UNIDADES[@]}; i++)); do
        unit_name=$(get_unit_name "$((i+1))")
        for ((r=1; r<=${RETOS_POR_UNIDAD[$i]}; r++)); do
            total=$((total+1))
            esta_completado "$unit_name" "$r" 2>/dev/null && completados=$((completados+1))
        done
    done
    echo -ne "  Progreso total: "; mostrar_barra_progreso "$completados" "$total"
}

get_unit_name() {
    case $1 in
        1)echo"unit-I";;2)echo"unit-II";;3)echo"unit-III";;4)echo"unit-IV";;5)echo"unit-V";;
        6)echo"unit-VI";;7)echo"unit-VII";;8)echo"unit-VIII";;9)echo"unit-IX";;10)echo"unit-X";;11)echo"unit-XI";;
    esac
}

get_unit_total_retos() { echo "${RETOS_POR_UNIDAD[$(($1-1))]}"; }

ejecutar_unidad() {
    case $1 in
        unit-I|unit-II|unit-III|unit-IV|unit-V|unit-VI|unit-VII|unit-VIII|unit-IX|unit-X|unit-XI)
            source "/shared/units/${1}/eval.sh" ;;
        *) error "Unidad no encontrada: $1"; return 1 ;;
    esac
}
