#!/bin/bash
# Unit V: Processes & Services — manual.sh
# Interactive guide for learning process/service management

source /shared/common.sh

UNIT_NAME="unit-V"
banner_unidad 5 "Procesos y Servicios"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Procesos y Servicios                              ║
║  Aprende a gestionar procesos, servicios y cron en Linux   ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  Un proceso es un programa en ejecucion. Cada proceso tiene
  un PID (Process ID) unico. Los procesos pueden ser:
  • Foreground — interactua con el usuario
  • Background — ejecuta sin bloquear el terminal

🔧 COMANDOS DE PROCESOS
══════════════════════════

  Listar procesos
  ─────────────────
  ps aux                    # Todos los procesos (formato BSD)
  ps -ef                    # Todos los procesos (formato SysV)
  ps aux --sort=-%cpu       # Ordenar por CPU
  ps aux --sort=-%mem       # Ordenar por memoria
  top                       # Monitor en tiempo real
  htop                      # Monitor mejorado (si esta instalado)

  Gestionar procesos
  ─────────────────────
  comando &                 # Ejecutar en background
  jobs                      # Ver procesos en background
  fg %1                     # Traer proceso 1 al foreground
  Ctrl+Z                    # Pausar proceso actual
  bg %1                     # Reanudar proceso en background
  kill PID                  # Terminar proceso (SIGTERM)
  kill -9 PID               # Forzar terminacion (SIGKILL)
  killall nombre            # Matar todos los procesos con ese nombre
  pkill patron              # Matar procesos que coincidan con patron

  Servicios (systemd)
  ─────────────────────
  systemctl start servicio      # Iniciar servicio
  systemctl stop servicio       # Detener servicio
  systemctl restart servicio    # Reiniciar servicio
  systemctl status servicio     # Ver estado
  systemctl enable servicio     # Habilitar al inicio
  systemctl disable servicio    # Deshabilitar al inicio
  systemctl list-units          # Listar servicios

  Cron (Tareas Programadas)
  ───────────────────────────
  crontab -e               # Editar cron jobs del usuario
  crontab -l               # Listar cron jobs
  crontab -r               # Eliminar todos los cron jobs

  Formato de cron:
  ┌───── min (0-59)
  │ ┌───── hora (0-23)
  │ │ ┌───── dia (1-31)
  │ │ │ ┌───── mes (1-12)
  │ │ │ │ ┌───── dia_semana (0-7)
  * * * * * comando

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/procesos/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  # Encontrar procesos que usan mucho CPU
  ps aux --sort=-%cpu | head -10

  # Matar un proceso que cuelga
  pkill -f "nombre_del_proceso"

  # Ejecutar comando cada 5 minutos
  */5 * * * * /ruta/comando.sh

  # Verificar si un proceso esta corriendo
  pgrep -f "proceso" && echo "Activo" || echo "Inactivo"

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
