#!/bin/bash
# Unit IV: User Management — manual.sh
# Interactive guide for learning user/group administration

source /shared/common.sh

UNIT_NAME="unit-IV"
banner_unidad 4 "Gestion de Usuarios"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Gestion de Usuarios y Grupos                      ║
║  Aprende a administrar cuentas de usuario en Linux          ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  En Linux, cada usuario tiene:
  • UID (User ID) — identificador numerico unico
  • GID (Group ID) — grupo principal
  • Home directory — directorio personal
  • Shell por defecto — interpretador de comandos

  Los grupos permiten gestionar permisos colectivos.
  Un usuario puede pertenecer a multiples grupos.

🔧 COMANDOS ESENCIALES
══════════════════════════

  USUARIOS
  ─────────
  sudo useradd -m usuario      # Crear usuario con home
  sudo userdel usuario         # Eliminar usuario
  sudo userdel -r usuario      # Eliminar usuario y home
  sudo usermod -s /bin/sh usr  # Cambiar shell
  sudo usermod -aG grp usr     # Agregar a grupo (append)
  passwd usuario               # Cambiar contrasena
  id usuario                   # Ver UID, GID, grupos
  whoami                       # Usuario actual

  GRUPOS
  ────────
  sudo groupadd grupo          # Crear grupo
  sudo groupdel grupo          # Eliminar grupo
  groups usuario               # Ver grupos de un usuario
  getent group grupo           # Ver info del grupo

  PERMISOS
  ─────────
  chmod 755 directorio         # rwxr-xr-x
  chmod 644 archivo            # rw-r--r--
  chown usuario:grupo archivo  # Cambiar propietario
  chown -R u:g dir             # Recursivo

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/usuarios/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS DE PERMISOS
═══════════════════════════

  755 = rwxr-xr-x (ejecutables, directorios)
  644 = rw-r--r-- (archivos normales)
  700 = rwx------ (solo propietario)
  600 = rw------- (archivos privados)

📌 REFERENCIA RAPIDA
════════════════════════

  Propietario  Grupo    Otros
  rwx          rwx      rwx
  7            7        7

  r = 4 (read)
  w = 2 (write)
  x = 1 (execute)

  7 = r+w+x = 4+2+1
  5 = r+x = 4+0+1
  4 = r = 4+0+0

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
