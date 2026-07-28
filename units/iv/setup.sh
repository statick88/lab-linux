#!/bin/bash
# Unit IV: User Management — setup.sh
# Creates the environment and 10 challenges for learning user/group administration

set -e
source /shared/common.sh

UNIT_NAME="unit-IV"
UNIT_NUM=4
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Gestion de Usuarios"

echo -e "${CYAN}Esta unidad ensena a administrar usuarios, grupos y permisos.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/usuarios"
cd "$HOME/laboratorio/usuarios"

# Reto 1: Crear un usuario
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Crear un usuario llamado "practicante"
sudo useradd -m -s /bin/bash practicante
echo "Usuario practicante creado"
id practicante
EOF
chmod +x reto1.sh

# Reto 2: Crear un grupo
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Crear un grupo llamado "desarrolladores"
sudo groupadd desarrolladores
echo "Grupo desarrolladores creado"
getent group desarrolladores
EOF
chmod +x reto2.sh

# Reto 3: Agregar usuario a un grupo
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Agregar practicante al grupo desarrolladores
sudo usermod -aG desarrolladores practicante
echo "practicante agregado a desarrolladores"
groups practicante
EOF
chmod +x reto3.sh

# Reto 4: Cambiar contrasena
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Establecer una contrasena para practicante
echo "practicante:Linux2024" | sudo chpasswd
echo "Contrasena establecida"
passwd -S practicante
EOF
chmod +x reto4.sh

# Reto 5: Cambiar el shell por defecto
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Cambiar el shell de practicante a /bin/sh
sudo usermod -s /bin/sh practicante
echo "Shell cambiado a /bin/sh"
grep practicante /etc/passwd
EOF
chmod +x reto5.sh

# Reto 6: Crear directorio home manualmente
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Crear directorio home para practicante si no existe
if [ ! -d "/home/practicante" ]; then
    sudo mkdir -p /home/practicante
    sudo chown practicante:practicante /home/practicante
    echo "Directorio home creado"
else
    echo "Directorio home ya existe"
fi
ls -la /home/practicante
EOF
chmod +x reto6.sh

# Reto 7: Cambiar ownership de un archivo
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Crear un archivo y cambiar su propietario a practicante
sudo touch /tmp/archivo_practicante.txt
sudo chown practicante:desarrolladores /tmp/archivo_practicante.txt
echo "Propietario cambiado"
ls -la /tmp/archivo_practicante.txt
EOF
chmod +x reto7.sh

# Reto 8: Configurar permisos basicos
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Establecer permisos 755 en un directorio
sudo mkdir -p /tmp/proyecto
sudo chmod 755 /tmp/proyecto
echo "Permisos 755 establecidos"
ls -la /tmp/proyecto
EOF
chmod +x reto8.sh

# Reto 9: Eliminar un usuario
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Eliminar el usuario practicante (conservando home)
sudo userdel practicante
echo "Usuario eliminado (home conservado)"
id practicante 2>/dev/null || echo "Usuario no encontrado"
EOF
chmod +x reto9.sh

# Reto 10: Limpiar usuario y grupo
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Eliminar completamente usuario y grupo
sudo userdel -r practicante 2>/dev/null || true
sudo groupdel desarrolladores 2>/dev/null || echo "Grupo no encontrado"
echo "Limpieza completada"
getent group desarrolladores || echo "Grupo desarrolladores eliminado"
EOF
chmod +x reto10.sh

exito "Entorno de Unit IV preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
