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

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Verificar nginx${NC}"
    echo ""
    echo "Verifica que nginx este instalado en el sistema."
    echo "Comando util: nginx -v"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Iniciar nginx${NC}"
    echo ""
    echo "Inicia el servidor nginx para que este ejecutandose."
    echo "Comando util: sudo nginx o sudo service nginx start"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Ver configuracion${NC}"
    echo ""
    echo "Explora el archivo de configuracion principal de nginx."
    echo "Comando util: cat /etc/nginx/nginx.conf"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Crear pagina personalizada${NC}"
    echo ""
    echo "Crea un archivo index.html en /var/www/html/ con contenido propio."
    echo "Comando util: sudo nano /var/www/html/index.html"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Configurar virtual host${NC}"
    echo ""
    echo "Crea un archivo de configuracion de virtual host en sites-available."
    echo "Comando util: sudo nano /etc/nginx/sites-available/mi-sitio"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Ver logs de nginx${NC}"
    echo ""
    echo "Verifica que existan los logs de acceso y error de nginx."
    echo "Comando util: ls /var/log/nginx/"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Verificar sitios activos${NC}"
    echo ""
    echo "Activa un sitio creando un enlace simbolico en sites-enabled."
    echo "Comando util: sudo ln -s /etc/nginx/sites-available/mi-sitio /etc/nginx/sites-enabled/"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Probar configuracion${NC}"
    echo ""
    echo "Prueba que la configuracion de nginx sea correcta antes de recargar."
    echo "Comando util: sudo nginx -t"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Recargar nginx${NC}"
    echo ""
    echo "Recarga nginx para aplicar los cambios sin detener el servicio."
    echo "Comando util: sudo nginx -s reload"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Detener nginx${NC}"
    echo ""
    echo "Detiene completamente el servidor nginx."
    echo "Comando util: sudo nginx -s stop o sudo service nginx stop"
    separador
}
