#!/bin/bash
# Unit VI: Storage Management — manual.sh
# Interactive guide for learning storage management

source /shared/common.sh

UNIT_NAME="unit-VI"
banner_unidad 6 "Gestion de Almacenamiento"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Gestion de Almacenamiento                         ║
║  Aprende a administrar discos, particiones y sistemas      ║
║  de archivos en Linux                                      ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  Linux gestiona el almacenamiento mediante:
  • Discos fisicos (/dev/sda, /dev/sdb)
  • Particiones (/dev/sda1, /dev/sda2)
  • Sistemas de archivos (ext4, xfs, btrfs)
  • Puntos de montaje (/home, /var, /tmp)

  En esta unidad usamos dispositivos de bucle (loop) para
  simular discos reales sin afectar el sistema.

🔧 COMANDOS ESENCIALES
══════════════════════════

  Informacion
  ─────────────
  lsblk                     # Ver estructura de discos
  sudo fdisk -l             # Ver tabla de particiones
  df -h                     # Ver espacio disponible
  du -sh directorio         # Ver tamaño de directorio
  mount                     # Ver puntos de montaje

  Gestion de discos
  ───────────────────
  dd if=/dev/zero of=disco.img bs=1M count=10  # Crear disco virtual
  sudo mkfs.ext4 disco.img                      # Formatear ext4
  sudo mount disco.img /mnt                     # Montar
  sudo umount /mnt                              # Desmontar

  Monitoreo
  ──────────
  iostat                    # Estadisticas de E/S
  vmstat                    # Estadisticas de memoria/swap
  free -h                   # Ver memoria RAM
  swapon --show             # Ver swap activo

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/storage/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  # Crear disco virtual de 100MB
  dd if=/dev/zero of=mi_disco.img bs=1M count=100

  # Formatear con ext4
  sudo mkfs.ext4 mi_disco.img

  # Montar
  sudo mkdir -p /mnt/mi_disco
  sudo mount mi_disco.img /mnt/mi_disco

  # Copiar archivos
  sudo cp archivo.txt /mnt/mi_disco/

  # Desmontar
  sudo umount /mnt/mi_disco

  # Verificar espacio
  df -h /mnt/mi_disco

📌 SISTEMAS DE ARCHIVOS COMUNES
══════════════════════════════════

  ext4  — El mas comun en Linux, robusto y confiable
  xfs   — Alto rendimiento para archivos grandes
  btrfs — Copias instantaneas (snapshots), checksums
  tmpfs — Sistema de archivos en memoria RAM
  vfat  — Compatible con Windows (USB, EFI)

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
