#!/bin/bash
# Unit VII: Security Hardening — manual.sh
# Interactive guide for learning security

source /shared/common.sh

UNIT_NAME="unit-VII"
banner_unidad 7 "Seguridad del Sistema"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Seguridad del Sistema                             ║
║  Aprende a proteger tu servidor Linux de amenazas          ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  La seguridad en Linux se basa en:
  • Autenticación — verificar identidad
  • Autorización — controlar acceso
  • Auditoría — registrar actividad
  • Hardening — reducir superficie de ataque

🔧 COMANDOS DE SEGURIDAD
══════════════════════════════

  Gestion de usuarios
  ─────────────────────
  passwd usuario              # Cambiar contraseña
  chage -l usuario            # Ver politica de contraseñas
  awk -F: '$3 == 0' /etc/passwd  # Ver usuarios root

  Permisos y archivos
  ──────────────────────
  find / -perm -4000          # Archivos SUID
  find / -perm -2000          # Archivos SGID
  chmod 700 ~/.ssh            # Permisos seguros para SSH
  ls -la /etc/shadow          # Verificar permisos de shadow

  Firewall (UFW)
  ────────────────
  sudo ufw status             # Ver estado
  sudo ufw enable             # Activar firewall
  sudo ufw allow 22           # Permitir SSH
  sudo ufw allow 80           # Permitir HTTP
  sudo ufw deny 3306          # Bloquear MySQL
  sudo ufw delete allow 80    # Eliminar regla

  SSH (Claves Publicas)
  ──────────────────────
  ssh-keygen -t rsa -b 4096   # Generar par de claves
  ssh-copy-id usuario@host    # Copiar clave publica al servidor
  ssh -i ~/.ssh/id_rsa user@host  # Conectar con clave

  Monitoreo de seguridad
  ────────────────────────
  last                        # Ultimos logins
  lastb                       # Logins fallidos
  who                         # Quien esta conectado
  journalctl -u ssh           # Logs del servicio SSH
  cat /var/log/auth.log       # Logs de autenticacion

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/security/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  # Activar firewall y permitir solo SSH
  sudo ufw allow 22
  sudo ufw enable

  # Generar claves SSH
  ssh-keygen -t rsa -b 4096
  ssh-copy-id usuario@servidor

  # Verificar usuarios con permisos root
  awk -F: '$3 == 0 {print $1}' /etc/passwd

  # Buscar archivos SUID
  find / -perm -4000 -type f 2>/dev/null

📌 BUENAS PRACTICAS
══════════════════════

  • Usar claves SSH en vez de contraseñas
  • Deshabilitar login de root por SSH
  • Usar firewall (UFW o iptables)
  • Actualizar el sistema regularmente
  • Monitorear logs de seguridad
  • Usar contraseñas fuertes (minimo 12 caracteres)
  • Limitar acceso con sudoers

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
