#!/bin/bash
# Unit VI: Storage Management — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-VI"
TOTAL_RETOS=10

reto1() {
    # Verificar que lsblk funciona
    output=$(lsblk 2>/dev/null)
    [ -n "$output" ]
}

reto2() {
    # Verificar que fdisk funciona
    output=$(sudo fdisk -l 2>/dev/null | head -5)
    [ -n "$output" ]
}

reto3() {
    # Verificar que puede crear archivo de disco virtual
    dd if=/dev/zero of=/tmp/test_disk.img bs=1M count=5 2>/dev/null
    [ -f "/tmp/test_disk.img" ]
    size=$(stat -f%z /tmp/test_disk.img 2>/dev/null || stat -c%s /tmp/test_disk.img 2>/dev/null)
    [ "$size" -gt 4000000 ]
    rm -f /tmp/test_disk.img
}

reto4() {
    # Verificar que puede formatear disco virtual
    dd if=/dev/zero of=/tmp/test_disk.img bs=1M count=5 2>/dev/null
    sudo mkfs.ext4 /tmp/test_disk.img 2>/dev/null | grep -q "ext4"
    rm -f /tmp/test_disk.img
}

reto5() {
    # Verificar que puede montar disco virtual
    dd if=/dev/zero of=/tmp/test_disk.img bs=1M count=5 2>/dev/null
    sudo mkfs.ext4 /tmp/test_disk.img 2>/dev/null
    mkdir -p /tmp/test_mount
    sudo mount /tmp/test_disk.img /tmp/test_mount 2>/dev/null
    mount | grep -q "test_mount"
    sudo umount /tmp/test_mount 2>/dev/null
    rm -f /tmp/test_disk.img
    rmdir /tmp/test_mount 2>/dev/null || true
}

reto6() {
    # Verificar que puede copiar archivos a disco montado
    dd if=/dev/zero of=/tmp/test_disk.img bs=1M count=5 2>/dev/null
    sudo mkfs.ext4 /tmp/test_disk.img 2>/dev/null
    mkdir -p /tmp/test_mount
    sudo mount /tmp/test_disk.img /tmp/test_mount 2>/dev/null
    echo "test" > /tmp/test_mount/test.txt
    [ -f "/tmp/test_mount/test.txt" ]
    sudo umount /tmp/test_mount 2>/dev/null
    rm -f /tmp/test_disk.img
    rmdir /tmp/test_mount 2>/dev/null || true
}

reto7() {
    # Verificar que puede desmontar disco
    dd if=/dev/zero of=/tmp/test_disk.img bs=1M count=5 2>/dev/null
    sudo mkfs.ext4 /tmp/test_disk.img 2>/dev/null
    mkdir -p /tmp/test_mount
    sudo mount /tmp/test_disk.img /tmp/test_mount 2>/dev/null
    sudo umount /tmp/test_mount 2>/dev/null
    ! mount | grep -q "test_mount"
    rm -f /tmp/test_disk.img
    rmdir /tmp/test_mount 2>/dev/null || true
}

reto8() {
    # Verificar que puede ver espacio en disco
    output=$(df -h 2>/dev/null)
    [ -n "$output" ]
}

reto9() {
    # Verificar que puede medir tamaño de directorio
    output=$(du -sh ~/laboratorio/ 2>/dev/null)
    [ -n "$output" ]
}

reto10() {
    # Verificar que puede limpiar disco virtual
    rm -f ~/laboratorio/storage/disco_virtual.img 2>/dev/null
    [ ! -f ~/laboratorio/storage/disco_virtual.img ]
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Ver dispositivos de bloque"
    "Ver tabla de particiones"
    "Crear disco virtual"
    "Formatear disco virtual"
    "Montar disco virtual"
    "Copiar archivos a disco"
    "Desmontar disco"
    "Ver espacio en disco"
    "Medir tamaño de directorio"
    "Limpiar disco virtual"
)

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
