#!/bin/bash
# Unit VII: Security Hardening — setup.sh
# Creates the environment and 10 challenges for learning security

set -e
source /shared/common.sh

UNIT_NAME="unit-VII"
UNIT_NUM=7
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Seguridad del Sistema"

echo -e "${CYAN}Esta unidad ensena a proteger un servidor Linux.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/security"
cd "$HOME/laboratorio/security"

# Reto 1: Verificar usuarios del sistema
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Verificar usuarios con UID 0 (solo root debe tenerlo)
awk -F: '$3 == 0 {print $1}' /etc/passwd
EOF
chmod +x reto1.sh

# Reto 2: Verificar permisos de archivos criticos
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Verificar permisos de /etc/passwd y /etc/shadow
ls -la /etc/passwd /etc/shadow
stat -c "%a %U %G" /etc/passwd /etc/shadow
EOF
chmod +x reto2.sh

# Reto 3: Verificar usuarios sin contraseña
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Buscar usuarios con campos de contraseña vacios
awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow
EOF
chmod +x reto3.sh

# Reto 4: Verificar sudoers
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Verificar el archivo sudoers
cat /etc/sudoers 2>/dev/null | grep -v "^#" | grep -v "^$" | head -20
EOF
chmod +x reto4.sh

# Reto 5: Verificar servicios abiertos
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Verificar puertos abiertos
ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null
EOF
chmod +x reto5.sh

# Reto 6: Verificar firewall
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Verificar estado del firewall
sudo ufw status 2>/dev/null || sudo iptables -L 2>/dev/null || echo "Firewall no configurado"
EOF
chmod +x reto6.sh

# Reto 7: Verificar clave SSH
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Generar par de claves SSH si no existe
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" 2>/dev/null
    echo "Clave SSH generada"
else
    echo "Clave SSH ya existe"
fi
ls -la ~/.ssh/id_rsa.pub
EOF
chmod +x reto7.sh

# Reto 8: Verificar permisos de directorio SSH
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Verificar permisos del directorio .ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ls -la ~ | grep ".ssh"
stat -c "%a" ~/.ssh
EOF
chmod +x reto8.sh

# Reto 9: Verificar intentos de login fallidos
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Ver intentos de login fallidos
lastb 2>/dev/null | head -10 || journalctl -u ssh 2>/dev/null | grep -i "fail" | tail -10
EOF
chmod +x reto9.sh

# Reto 10: Verificar archivos SUID
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Encontrar archivos con permisos SUID
find / -perm -4000 -type f 2>/dev/null | head -15
EOF
chmod +x reto10.sh

exito "Entorno de Unit VII preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
