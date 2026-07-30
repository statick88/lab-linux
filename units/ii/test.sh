#!/bin/bash
# Unit II: Package Management — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-II"
TOTAL_RETOS=10
INITIAL_PACKAGE_COUNT=$(dpkg -l | grep "^ii" | wc -l)

reto1() {
    # Verificar que apt-get update ejecuto correctamente
    apt-cache policy apt >/dev/null 2>&1
}

reto2() {
    # Verificar que vim esta instalado
    dpkg -l vim 2>/dev/null | grep -q "^ii"
}

reto3() {
    # Verificar que curl y tree estan instalados
    dpkg -l curl tree 2>/dev/null | grep -q "^ii"
}

reto4() {
    # Verificar que apt-cache show funciona
    apt-cache show nginx 2>/dev/null | grep -q "^Package:"
}

reto5() {
    # Verificar que apt-cache search funciona
    apt-cache search editor 2>/dev/null | grep -q "."
}

reto6() {
    # Verificar que dpkg -l muestra info de vim
    dpkg -l vim 2>/dev/null | grep -q "vim"
}

reto7() {
    # Verificar que dpkg -L lista archivos de curl
    dpkg -L curl 2>/dev/null | grep -q "/usr/"
}

reto8() {
    # Verificar que dpkg -S identifica el paquete de vim
    dpkg -S /usr/bin/vim.basic 2>/dev/null | grep -q "vim"
}

reto9() {
    # Verificar que vim fue eliminado (pero no purge)
    ! dpkg -l vim 2>/dev/null | grep -q "^ii"
}

reto10() {
    # Verificar que curl fue eliminado completamente
    ! dpkg -l curl 2>/dev/null | grep -q "^ii"
    # Verificar que no queda configuracion
    [ ! -d /etc/curl ] 2>/dev/null
}

# Array de funciones de evaluacion
validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Actualizar repositorios"
    "Instalar vim"
    "Instalar curl y tree"
    "Consultar info de paquete"
    "Buscar paquetes"
    "Consultar estado con dpkg"
    "Listar archivos de paquete"
    "Identificar paquete propietario"
    "Eliminar paquete (conservar config)"
    "Eliminar paquete y configuracion"
)

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Actualizar repositorios${NC}"
    echo ""
    echo "Actualiza los repositorios de paquetes del sistema."
    echo "Comando útil: sudo apt-get update"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Instalar vim${NC}"
    echo ""
    echo "Instala el editor de texto vim usando apt-get."
    echo "Comando útil: sudo apt-get install -y vim"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Instalar curl y tree${NC}"
    echo ""
    echo "Instala los paquetes curl y tree en una sola línea."
    echo "Comando útil: sudo apt-get install -y curl tree"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Consultar info de paquete${NC}"
    echo ""
    echo "Consulta la información detallada del paquete nginx."
    echo "Comando útil: apt-cache show nginx"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Buscar paquetes${NC}"
    echo ""
    echo "Busca paquetes relacionados con 'editor' en los repositorios."
    echo "Comando útil: apt-cache search editor"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Consultar estado con dpkg${NC}"
    echo ""
    echo "Consulta el estado de instalación del paquete vim con dpkg."
    echo "Comando útil: dpkg -l vim"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Listar archivos de paquete${NC}"
    echo ""
    echo "Lista todos los archivos que pertenecen al paquete curl."
    echo "Comando útil: dpkg -L curl"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Identificar paquete propietario${NC}"
    echo ""
    echo "Identifica qué paquete es dueño del archivo /usr/bin/vim."
    echo "Comando útil: dpkg -S /usr/bin/vim"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Eliminar paquete (conservar config)${NC}"
    echo ""
    echo "Elimina el paquete vim pero conserva su configuración."
    echo "Comando útil: sudo apt-get remove vim"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Eliminar paquete y configuración${NC}"
    echo ""
    echo "Elimina el paquete curl junto con toda su configuración."
    echo "Comando útil: sudo apt-get purge curl"
    separador
}
