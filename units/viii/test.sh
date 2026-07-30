#!/bin/bash
# Unit VIII: Docker Containers — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-VIII"
TOTAL_RETOS=10

reto1() {
    # Verificar que Docker esta instalado
    docker --version 2>/dev/null | grep -q "Docker"
}

reto2() {
    # Verificar que puede ejecutar contenedor basico
    output=$(docker run --rm ubuntu:latest echo "test" 2>/dev/null)
    [ "$output" = "test" ]
}

reto3() {
    # Verificar que puede listar contenedores
    docker run -d --name test_ps ubuntu:latest sleep 300 2>/dev/null
    output=$(docker ps 2>/dev/null)
    docker stop test_ps 2>/dev/null && docker rm test_ps 2>/dev/null
    echo "$output" | grep -q "test_ps\|CONTAINER ID"
}

reto4() {
    # Verificar que puede ejecutar comandos en contenedor
    output=$(docker run --rm ubuntu:latest echo "exec_test" 2>/dev/null)
    [ "$output" = "exec_test" ]
}

reto5() {
    # Verificar que puede ver logs
    docker run -d --name test_logs ubuntu:latest bash -c "echo logtest" 2>/dev/null
    sleep 2
    output=$(docker logs test_logs 2>/dev/null)
    docker stop test_logs 2>/dev/null && docker rm test_logs 2>/dev/null
    echo "$output" | grep -q "logtest"
}

reto6() {
    # Verificar que puede inspeccionar contenedor
    docker run -d --name test_inspect ubuntu:latest sleep 300 2>/dev/null
    output=$(docker inspect test_inspect 2>/dev/null | head -5)
    docker stop test_inspect 2>/dev/null && docker rm test_inspect 2>/dev/null
    [ -n "$output" ]
}

reto7() {
    # Verificar que puede crear redes
    docker network create test_network 2>/dev/null
    output=$(docker network ls 2>/dev/null)
    docker network rm test_network 2>/dev/null
    echo "$output" | grep -q "test_network"
}

reto8() {
    # Verificar que puede crear volumenes
    docker volume create test_volume 2>/dev/null
    output=$(docker volume ls 2>/dev/null)
    docker volume rm test_volume 2>/dev/null
    echo "$output" | grep -q "test_volume"
}

reto9() {
    # Verificar que puede crear imagen
    mkdir -p /tmp/build_test
    cat > /tmp/build_test/Dockerfile << 'EOF'
FROM ubuntu:latest
RUN echo "test"
CMD ["echo", "image_test"]
EOF
    docker build -t test_image /tmp/build_test/ 2>/dev/null
    output=$(docker run --rm test_image 2>/dev/null)
    docker rmi test_image 2>/dev/null
    rm -rf /tmp/build_test
    [ "$output" = "image_test" ]
}

