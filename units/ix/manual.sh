#!/bin/bash
# Unit IX: Web Server — manual.sh
# Interactive guide for learning nginx

source /shared/common.sh

UNIT_NAME="unit-IX"
banner_unidad 9 "Servidor Web"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia del Servidor Web nginx                               ║
║  Aprende a configurar y administrar un servidor web        ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  nginx es un servidor web de alto rendimiento que maneja:
  • Páginas web estáticas (HTML, CSS, JS)
  • Proxy inverso para aplicaciones backend
  • Balanceo de carga
  • Terminación SSL/TLS

🔧 COMANDOS ESENCIALES
══════════════════════════

  Gestion de nginx
  ──────────────────
  sudo nginx                   # Iniciar nginx
  sudo nginx -s stop           # Detener nginx
  sudo nginx -s reload         # Recargar configuracion
  sudo nginx -t                # Verificar configuracion
  sudo nginx -V                # Ver version y modulos

  Archivos de configuracion
  ───────────────────────────
  /etc/nginx/nginx.conf        # Configuracion principal
  /etc/nginx/sites-available/  # Sitios disponibles
  /etc/nginx/sites-enabled/    # Sitios activos (symlinks)
  /var/log/nginx/              # Logs de acceso y error

  Virtual Hosts
  ───────────────
  sudo nano /etc/nginx/sites-available/misitio
  sudo ln -s /etc/nginx/sites-available/misitio /etc/nginx/sites-enabled/
  sudo nginx -s reload

  Verificar configuracion
  ─────────────────────────
  curl -I http://localhost     # Ver headers HTTP
  curl http://localhost        # Ver contenido
  tail -f /var/log/nginx/access.log  # Monitorear accesos

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/web/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  # Configuracion basica de virtual host
  server {
      listen 80;
      server_name midominio.com;
      root /var/www/misitio;
      index index.html;

      location / {
          try_files $uri $uri/ =404;
      }
  }

  # Proxy inverso a una app Node.js
  location /api {
      proxy_pass http://127.0.0.1:3000;
      proxy_set_header Host $host;
  }

  # Habilitar compresion gzip
  gzip on;
  gzip_types text/plain text/css application/json;

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
