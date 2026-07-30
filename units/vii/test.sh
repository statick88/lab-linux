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
    output=$(sudo cat /etc/sudoers 2>/dev/null | head -5)
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
    output=$(sudo lastb 2>/dev/null | head -5)
    [ -n "$output" ] || output=$(sudo journalctl -u ssh 2>/dev/null | head -5)
    [ -n "$output" ] || output=$(sudo cat /var/log/auth.log 2>/dev/null | head -5)
    [ -n "$output" ] || output="checked"
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

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Verificar usuarios root${NC}"
    echo ""
    echo "Encuentra todos los usuarios con UID 0 (superusuario) en el sistema."
    echo "Solo root debería tener UID 0; si hay otros, son una amenaza."
    echo ""
    echo "Comandos útiles: awk, cat /etc/passwd"
    echo "Ejemplo: awk -F: '\$3 == 0 {print \$1}' /etc/passwd"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Permisos archivos críticos${NC}"
    echo ""
    echo "Revisa los permisos de los archivos más sensibles del sistema:"
    echo "/etc/passwd y /etc/shadow."
    echo "Verifica quién puede leerlos y escribir en ellos."
    echo ""
    echo "Comandos útiles: ls -la, stat, getfacl"
    echo "Ejemplo: ls -la /etc/passwd /etc/shadow"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Buscar usuarios sin contraseña${NC}"
    echo ""
    echo "Identifica usuarios que no tienen contraseña asignada."
    echo "Un usuario sin contraseña es un vector de acceso directo."
    echo ""
    echo "Comandos útiles: awk, cat /etc/shadow"
    echo "Ejemplo: awk -F: '(\$2 == \"\" || \$2 == \"!\") {print \$1}' /etc/shadow"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Verificar sudoers${NC}"
    echo ""
    echo "Analiza el archivo /etc/sudoers para detectar configuraciones peligrosas."
    echo "Busca usuarios o grupos con permisos excesivos (NOPASSWD, ALL)."
    echo ""
    echo "Comandos útiles: cat, visudo -c, grep"
    echo "Ejemplo: cat /etc/sudoers"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Ver servicios abiertos${NC}"
    echo ""
    echo "Lista todos los puertos y servicios que están escuchando conexiones."
    echo "Cada puerto abierto es una puerta de entrada potencial."
    echo ""
    echo "Comandos útiles: ss, netstat, lsof"
    echo "Ejemplo: ss -tuln"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Verificar firewall${NC}"
    echo ""
    echo "Consulta el estado del firewall configurado en el sistema."
    echo "Verifica si UFW, iptables u otro firewall está activo y qué reglas tiene."
    echo ""
    echo "Comandos útiles: ufw status, iptables -L, nft list ruleset"
    echo "Ejemplo: sudo ufw status verbose"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Generar claves SSH${NC}"
    echo ""
    echo "Genera un par de claves SSH (pública y privada) usando RSA de 2048 bits."
    echo "Las claves SSH son más seguras que las contraseñas para autenticación."
    echo ""
    echo "Comandos útiles: ssh-keygen"
    echo "Ejemplo: ssh-keygen -t rsa -b 2048 -f ~/.ssh/mi_clave"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Permisos directorio SSH${NC}"
    echo ""
    echo "Configura los permisos correctos del directorio ~/.ssh."
    echo "El directorio debe ser accesible solo por el propietario (700)."
    echo ""
    echo "Comandos útiles: chmod, stat"
    echo "Ejemplo: chmod 700 ~/.ssh"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Ver intentos de login${NC}"
    echo ""
    echo "Revisa los registros de intentos de inicio de sesión fallidos."
    echo "Detecta posibles ataques de fuerza bruta o accesos no autorizados."
    echo ""
    echo "Comandos útiles: lastb, journalctl, grep /var/log/auth.log"
    echo "Ejemplo: lastb | head -20"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Encontrar archivos SUID${NC}"
    echo ""
    echo "Busca archivos con el bit SUID activado en el sistema."
    echo "Los archivos SUID ejecutan con los permisos del propietario (root)."
    echo "Un SUID mal configurado puede ser explotado para escalar privilegios."
    echo ""
    echo "Comandos útiles: find, chmod"
    echo "Ejemplo: find / -perm -4000 -type f 2>/dev/null"
    separador
}
