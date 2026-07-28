#!/bin/bash
# Unit XI: Backup & Recovery — manual.sh
# Interactive guide for learning backups

source /shared/common.sh

UNIT_NAME="unit-XI"
banner_unidad 11 "Respaldo y Recuperacion"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Respaldo y Recuperacion                          ║
║  Protege tus datos con estrategias de backup solidas      ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  Tipos de backup:
  • Completo — todos los archivos (lento, espacio)
  • Incremental — solo cambios desde el ultimo (rapido)
  • Diferencial — cambios desde el completo (balance)

  Regla 3-2-1:
  • 3 copias de tus datos
  • 2 medios diferentes
  • 1 copia offsite

🔧 COMANDOS ESENCIALES
══════════════════════════

  tar (archivos)
  ────────────────
  tar -czf backup.tar.gz datos/     # Crear backup comprimido
  tar -xzf backup.tar.gz            # Extraer backup
  tar -tzf backup.tar.gz            # Listar contenido
  tar -czf inc.tar.gz --newer=ref.tar.gz datos/  # Incremental

  rsync (sincronizacion)
  ──────────────────────
  rsync -av datos/ destino/         # Sincronizar directorios
  rsync -av --delete datos/ dest/   # Sincronizar con borrado
  rsync -avz remote:/path/ local/   # Sincronizar remoto

  Verificacion
  ──────────────
  sha256sum backup.tar.gz > backup.sha256
  sha256sum -c backup.sha256         # Verificar integridad

  Programacion (cron)
  ────────────────────
  crontab -e
  0 2 * * * /path/to/backup.sh      # Diario a las 2am
  0 0 * * 0 /path/to/backup.sh     # Semanal (domingo)

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/backup/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  # Backup completo de /etc
  sudo tar -czf /backup/etc_$(date +%Y%m%d).tar.gz /etc/

  # Backup con排除 de archivos grandes
  tar -czf backup.tar.gz --exclude="*.log" --exclude="node_modules" datos/

  # Restaurar backup especifico
  tar -xzf backup.tar.gz --wildcards "*.conf" -C /tmp/

  # Script de backup con rotation
  #!/bin/bash
  BACKUP_DIR="/backup"
  KEEP=7
  tar -czf ${BACKUP_DIR}/backup_$(date +%Y%m%d).tar.gz /datos
  find ${BACKUP_DIR} -name "backup_*.tar.gz" -mtime +${KEEP} -delete

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
