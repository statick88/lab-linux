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

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Crear usuario${NC}"
    echo ""
    echo "Crea un usuario llamado 'practicante' en el sistema."
    echo "Comandos utiles: useradd, adduser"
    echo "Verificacion: id practicante"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Crear grupo${NC}"
    echo ""
    echo "Crea un grupo llamado 'desarrolladores' en el sistema."
    echo "Comandos utiles: groupadd, addgroup"
    echo "Verificacion: getent group desarrolladores"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Agregar usuario a grupo${NC}"
    echo ""
    echo "Agrega el usuario 'practicante' al grupo 'desarrolladores'."
    echo "Comandos utiles: usermod -aG, adduser"
    echo "Verificacion: groups practicante"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Cambiar contrasena${NC}"
    echo ""
    echo "Establece una contrasena para el usuario 'practicante'."
    echo "Comandos utiles: passwd, chpasswd"
    echo "Verificacion: sudo passwd -S practicante"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Cambiar shell por defecto${NC}"
    echo ""
    echo "Cambia el shell por defecto de 'practicante' a /bin/sh."
    echo "Comandos utiles: usermod -s, chsh"
    echo "Verificacion: grep practicante /etc/passwd"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Crear directorio home${NC}"
    echo ""
    echo "Asegurate de que el directorio /home/practicante exista"
    echo "y que sea propiedad del usuario practicante."
    echo "Comandos utiles: mkdir, chown -R"
    echo "Verificacion: ls -la /home/"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Cambiar ownership${NC}"
    echo ""
    echo "Cambia el propietario del archivo /tmp/archivo_practicante.txt"
    echo "para que sea propiedad de 'practicante'."
    echo "Comandos utiles: chown, chgrp"
    echo "Verificacion: ls -la /tmp/archivo_practicante.txt"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Configurar permisos${NC}"
    echo ""
    echo "Establece los permisos del directorio /tmp/proyecto a 755"
    echo "(rwxr-xr-x)."
    echo "Comandos utiles: chmod, stat"
    echo "Verificacion: stat -c \"%a\" /tmp/proyecto"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Eliminar usuario${NC}"
    echo ""
    echo "Elimina el usuario 'practicante' del sistema."
    echo "Comandos utiles: userdel, deluser"
    echo "Verificacion: id practicante"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Limpiar usuario y grupo${NC}"
    echo ""
    echo "Elimina el grupo 'desarrolladores' del sistema."
    echo "Asegurate de que tanto el usuario como el grupo ya no existan."
    echo "Comandos utiles: groupdel, delgroup"
    echo "Verificacion: getent group desarrolladores"
    separador
}
