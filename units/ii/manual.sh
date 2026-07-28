#!/bin/bash
# Unit II: Package Management — manual.sh
# Interactive guide for learning apt/dpkg

source /shared/common.sh

UNIT_NAME="unit-II"
banner_unidad 2 "Gestion de Paquetes"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Gestion de Paquetes en Linux                      ║
║  Aprende a usar apt, dpkg y apt-cache                      ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  apt (Advanced Package Tool)
  ───────────────────────────
  Gestor de paquetes de alto nivel para Debian/Ubuntu.
  Administra repositorios, dependencias y actualizaciones.

  dpkg (Debian Package)
  ─────────────────────
  Gestor de paquetes de bajo nivel.
  Trabaja directamente con archivos .deb sin resolver dependencias.

  apt-cache
  ─────────
  Herramienta para consultar la base de datos local de paquetes.

🔧 COMANDOS ESENCIALES
══════════════════════════

  sudo apt-get update          # Actualizar cache de repositorios
  sudo apt-get install pkg     # Instalar un paquete
  sudo apt-get remove pkg      # Eliminar ( conserva configuracion )
  sudo apt-get purge pkg       # Eliminar todo ( incluye configuracion )
  sudo apt-get upgrade         # Actualizar todos los paquetes
  dpkg -l                      # Listar todos los paquetes instalados
  dpkg -l pkg                  # Ver estado de un paquete especifico
  dpkg -L pkg                  # Listar archivos de un paquete
  dpkg -S /ruta/archivo        # Buscar que paquete posee un archivo
  apt-cache show pkg            # Mostrar informacion detallada
  apt-cache search texto       # Buscar paquetes por descripcion
  apt-cache policy pkg         # Ver versiones disponibles

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/paquetes/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 TIPS
════════

  • Siempre ejecuta 'sudo apt-get update' antes de instalar
  • Usa 'apt-cache show' para ver dependencias antes de instalar
  • 'dpkg -l | grep nombre' es util para buscar paquetes
  • 'dpkg -S archivo' te dice de que paquete viene un archivo

📌 EJEMPLO INTERACTIVO
════════════════════════

  $ apt-cache show nginx
  Package: nginx
  Version: 1.18.0-6.1
  Depends: ...

  $ dpkg -L curl
  /usr/
  /usr/bin/
  /usr/bin/curl
  /usr/share/man/...

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
