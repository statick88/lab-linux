#!/bin/bash
# Sistema de menus y navegacion para 11 unidades SDD

UNIDADES=("Unit I: Fundamentos" "Unit II: Gestión de Paquetes" "Unit III: Scripting Shell"
          "Unit IV: Usuarios y SSH" "Unit V: Procesos y systemd" "Unit VI: Almacenamiento y LVM"
          "Unit VII: Hardening" "Unit VIII: Docker" "Unit IX: Nginx" "Unit X: SSL/HTTPS"
          "Unit XI: Docker Compose + DB")
ICONOS=("🖥️" "📦" "🐚" "👥" "⚙️" "💾" "🛡️" "🐳" "🌐" "🔒" "🐘")
RETOS_POR_UNIDAD=(10 10 10 10 10 10 10 10 10 10 10)

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
    local -n _names=$1 _icons=$2
    local unit="$3" total=${#_names[@]}
    while true; do
        clear; echo ""
        echo -e "${CYAN_B}╔══════════════════════════════════════════════════╗"
        printf "║  %-46s  ║" "${unit}"
        echo -e "╚══════════════════════════════════════════════════╝${RESET}"
        local completados=$(contar_completados "$unit" "$total")
        echo -ne "  Progreso: "; mostrar_barra_progreso "$completados" "$total"
        separador
        for ((i=0; i<total; i++)); do
            if esta_completado "$unit" "$((i+1))" 2>/dev/null; then
                echo -e "  ${VERDE}[✔]${RESET} ${_icons[$i]} Reto $((i+1)): ${_names[$i]}"
            else
                echo -e "  ${ROJO}[✘]${RESET} ${_icons[$i]} Reto $((i+1)): ${_names[$i]}"
            fi
        done
        separador; echo -e "  ${AMARILLO}[0]${RESET} 🏠 Volver\n"
        echo -n "  Selecciona un reto (1-${total}, 0=volver): "
        read -r reto_choice
        case "$reto_choice" in
            0|"") return 0 ;;
            [0-9]|[1-9][0-9])
                if [ "$reto_choice" -ge 1 ] && [ "$reto_choice" -le "$total" ]; then
                    jugar_reto "$unit" "$reto_choice"
                else error "Opcion invalida"; fi ;;
            *) error "Opcion invalida" ;;
        esac
    done
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
    local unit="$1"
    local unit_path; unit_path=$(resolve_unit_path "$unit")
    if [ ! -f "$unit_path/test.sh" ]; then error "Unidad no encontrada: $unit"; return 1; fi
    source "$unit_path/test.sh" 2>/dev/null || true
    mostrar_menu_retos challenge_names ICONOS "$unit"
}

# Punto de entrada principal para "jugar" - bucle interactivo por unidad
jugar_unidad() {
    local unit="${1:-}"
    
    # Si no se pasa unidad, mostrar menú para elegir
    if [ -z "$unit" ]; then
        echo -e "${CYAN}🎮 MODO JUGAR - Selecciona una unidad:${RESET}"
        echo ""
        for i in {1..11}; do
            local u="unit-$(echo I II III IV V VI VII VIII IX X XI | cut -d' ' -f$i)"
            local titulo=$(case $i in
                1) echo "Fundamentos" ;;
                2) echo "Gestión de Paquetes" ;;
                3) echo "Scripting Bash" ;;
                4) echo "Usuarios y SSH" ;;
                5) echo "Procesos y systemd" ;;
                6) echo "Almacenamiento y LVM" ;;
                7) echo "Hardening" ;;
                8) echo "Docker" ;;
                9) echo "Nginx" ;;
                10) echo "SSL/HTTPS" ;;
                11) echo "Docker Compose + DB" ;;
            esac)
            local completados=$(contar_completados "$u" 10 2>/dev/null || echo 0)
            echo -e "  ${VERDE}[$i]${RESET} $u - $titulo (${completados}/10)"
        done
        echo ""
        echo -n "  Elige unidad (1-11, Enter para actual): "
        read -r choice
        if [ -z "$choice" ]; then
            unit="${CURRENT_UNIT:-}"
            [ -z "$unit" ] && { error "No hay unidad actual. Usa 'unidad <n>' primero."; return 1; }
        else
            unit="unit-$(echo I II III IV V VI VII VIII IX X XI | cut -d' ' -f$choice)"
        fi
    fi
    
    local unit_path; unit_path=$(resolve_unit_path "$unit")
    if [ ! -f "$unit_path/test.sh" ]; then error "Unidad no encontrada: $unit"; return 1; fi
    source "$unit_path/test.sh" 2>/dev/null || true
    
    # Jugar el primer reto no completado
    local total=${#challenge_names[@]}
    for ((i=1; i<=total; i++)); do
        if ! esta_completado "$unit" "$i" 2>/dev/null; then
            jugar_reto "$unit" "$i" || return $?
            # jugar_reto ya maneja el avance al siguiente reto
            return $?
        fi
    done
    
    exito "¡Todos los retos de $unit completados! 🏆"
    echo -e "${AMARILLO}Usa 'menu' para ver progreso global o 'unidad <n>' para otra.${RESET}"
}

