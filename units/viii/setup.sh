#!/bin/bash
# Unit VIII: Docker Containers — setup.sh
# Creates the environment and 10 challenges for learning Docker

set -e
source /shared/common.sh

UNIT_NAME="unit-VIII"
UNIT_NUM=8
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Contenedores Docker"

echo -e "${CYAN}Esta unidad ensena a gestionar contenedores Docker.${RESET}"
echo -e "${AMARILLO}Usamos Docker-in-Docker (DinD) para experimentar.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/docker"
cd "$HOME/laboratorio/docker"

# Reto 1: Verificar Docker
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Verificar que Docker esta instalado y funcionando
docker --version
docker info | head -10
EOF
chmod +x reto1.sh

# Reto 2: Ejecutar un contenedor basico
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Ejecutar contenedor Ubuntu que imprima mensaje
docker run --rm ubuntu:latest echo "Hola desde Docker"
EOF
chmod +x reto2.sh

# Reto 3: Listar contenedores
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Ejecutar contenedor en background y listarlo
docker run -d --name test_container ubuntu:latest sleep 300
docker ps
docker ps -a
EOF
chmod +x reto3.sh

# Reto 4: Ejecutar comandos en contenedor
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Ejecutar comandos dentro de un contenedor
docker run --rm ubuntu:latest bash -c "apt-get update && apt-get install -y curl && curl --version"
EOF
chmod +x reto4.sh

# Reto 5: Ver logs de contenedor
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Ver logs de un contenedor
docker run -d --name log_container ubuntu:latest bash -c "echo 'Inicio'; sleep 1; echo 'Proceso'; sleep 1; echo 'Fin'"
sleep 3
docker logs log_container
EOF
chmod +x reto5.sh

# Reto 6: Inspeccionar contenedor
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Inspeccionar detalles de un contenedor
docker run -d --name inspect_container ubuntu:latest sleep 300
docker inspect inspect_container | head -30
EOF
chmod +x reto6.sh

# Reto 7: Gestionar redes
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Crear y listar redes Docker
docker network create mi_red 2>/dev/null || true
docker network ls
docker network inspect mi_red | head -20
EOF
chmod +x reto7.sh

# Reto 8: Gestionar volumenes
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Crear y usar un volumen
docker volume create mi_volumen 2>/dev/null || true
docker volume ls
docker run --rm -v mi_volumen:/datos ubuntu:latest bash -c "echo 'Dato guardado' > /datos/archivo.txt"
docker volume inspect mi_volumen | head -10
EOF
chmod +x reto8.sh

# Reto 9: Crear imagen con Dockerfile
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Crear una imagen personalizada
cat > /tmp/Dockerfile.custom << 'Dockerfile'
FROM ubuntu:latest
RUN apt-get update && apt-get install -y nano
CMD ["echo", "Imagen personalizada creada"]
Dockerfile
docker build -t mi_imagen -f /tmp/Dockerfile.custom /tmp/
docker run --rm mi_imagen
EOF
chmod +x reto9.sh

# Reto 10: Limpiar recursos
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Limpiar contenedores, imagenes y volumenes detenidos
docker stop $(docker ps -q) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker volume rm $(docker volume ls -q) 2>/dev/null || true
docker network rm mi_red 2>/dev/null || true
echo "Recursos limpiados"
docker ps -a
EOF
chmod +x reto10.sh

exito "Entorno de Unit VIII preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
