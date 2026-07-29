#!/bin/bash
# Sistema de menus y navegacion para 11 unidades SDD

UNIDADES=("Unit I: Fundamentos (pendiente)" "Unit II: Gestión de Paquetes" "Unit III: Scripting Shell"
          "Unit IV: Usuarios y SSH" "Unit V: Procesos y systemd" "Unit VI: Almacenamiento y LVM"
          "Unit VII: Hardening" "Unit VIII: Docker" "Unit IX: Nginx" "Unit X: SSL/HTTPS"
          "Unit XI: Docker Compose + DB")
ICONOS=("🖥️" "📦" "🐚" "👥" "⚙️" "💾" "🛡️" "🐳" "🌐" "🔒" "🐘")
RETOS_POR_UNIDAD=(0 10 10 10 10 10 10 10 10 10 10)

mostrar_menu_principal() {
    clear; echo ""
    echo -e "${CYAN_B}╔══════════════════════════════════════════════════╗"
    echo "║     LABORATORIO DE LINUX SERVER ADMIN            ║"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
    mostrar_progreso_global; echo ""
    separador
    for ((i=0; i<${#UNIDADES[@]}; i++)); do
        local estado=""
        if [ $((i+1)) -eq 1 ]; then
            estado=" ${GRIS}(pendiente)${RESET}"
        fi
        printf "  ${VERDE}[%2d]${RESET} %s %s%s\n" "$((i+1))" "${ICONOS[$i]}" "${UNIDADES[$i]}" "$estado"
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

get_unit_total_retos() { echo "${RETOS_POR_UNIDAD[$(($1-1))]}"; }

ejecutar_unidad() {
    case $1 in
        unit-II|unit-III|unit-IV|unit-V|unit-VI|unit-VII|unit-VIII|unit-IX|unit-X|unit-XI)
            source "$HOME/laboratorio/units/${1}/test.sh" ;;
        unit-I)
            source "$HOME/laboratorio/units/i/test.sh" ;;
        *) error "Unidad no encontrada: $1"; return 1 ;;
    esac
}