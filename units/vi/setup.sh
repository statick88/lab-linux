#!/bin/bash
# Unit VI: Storage Management — setup.sh
# Creates the environment and 10 challenges for learning storage

set -e
source /shared/common.sh

UNIT_NAME="unit-VI"
UNIT_NUM=6
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Gestion de Almacenamiento"

echo -e "${CYAN}Esta unidad ensena a gestionar discos, particiones y almacenamiento.${RESET}"
echo -e "${AMARILLO}Usamos dispositivos de bucle (loop) para simular discos reales.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/storage"
cd "$HOME/laboratorio/storage"

# Reto 1: Ver informacion de discos
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Listar todos los dispositivos de bloque
lsblk
EOF
chmod +x reto1.sh

# Reto 2: Ver informacion de discos con fdisk
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Ver tabla de particiones
sudo fdisk -l 2>/dev/null | head -20
EOF
chmod +x reto2.sh

# Reto 3: Crear un archivo de 10MB para simular un disco
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Crear archivo de 10MB para usar como disco virtual
dd if=/dev/zero of=~/laboratorio/storage/disco_virtual.img bs=1M count=10 2>/dev/null
ls -lh ~/laboratorio/storage/disco_virtual.img
EOF
chmod +x reto3.sh

# Reto 4: Formatear el disco virtual
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Formatear el disco virtual con ext4
sudo mkfs.ext4 ~/laboratorio/storage/disco_virtual.img 2>/dev/null
echo "Disco formateado con ext4"
EOF
chmod +x reto4.sh

# Reto 5: Montar el disco virtual
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Montar el disco virtual en un directorio
mkdir -p ~/laboratorio/storage/montaje
sudo mount ~/laboratorio/storage/disco_virtual.img ~/laboratorio/storage/montaje
echo "Disco montado en ~/laboratorio/storage/montaje"
df -h ~/laboratorio/storage/montaje
EOF
chmod +x reto5.sh

# Reto 6: Copiar archivos al disco montado
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Copiar archivos al disco virtual montado
echo "Archivo de prueba" > ~/laboratorio/storage/montaje/archivo_prueba.txt
cp /etc/hostname ~/laboratorio/storage/montaje/
ls -la ~/laboratorio/storage/montaje/
EOF
chmod +x reto6.sh

# Reto 7: Desmontar el disco
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Desmontar el disco virtual
sudo umount ~/laboratorio/storage/montaje 2>/dev/null
echo "Disco desmontado"
ls ~/laboratorio/storage/montaje/
EOF
chmod +x reto7.sh

# Reto 8: Ver espacio en disco
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Verificar espacio en disco
df -h
EOF
chmod +x reto8.sh

# Reto 9: Verificar tamaño de directorio
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Medir el tamaño del directorio home
du -sh ~/laboratorio/
EOF
chmod +x reto9.sh

# Reto 10: Limpieza del disco virtual
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Eliminar el disco virtual
sudo umount ~/laboratorio/storage/montaje 2>/dev/null || true
rm -f ~/laboratorio/storage/disco_virtual.img
echo "Disco virtual eliminado"
ls -la ~/laboratorio/storage/
EOF
chmod +x reto10.sh

exito "Entorno de Unit VI preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
