#!/bin/bash
# Unit IX: Web Server — setup.sh
# Creates the environment and 10 challenges for learning nginx

set -e
source /shared/common.sh

UNIT_NAME="unit-IX"
UNIT_NUM=9
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Servidor Web"

echo -e "${CYAN}Esta unidad ensena a configurar y administrar un servidor web nginx.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/web"
cd "$HOME/laboratorio/web"

# Reto 1: Verificar nginx
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Verificar que nginx esta instalado
nginx -v 2>&1
which nginx
EOF
chmod +x reto1.sh

# Reto 2: Iniciar nginx
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Iniciar el servidor web
sudo nginx 2>/dev/null || sudo service nginx start 2>/dev/null
echo "Nginx iniciado"
curl -s http://localhost | head -5
EOF
chmod +x reto2.sh

# Reto 3: Ver configuracion de nginx
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Ver la configuracion principal de nginx
cat /etc/nginx/nginx.conf | head -30
EOF
chmod +x reto3.sh

# Reto 4: Crear pagina personalizada
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Crear una pagina web personalizada
sudo mkdir -p /var/www/html
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Mi Servidor</title></head>
<body><h1>Hola desde nginx</h1></body>
</html>
HTML
echo "Pagina creada"
curl -s http://localhost | head -5
EOF
chmod +x reto4.sh

# Reto 5: Configurar virtual host
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Crear configuracion de virtual host
sudo mkdir -p /var/www/misitio
cat > /var/www/misitio/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Mi Sitio</title></head>
<body><h1>Bienvenido a mi sitio</h1></body>
</html>
HTML
sudo tee /etc/nginx/sites-available/misitio > /dev/null << 'NGINX'
server {
    listen 8080;
    server_name localhost;
    root /var/www/misitio;
    index index.html;
}
NGINX
sudo ln -sf /etc/nginx/sites-available/misitio /etc/nginx/sites-enabled/
sudo nginx -t 2>/dev/null && sudo nginx -s reload 2>/dev/null
echo "Virtual host configurado"
EOF
chmod +x reto5.sh

# Reto 6: Ver logs de nginx
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Ver registros de acceso y error
sudo touch /var/log/nginx/access.log /var/log/nginx/error.log
echo "Logs de nginx:"
ls -la /var/log/nginx/
tail -5 /var/log/nginx/access.log 2>/dev/null
EOF
chmod +x reto6.sh

# Reto 7: Verificar sitios activos
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Listar sitios configurados
echo "Sitios disponibles:"
ls -la /etc/nginx/sites-available/
echo ""
echo "Sitios activos:"
ls -la /etc/nginx/sites-enabled/
EOF
chmod +x reto7.sh

# Reto 8: Probar configuracion
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Verificar que la configuracion es valida
sudo nginx -t 2>&1
EOF
chmod +x reto8.sh

# Reto 9: Recargar nginx
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Recargar configuracion sin reiniciar
sudo nginx -s reload 2>/dev/null
echo "Nginx recargado"
sudo nginx -t 2>&1
EOF
chmod +x reto9.sh

# Reto 10: Detener nginx
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Detener el servidor web
sudo nginx -s stop 2>/dev/null || sudo service nginx stop 2>/dev/null
echo "Nginx detenido"
pgrep nginx || echo "Nginx no esta ejecutandose"
EOF
chmod +x reto10.sh

exito "Entorno de Unit IX preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
