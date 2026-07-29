#!/bin/bash
# Unit I: Fundamentos de Linux y WSL2 — manual.sh
# Interactive guide for learning Linux fundamentals

source /shared/common.sh

UNIT_NAME="unit-I"
banner_unidad 1 "Fundamentos de Linux y WSL2"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Fundamentos de Linux y WSL2                       ║
║  Aprende a navegar, entender FHS, permisos y WSL2         ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  FHS (Filesystem Hierarchy Standard)
  ─────────────────────────────────────
  Linux organiza archivos en una jerarquía estándar:

  /           Raíz del sistema
  ├── /bin    Binarios esenciales de usuario
  ├── /boot   Archivos de arranque (kernel, initrd)
  ├── /dev    Archivos de dispositivo
  ├── /etc    CONFIGURACIÓN DEL SISTEMA  ← IMPORTANTE
  ├── /home   Directorios personales de usuarios
  ├── /lib    Bibliotecas esenciales
  ├── /media  Puntos de montaje extraíbles
  ├── /mnt    Montajes temporales
  ├── /opt    Software opcional/add-on
  ├── /proc   Información de procesos (virtual)
  ├── /root   Home de root
  ├── /run    Datos de runtime (desde boot)
  ├── /sbin   Binarios de sistema (admin)
  ├── /srv    Datos de servicios
  ├── /sys    Info de kernel (virtual)
  ├── /tmp    TEMPORALES (se borran al reiniciar)
  ├── /usr    Programas de usuario (read-only)
  │   ├── /usr/bin
  │   ├── /usr/lib
  │   └── /usr/local
  └── /var    VARIABLES: logs, spool, caché  ← PERSISTE

🔧 COMANDOS ESENCIALES
══════════════════════════

  NAVEGACIÓN
  ──────────
  pwd                    # Directorio actual (Print Working Directory)
  cd /ruta               # Cambiar directorio
  cd ~                   # Ir a home ($HOME)
  cd -                   # Directorio anterior
  ls                     # Listar
  ls -la                 # Detallado + ocultos (-a)
  ls -lh                 # Tamaños legibles (-h)

  ARCHIVOS
  ────────
  cat archivo            # Ver contenido
  less archivo           # Ver con paginación (q para salir)
  head -n 10 archivo     # Primeras 10 líneas
  tail -f archivo        # Últimas líneas + seguir (logs)
  cp origen destino      # Copiar
  mv origen destino      # Mover/renombrar
  rm archivo             # Eliminar
  rm -r dir              # Eliminar directorio recursivo
  mkdir -p ruta/nueva    # Crear directorios padres

  PERMISOS
  ────────
  chmod 755 archivo      # rwxr-xr-x
  chmod 644 archivo      # rw-r--r--
  chown user:group arch  # Cambiar propietario
  chown -R u:g dir       # Recursivo

  OCTALES
  ───────
  7 = rwx (4+2+1)
  6 = rw- (4+2+0)
  5 = r-x (4+0+1)
  4 = r-- (4+0+0)
  0 = --- (0+0+0)

  755 = rwx | r-x | r-x  (ejecutables, directorios)
  644 = rw- | r-- | r--  (archivos normales)
  600 = rw- | --- | ---  (privados: claves SSH, .env)

🐧 WSL2 (Windows Subsystem for Linux 2)
════════════════════════════════════════

  WSL2 usa un kernel Linux REAL en VM ligera (Hyper-V).
  
  Ventajas vs WSL1:
  ✓ Kernel Linux completo (compatibilidad 100%)
  ✓ Docker nativo (DinD)
  ✓ systemd (en versiones recientes)
  ✓ Mejor rendimiento I/O

  Comandos útiles:
  ────────────────
  wsl --list --verbose         # Ver distros instaladas
  wsl --set-default-version 2  # WSL2 por defecto
  wsl --install -d Ubuntu      # Instalar Ubuntu
  wsl -d Ubuntu                # Entrar a Ubuntu
  wsl --shutdown               # Apagar VM

  Integración Windows ↔ Linux:
  ──────────────────────────────
  /mnt/c/Users/usuario/...     # Acceder a Windows desde Linux
  \\wsl$\Ubuntu\home\usuario   # Acceder a Linux desde Explorer
  code .                       # VS Code abre en WSL (con ext Remote-WSL)

🎯 RETOS DE ESTA UNIDAD
══════════════════════════

  10 preguntas de selección múltiple:
  1. Directorio /etc (FHS)
  2. /var vs /tmp
  3. Comando pwd
  4. Opción ls -a
  5. Permisos 755
  6. Arquitectura WSL2
  7. Comando mount
  8. UID de root
  9. Símbolo pipe (|)
  10. df -h (espacio disco)

💡 COMANDOS PARA EL LAB
══════════════════════════

  • Ejecutar reto:     bash reto1.sh
  • Ver progreso:      evaluar-unidad
  • Ver retos:         retos-unidad
  • Ver manual:        retos-unidad
  • Frase oculta:      revelar-frase

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar-unidad'${AMARILLO} para verificar tu progreso o ${CYAN}'bash reto1.sh'${AMARILLO} para empezar.${RESET}"