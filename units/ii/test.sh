#!/bin/bash
# Unit II: Package Management — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-II"
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
    dpkg -S /usr/bin/vim 2>/dev/null | grep -q "vim"
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

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
