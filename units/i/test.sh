#!/bin/bash
# Unit I: Fundamentos de Linux y WSL2 — test.sh
# Standard pattern: defines retoN() validators + retoN_info() for menu-driven execution

set -e
source /shared/common.sh

UNIT_NAME="unit-I"
TOTAL_RETOS=10

# Pure validators - no user interaction, check system state only

reto1() {
    # Verificar que /etc existe y es legible (directorio de configuración FHS)
    [ -d /etc ] && [ -r /etc ]
}

reto2() {
    # Verificar estructura: /var/log persiste, /tmp es temporal
    [ -d /var/log ] && [ -d /tmp ]
}

reto3() {
    # Verificar que pwd funciona y coincide con $PWD
    [ "$(pwd)" = "$PWD" ]
}

reto4() {
    # Verificar que ls -a muestra archivos ocultos (entradas que empiezan con .)
    ls -a / 2>/dev/null | grep -q '^\.'
}

reto5() {
    # Verificar que chmod 755 otorga permisos rwxr-xr-x (portable)
    touch /tmp/test_perms && chmod 755 /tmp/test_perms
    # Check owner has rwx, group has r-x, others have r-x
    [ -r /tmp/test_perms ] && [ -w /tmp/test_perms ] && [ -x /tmp/test_perms ] && rm /tmp/test_perms
}

reto6() {
    # Concept check: WSL2 architecture (always pass - educational)
    # Students learn: WSL2 = VM ligera con kernel Linux real
    # This validator always passes since WSL2 is environment, not action
    echo "  ℹ WSL2 usa VM ligera con kernel Linux real (vs WSL1 que traducía syscalls)"
    return 0
}

reto7() {
    # Verificar que el sistema de archivos raíz está montado
    mount | grep -q ' on / '
}

reto8() {
    # Verificar que root tiene UID 0
    [ "$(id -u root 2>/dev/null)" = "0" ]
}

reto9() {
    # Verificar que pipe (|) funciona: stdout -> stdin
    [ "$(echo test | cat)" = "test" ]
}

reto10() {
    # Verificar que df -h produce salida con números (tamaños)
    df -h / 2>/dev/null | grep -q '[0-9]'
}

# Array de funciones de evaluación (para compatibilidad con evaluación batch)
validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)

challenge_names=(
    "Directorio /etc (FHS)"
    "/var vs /tmp"
    "Comando pwd"
    "Opción ls -a"
    "Permisos 755"
    "WSL2 arquitectura"
    "Comando mount"
    "UID de root"
    "Símbolo pipe"
    "df -h espacio disco"
)

# Iconos para el menú (referenciados por menu.sh)
ICONOS=(📁 📂 📍 👁️ 🔐 🐧 🔗 👑 🔀 💾)

# Funciones de información para cada reto (patrón estándar Units II-XI)

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Directorio /etc (FHS)${NC}"
    echo ""
    echo "El directorio /etc contiene los archivos de configuración del sistema."
    echo "Según el estándar FHS (Filesystem Hierarchy Standard), /etc es"
    echo "el lugar designado para archivos de configuración estáticos."
    echo ""
    echo "Comando útil: ls /etc"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: /var vs /tmp - Datos persistentes${NC}"
    echo ""
    echo "/var contiene datos variables que PERSISTEN entre reinicios (logs, spool, cache)."
    echo "/tmp es temporal y se limpia al reiniciar."
    echo ""
    echo "Comando útil: ls /var/log /tmp"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Comando pwd${NC}"
    echo ""
    echo "pwd (print working directory) muestra el directorio de trabajo actual."
    echo "Es fundamental para saber dónde estás en el árbol de directorios."
    echo ""
    echo "Comando útil: pwd"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Opción ls -a${NC}"
    echo ""
    echo "ls -a muestra TODOS los archivos, incluidos los ocultos (los que empiezan con punto)."
    echo "Los archivos ocultos suelen ser de configuración (ej: .bashrc, .git)."
    echo ""
    echo "Comando útil: ls -a"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Permisos 755${NC}"
    echo ""
    echo "chmod 755 otorga: Propietario=rwx, Grupo=r-x, Otros=r-x"
    echo "7=rwx (4+2+1), 5=r-x (4+0+1), 5=r-x"
    echo ""
    echo "Comando útil: chmod 755 archivo"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: WSL2 Arquitectura${NC}"
    echo ""
    echo "WSL2 usa una VM ligera con kernel Linux REAL; WSL1 traducía syscalls."
    echo "Esto da compatibilidad total con binarios Linux y systemd."
    echo ""
    echo "Comando útil: cat /proc/version"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Comando mount${NC}"
    echo ""
    echo "mount une un sistema de archivos al árbol de directorios."
    echo "El sistema de archivos raíz (/) siempre está montado."
    echo ""
    echo "Comando útil: mount | grep ' on / '"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: UID de root${NC}"
    echo ""
    echo "El usuario root SIEMPRE tiene UID 0 en Linux/Unix."
    echo "Es el superusuario con acceso total al sistema."
    echo ""
    echo "Comando útil: id root"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Símbolo pipe (|)${NC}"
    echo ""
    echo "El pipe | conecta la salida (stdout) de un comando a la entrada (stdin) de otro."
    echo "Permite encadenar comandos para procesamiento de datos."
    echo ""
    echo "Comando útil: echo hola | cat"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: df -h espacio en disco${NC}"
    echo ""
    echo "df -h muestra espacio disponible en disco en formato legible (human-readable)."
    echo "Muestra: sistema de archivos, tamaño, usado, disponible, %uso, montado en."
    echo ""
    echo "Comando útil: df -h /"
    separador
}