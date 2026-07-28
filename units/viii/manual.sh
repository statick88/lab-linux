#!/bin/bash
# Unit VIII: Docker Containers — manual.sh
# Interactive guide for learning Docker

source /shared/common.sh

UNIT_NAME="unit-VIII"
banner_unidad 8 "Contenedores Docker"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Contenedores Docker                               ║
║  Aprende a crear, gestionar y orquestar contenedores       ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  Docker permite empaquetar aplicaciones con sus dependencias
  en contenedores portables y aislados.

  • Imagen — Plantilla de solo lectura
  • Contenedor — Instancia en ejecucion de una imagen
  • Dockerfile — Receta para construir imagenes
  • Volumen — Almacenamiento persistente
  • Red — Comunicacion entre contenedores

🔧 COMANDOS ESENCIALES
══════════════════════════

  Imagenes
  ─────────
  docker pull imagen          # Descargar imagen
  docker images               # Listar imagenes locales
  docker rmi imagen           # Eliminar imagen
  docker build -t nombre .    # Construir desde Dockerfile
  docker tag imagen nueva     # Renombrar imagen
  docker push imagen          # Subir a registro

  Contenedores
  ──────────────
  docker run -d --name nom imagen  # Ejecutar en background
  docker run --rm imagen           # Ejecutar y eliminar al salir
  docker run -it imagen bash       # Ejecutar con terminal interactiva
  docker ps                        # Ver contenedores activos
  docker ps -a                     # Ver todos los contenedores
  docker stop nombre               # Detener contenedor
  docker rm nombre                 # Eliminar contenedor
  docker exec -it nombre bash      # Entrar a contenedor corriendo

  Dockerfile
  ────────────
  FROM ubuntu:latest        # Imagen base
  RUN apt-get update        # Ejecutar comandos
  COPY archivo /ruta        # Copiar archivos
  WORKDIR /ruta             # Directorio de trabajo
  EXPOSE 80                 # Exponer puerto
  CMD ["comando"]           # Comando por defecto

  Redes y volumenes
  ───────────────────
  docker network create red       # Crear red
  docker network ls               # Listar redes
  docker volume create volumen    # Crear volumen
  docker volume ls                # Listar volumenes
  docker run -v vol:/ruta img     # Montar volumen

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/docker/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  # Ejecutar Ubuntu con terminal
  docker run -it ubuntu:latest bash

  # Ejecutar contenedor web
  docker run -d -p 8080:80 nginx:latest

  # Ver logs en tiempo real
  docker logs -f nombre

  # Copiar archivos desde contenedor
  docker cp nombre:/ruta/archivo.txt .

  # Ver uso de recursos
  docker stats

📌 DOCKERFILE EJEMPLO
═══════════════════════

  # Crear archivo Dockerfile
  cat > Dockerfile << 'DOCKERFILE'
  FROM python:3.9-slim
  WORKDIR /app
  COPY requirements.txt .
  RUN pip install -r requirements.txt
  COPY . .
  CMD ["python", "app.py"]
  DOCKERFILE

  # Construir y ejecutar
  docker build -t mi_app .
  docker run -p 5000:5000 mi_app

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