ejecutar_reto() {
    local unit="$1" reto_num="$2"
    local unit_path; unit_path=$(resolve_unit_path "$unit")
    if [ ! -f "$unit_path/test.sh" ]; then error "Unidad no encontrada: $unit"; return 1; fi
    source "$unit_path/test.sh"
    local info_func="reto${reto_num}_info"
    if declare -f "$info_func" >/dev/null 2>&1; then
        echo ""; titulo "Reto $reto_num"; "$info_func"; echo ""; separador
    fi
    local validator_func="reto${reto_num}"
    if declare -f "$validator_func" >/dev/null 2>&1; then
        echo -e "\n  ⏳ Verificando reto $reto_num..."
        if "$validator_func" >/dev/null 2>&1; then
            marcar_completado "$unit" "$reto_num"
            exito "Reto $reto_num completado"
            mostrar_frase_unidad "$(get_unit_index "$unit")"
            return 0
        else error "Reto $reto_num fallido"; return 1; fi
    else error "Reto $reto_num no encontrado en $unit"; return 1; fi
}

# ═══════════════════════════════════════════════════════════════════════════
# MODO INTERACTIVO POR RETO: instrucciones → comandos → verificar → avanzar
# ═══════════════════════════════════════════════════════════════════════════

jugar_reto() {
    local unit="$1" reto_num="$2"
    local unit_path; unit_path=$(resolve_unit_path "$unit")
    if [ ! -f "$unit_path/test.sh" ]; then error "Unidad no encontrada: $unit"; return 1; fi
    source "$unit_path/test.sh"
    
    local info_func="reto${reto_num}_info"
    local validator_func="reto${reto_num}"
    local reto_name="${challenge_names[$((reto_num-1))]:-Reto $reto_num}"
    
    if ! declare -f "$validator_func" >/dev/null 2>&1; then
        error "Reto $reto_num no existe en $unit"; return 1
    fi
    
    # Verificar si ya está completado
    if esta_completado "$unit" "$reto_num" 2>/dev/null; then
        exito "Este reto ya está completado ✔"
        echo -n "  ¿Quieres jugarlo de nuevo? (s/N): "; read -r replay
        [[ "$replay" =~ ^[sS]$ ]] || return 0
    fi
    
    clear
    echo -e "${CYAN_B}╔═══════════════════════════════════════════════════════════════════╗"
    printf "║  🎮  %-58s  ║\n" "$unit — Reto $reto_num: $reto_name"
    echo -e "╚═══════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Mostrar instrucciones
    if declare -f "$info_func" >/dev/null 2>&1; then
        "$info_func"
    else
        echo -e "${AMARILLO}ℹ No hay instrucciones específicas para este reto.${RESET}"
        echo "Intenta explorar y experimentar con comandos relacionados."
        separador
    fi
    
    echo -e "${VERDE}💡 Ejecuta tus comandos en esta terminal.${RESET}"
    echo -e "${VERDE}   Cuando creas que lo resolviste, escribe: ${CYAN}verificar${RESET}"
    echo -e "${VERDE}   Para ver la pista: ${CYAN}pista${RESET}"
    echo -e "${VERDE}   Para salir sin completar: ${CYAN}salir${RESET}"
    separador
    
    # Loop interactivo
    local intentos=0
    while true; do
        echo -ne "${AZUL}[$unit|R$reto_num]${RESET} $ "
        read -r cmd
        
        case "$cmd" in
            verificar|ver)
                ((intentos++))
                echo -e "\n  ${CYAN}🔍 Verificando intento #$intentos...${RESET}"
                if "$validator_func" >/dev/null 2>&1; then
                    marcar_completado "$unit" "$reto_num"
                    echo ""
                    exito "¡Reto $reto_num COMPLETADO! ✨"
                    mostrar_frase_unidad "$(get_unit_index "$unit")"
                    echo ""
                    progreso
                    
                    # Ofrecer siguiente reto
                    local total=${#challenge_names[@]}
                    if [ "$reto_num" -lt "$total" ]; then
                        local next=$((reto_num + 1))
                        local next_name="${challenge_names[$((next-1))]}"
                        echo -ne "${AMARILLO}▶ ¿Quieres continuar con el Reto $next: $next_name? (S/n): ${RESET}"
                        read -r cont
                        if [[ ! "$cont" =~ ^[nN]$ ]]; then
                            jugar_reto "$unit" "$next"
                            return $?
                        fi
                    else
                        exito "¡Unidad $unit COMPLETA! 🏆"
                    fi
                    return 0
                else
                    error "Aún no está resuelto. Intenta de nuevo."
                    # Dar pista contextual según el reto
                    dar_pista "$unit" "$reto_num"
                fi
                ;;
            pista|hint|ayuda|help)
                dar_pista "$unit" "$reto_num"
                ;;
            salir|exit|quit|q)
                echo -e "${AMARILLO}⏸ Progreso guardado. Vuelve cuando quieras.${RESET}"
                return 1
                ;;
            "")
                # Enter vacío, solo muestra prompt de nuevo
                ;;
            *)
                # Ejecutar comando del usuario
                eval "$cmd"
                ;;
        esac
    done
}

