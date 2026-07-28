#!/bin/bash
# Unit II: Package Management — setup.sh
# Creates the environment and 10 challenges for learning apt/dpkg

set -e
source /shared/common.sh

UNIT_NAME="unit-II"
UNIT_NUM=2
TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Gestion de Paquetes"

echo -e "${CYAN}Esta unidad ensena a administrar paquetes con apt, dpkg y apt-cache.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/paquetes"
cd "$HOME/laboratorio/paquetes"

# Reto 1: Actualizar repositorios
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Actualizar los repositorios de paquetes
# Ejecuta el comando para actualizar la cache de apt
sudo apt-get update -qq
echo "Repositorios actualizados"
EOF
chmod +x reto1.sh

# Reto 2: Instalar vim
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Instalar el editor vim
sudo apt-get install -y vim
echo "vim instalado: $(which vim)"
EOF
chmod +x reto2.sh

# Reto 3: Instalar curl y tree
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Instalar curl y tree en una sola operacion
sudo apt-get install -y curl tree
echo "curl: $(which curl)"
echo "tree: $(which tree)"
EOF
chmod +x reto3.sh

# Reto 4: Consultar informacion de un paquete
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Consultar informacion del paquete nginx
apt-cache show nginx | head -20
echo "Info de nginx mostrada"
EOF
chmod +x reto4.sh

# Reto 5: Buscar paquetes
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Buscar paquetes relacionados con "editor"
apt-cache search editor
echo "Busqueda completada"
EOF
chmod +x reto5.sh

# Reto 6: Consultar estado de un paquete con dpkg
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Verificar el estado de vim con dpkg
dpkg -l vim
echo "Estado de vim consultado"
EOF
chmod +x reto6.sh

# Reto 7: Listar archivos de un paquete
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Listar archivos instalados por curl
dpkg -L curl
echo "Archivos de curl listados"
EOF
chmod +x reto7.sh

# Reto 8: Buscar que paquete provee un archivo
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Encontrar que paquete provee /usr/bin/vim
dpkg -S /usr/bin/vim
echo "Paquete propietario identificado"
EOF
chmod +x reto8.sh

# Reto 9: Eliminar un paquete sin configuracion
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Eliminar vim conservando su configuracion
sudo apt-get remove -y vim
echo "vim eliminado (configuracion conservada)"
EOF
chmod +x reto9.sh

# Reto 10: Eliminar paquete y su configuracion
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Eliminar curl y su configuracion completamente
sudo apt-get purge -y curl
echo "curl y su configuracion eliminados"
EOF
chmod +x reto10.sh

exito "Entorno de Unit II preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
