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
    cat > /tmp/test_dockerfile << 'EOF'
FROM ubuntu:latest
RUN echo "test"
CMD ["echo", "image_test"]
EOF
    docker build -t test_image /tmp/ 2>/dev/null
    output=$(docker run --rm test_image 2>/dev/null)
    docker rmi test_image 2>/dev/null
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

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
