#!/bin/bash
# Banners y elementos visuales

banner_bienvenida() {
    clear
    echo -e "${CYAN_B}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║          LABORATORIO DE LINUX SERVER ADMIN                  ║
║            Administracion de Servidores Linux               ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
}

banner_unidad() {
    echo -e "\n${CYAN_B}╔══════════════════════════════════════════════════╗"
    echo "║  Unit $1: $2"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}\n"
}

banner_felicitacion() {
    echo -e "\n${VERDE_B}╔══════════════════════════════════════════════════╗"
    echo "║   🎉  FELICIDADES - UNIDAD COMPLETADA"
    echo "║   Palabra revelada: $2"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
}

banner_frase_completa() {
    echo -e "\n${VERDE_B}╔══════════════════════════════════════════════════╗"
    echo "║   🏆  FRASE SECRETA COMPLETA"
    echo "║   Has completado todas las unidades del curso."
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
}