# Pistas contextuales por unidad y reto
dar_pista() {
    local unit="$1" reto_num="$2"
    echo -e "\n  ${CYAN}💡 PISTA:${RESET}"
    case "$unit" in
        unit-I)
            case "$reto_num" in
                1) echo "    El directorio /etc es donde viven los archivos de configuración del sistema." ;;
                2) echo "    /var guarda logs y datos que persisten; /tmp se borra al reiniciar." ;;
                3) echo "    pwd = Print Working Directory. Muestra dónde estás parado." ;;
                4) echo "    ls -a muestra archivos ocultos (los que empiezan con punto)." ;;
                5) echo "    7=rwx (dueño), 5=r-x (grupo), 5=r-x (otros). Suma: 4+2+1=7, 4+0+1=5." ;;
                6) echo "    WSL2 corre un kernel Linux real dentro de una VM ligera." ;;
                7) echo "    mount une un sistema de archivos a un directorio del árbol." ;;
                8) echo "    root siempre tiene UID 0. Es el superusuario." ;;
                9) echo "    El pipe | conecta la salida de un comando a la entrada de otro." ;;
                10) echo "    df -h = disk free human-readable. Muestra espacio en disco." ;;
            esac
            ;;
        unit-II)
            case "$reto_num" in
                1) echo "    sudo apt-get update actualiza la lista de paquetes disponibles." ;;
                2) echo "    sudo apt-get install -y vim instala el editor vim." ;;
                3) echo "    Puedes instalar varios paquetes a la vez: sudo apt-get install -y curl tree" ;;
                4) echo "    apt-cache show nginx muestra metadatos del paquete nginx." ;;
                5) echo "    apt-cache search editor busca paquetes relacionados con 'editor'." ;;
                6) echo "    dpkg -l vim lista el estado del paquete vim." ;;
                7) echo "    dpkg -L curl lista todos los archivos que instaló el paquete curl." ;;
                8) echo "    dpkg -S /usr/bin/vim te dice qué paquete instaló ese archivo." ;;
                9) echo "    apt-get remove elimina el paquete pero guarda configs; purge borra todo." ;;
                10) echo "    apt-get purge curl elimina el paquete Y sus archivos de configuración." ;;
            esac
            ;;
        *)
            echo "    Revisa los comandos relacionados con el tema de este reto."
            echo "    Usa 'man <comando>' o '<comando> --help' para más info."
            ;;
    esac
    separador
}
