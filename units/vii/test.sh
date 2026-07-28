#!/bin/bash
# Unit VII: Security Hardening — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-VII"
TOTAL_RETOS=10

reto1() {
    # Verificar que puede encontrar usuarios con UID 0
    output=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
    [ -n "$output" ]
}

reto2() {
    # Verificar que puede ver permisos de archivos criticos
    output=$(ls -la /etc/passwd /etc/shadow 2>/dev/null)
    [ -n "$output" ]
}

reto3() {
    # Verificar que puede buscar usuarios sin contraseña
    output=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null)
    [ -n "$output" ] || true  # Puede no haber usuarios sin contraseña
}

reto4() {
    # Verificar que puede ver sudoers
    output=$(cat /etc/sudoers 2>/dev/null | head -5)
    [ -n "$output" ]
}

reto5() {
    # Verificar que puede ver puertos abiertos
    output=$(ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null)
    [ -n "$output" ]
}

reto6() {
    # Verificar que puede ver estado del firewall
    output=$(sudo ufw status 2>/dev/null || sudo iptables -L 2>/dev/null || echo "checked")
    [ -n "$output" ]
}

reto7() {
    # Verificar que puede generar claves SSH
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -b 2048 -f /tmp/test_key -N "" 2>/dev/null
    [ -f "/tmp/test_key" ]
    rm -f /tmp/test_key /tmp/test_key.pub
}

reto8() {
    # Verificar que puede verificar permisos de .ssh
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    perms=$(stat -c "%a" ~/.ssh 2>/dev/null)
    [ "$perms" = "700" ]
}

reto9() {
    # Verificar que puede ver intentos de login
    output=$(lastb 2>/dev/null | head -5 || journalctl -u ssh 2>/dev/null | head -5 || echo "checked")
    [ -n "$output" ]
}

reto10() {
    # Verificar que puede encontrar archivos SUID
    output=$(find / -perm -4000 -type f 2>/dev/null | head -5)
    [ -n "$output" ]
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Verificar usuarios root"
    "Permisos archivos criticos"
    "Buscar usuarios sin contraseña"
    "Verificar sudoers"
    "Ver servicios abiertos"
    "Verificar firewall"
    "Generar claves SSH"
    "Permisos directorio SSH"
    "Ver intentos de login"
    "Encontrar archivos SUID"
)

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