reto10() {
    # Verificar que puede limpiar recursos
    docker ps -aq 2>/dev/null | xargs docker rm -f 2>/dev/null || true
    docker volume ls -q 2>/dev/null | xargs docker volume rm 2>/dev/null || true
    output=$(docker ps -a 2>/dev/null)
    [ -n "$output" ]
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Verificar Docker"
    "Ejecutar contenedor basico"
    "Listar contenedores"
    "Ejecutar comandos en contenedor"
    "Ver logs de contenedor"
    "Inspeccionar contenedor"
    "Gestionar redes"
    "Gestionar volumenes"
    "Crear imagen con Dockerfile"
    "Limpiar recursos"
)

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Verificar Docker${NC}"
    echo ""
    echo "Verifica que Docker esta instalado correctamente en tu sistema."
    echo ""
    echo "Comandos utiles:"
    echo "  docker --version    -- Muestra la version de Docker instalada"
    echo "  docker info         -- Muestra informacion general del demonio Docker"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Ejecutar contenedor basico${NC}"
    echo ""
    echo "Ejecuta un contenedor basico de Ubuntu y verifica que funciona."
    echo ""
    echo "Comandos utiles:"
    echo "  docker run --rm ubuntu:latest echo 'hola'  -- Ejecuta un comando en un contenedor temporal"
    echo "  docker ps                                  -- Lista contenedores en ejecucion"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Listar contenedores${NC}"
    echo ""
    echo "Crea un contenedor en segundo plano y listalo con docker ps."
    echo "El contenedor debe aparecer en la lista de contenedores activos."
    echo ""
    echo "Comandos utiles:"
    echo "  docker run -d --name mi_contenedor ubuntu:latest sleep 300"
    echo "  docker ps                        -- Lista contenedores en ejecucion"
    echo "  docker stop mi_contenedor        -- Detiene un contenedor"
    echo "  docker rm mi_contenedor          -- Elimina un contenedor"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Ejecutar comandos en contenedor${NC}"
    echo ""
    echo "Ejecuta un comando dentro de un contenedor en ejecucion."
    echo "Demuestra que puedes interactuar con un contenedor activo."
    echo ""
    echo "Comandos utiles:"
    echo "  docker exec mi_contenedor ls           -- Ejecuta un comando en un contenedor activo"
    echo "  docker exec mi_contenedor bash          -- Abre una sesion bash en el contenedor"
    echo "  docker run --rm ubuntu:latest echo test -- Ejecuta un comando directamente"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Ver logs de contenedor${NC}"
    echo ""
    echo "Genera y consulta los logs de un contenedor."
    echo "El contenedor debe producir algun mensaje que puedas ver con docker logs."
    echo ""
    echo "Comandos utiles:"
    echo "  docker run -d --name log_test ubuntu:latest bash -c 'echo hola'"
    echo "  docker logs log_test             -- Muestra los logs del contenedor"
    echo "  docker logs -f log_test          -- Sigue los logs en tiempo real"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Inspeccionar contenedor${NC}"
    echo ""
    echo "Usa docker inspect para obtener informacion detallada de un contenedor."
    echo "Debes poder ver la configuracion de red, volumenes y estado."
    echo ""
    echo "Comandos utiles:"
    echo "  docker inspect mi_contenedor              -- Muestra toda la configuracion JSON"
    echo "  docker inspect --format '{{.State.Status}}' mi_contenedor  -- Campo especifico"
    echo "  docker inspect --format '{{.NetworkSettings.IPAddress}}' mi_contenedor"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Gestionar redes${NC}"
    echo ""
    echo "Crea una red Docker personalizada y listalas."
    echo "Demuestra que puedes administrar redes de contenedores."
    echo ""
    echo "Comandos utiles:"
    echo "  docker network create mi_red     -- Crea una nueva red"
    echo "  docker network ls                -- Lista todas las redes"
    echo "  docker network inspect mi_red    -- Detalles de una red"
    echo "  docker network rm mi_red         -- Elimina una red"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Gestionar volumenes${NC}"
    echo ""
    echo "Crea un volumen Docker y listalos."
    echo "Los volumenes permiten persistir datos mas alla del ciclo de vida de los contenedores."
    echo ""
    echo "Comandos utiles:"
    echo "  docker volume create mi_volumen   -- Crea un nuevo volumen"
    echo "  docker volume ls                  -- Lista todos los volumenes"
    echo "  docker volume inspect mi_volumen  -- Detalles de un volumen"
    echo "  docker volume rm mi_volumen       -- Elimina un volumen"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Crear imagen con Dockerfile${NC}"
    echo ""
    echo "Crea un Dockerfile y construye una imagen personalizada."
    echo "El Dockerfile debe definir al menos FROM, RUN y CMD."
    echo ""
    echo "Comandos utiles:"
    echo "  touch Dockerfile                              -- Crea el archivo Dockerfile"
    echo "  docker build -t mi_imagen .                   -- Construye la imagen desde el Dockerfile"
    echo "  docker run --rm mi_imagen                     -- Ejecuta un contenedor con la imagen"
    echo "  docker images                                 -- Lista las imagenes disponibles"
    echo ""
    echo "Estructura minima de un Dockerfile:"
    echo "  FROM ubuntu:latest"
    echo "  RUN echo 'Hola Mundo'"
    echo '  CMD ["echo", "imagen_creada"]'
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Limpiar recursos${NC}"
    echo ""
    echo "Limpia todos los recursos Docker utilizados: contenedores, imagenes y volumenes."
    echo "Demuestra que puedes liberar espacio en tu sistema."
    echo ""
    echo "Comandos utiles:"
    echo "  docker ps -aq | xargs docker rm -f    -- Elimina todos los contenedores"
    echo "  docker images -q | xargs docker rmi    -- Elimina todas las imagenes"
    echo "  docker volume ls -q | xargs docker volume rm  -- Elimina todos los volumenes"
    echo "  docker system prune -a                 -- Limpia todo de una vez"
    separador
}
