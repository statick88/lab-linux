#!/bin/bash
# Unit IX: Web Server — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-IX"
TOTAL_RETOS=10

reto1() {
    nginx -v 2>&1 | grep -qi "nginx"
}

reto2() {
    sudo nginx -t 2>/dev/null || true
    sudo nginx 2>/dev/null || sudo service nginx start 2>/dev/null || true
    output=$(curl -s http://localhost 2>/dev/null)
    [ -n "$output" ]
}

reto3() {
    output=$(cat /etc/nginx/nginx.conf 2>/dev/null)
    echo "$output" | grep -q "server\|events\|http"
}

reto4() {
    sudo mkdir -p /var/www/html
    sudo tee /var/www/html/index.html > /dev/null << 'HTML'
<!DOCTYPE html><html><body><h1>Test Page</h1></body></html>
HTML
    output=$(curl -s http://localhost 2>/dev/null)
    echo "$output" | grep -qi "test\|html\|h1"
}

reto5() {
    output=$(ls /etc/nginx/sites-available/ 2>/dev/null)
    [ -n "$output" ]
}

reto6() {
    output=$(ls /var/log/nginx/ 2>/dev/null)
    echo "$output" | grep -q "access\|error"
}

reto7() {
    output=$(ls /etc/nginx/sites-enabled/ 2>/dev/null)
    [ -n "$output" ]
}

reto8() {
    output=$(sudo nginx -t 2>&1)
    echo "$output" | grep -qi "successful\|ok\|syntax"
}

reto9() {
    sudo nginx -s reload 2>/dev/null || true
    output=$(sudo nginx -t 2>&1)
    echo "$output" | grep -qi "successful\|ok\|syntax"
}

reto10() {
    sudo nginx -s stop 2>/dev/null || sudo service nginx stop 2>/dev/null || true
    sleep 1
    output=$(pgrep nginx 2>/dev/null || true)
    [ -z "$output" ]
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Verificar nginx"
    "Iniciar nginx"
    "Ver configuracion"
    "Crear pagina personalizada"
    "Configurar virtual host"
    "Ver logs de nginx"
    "Verificar sitios activos"
    "Probar configuracion"
    "Recargar nginx"
    "Detener nginx"
)

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
