#!/bin/bash
# Unit IV: User Management — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-IV"
TOTAL_RETOS=10

reto1() {
    # Verificar que el usuario practicante existe
    id practicante >/dev/null 2>&1
}

reto2() {
    # Verificar que el grupo desarrolladores existe
    getent group desarrolladores >/dev/null 2>&1
}

reto3() {
    # Verificar que practicante esta en el grupo desarrolladores
    groups practicante 2>/dev/null | grep -q "desarrolladores"
}

reto4() {
    # Verificar que practicante tiene contrasena configurada
    sudo passwd -S practicante 2>/dev/null | grep -q "P"
}

reto5() {
    # Verificar que el shell de practicante es /bin/sh
    grep practicante /etc/passwd | grep -q "/bin/sh"
}

reto6() {
    # Verificar que el directorio home existe y tiene ownership correcto
    [ -d "/home/practicante" ]
    ls -la /home/practicante | grep -q "practicante"
}

reto7() {
    # Verificar que el archivo tiene el propietario correcto
    [ -f "/tmp/archivo_practicante.txt" ]
    ls -la /tmp/archivo_practicante.txt | grep -q "practicante"
}

reto8() {
    # Verificar que el directorio tiene permisos 755
    [ -d "/tmp/proyecto" ]
    permisos=$(stat -c "%a" /tmp/proyecto 2>/dev/null)
    [ "$permisos" = "755" ]
}

reto9() {
    # Verificar que practicante fue eliminado
    ! id practicante >/dev/null 2>&1
}

reto10() {
    # Verificar que el grupo desarrolladores fue eliminado
    ! getent group desarrolladores >/dev/null 2>&1
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Crear usuario"
    "Crear grupo"
    "Agregar usuario a grupo"
    "Cambiar contrasena"
    "Cambiar shell por defecto"
    "Crear directorio home"
    "Cambiar ownership"
    "Configurar permisos"
    "Eliminar usuario"
    "Limpiar usuario y grupo"
)

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
