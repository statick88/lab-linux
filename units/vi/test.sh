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
    size=$(stat -c%s /tmp/test_disk.img 2>/dev/null || stat -f%z /tmp/test_disk.img 2>/dev/null)
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

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Ver dispositivos de bloque${NC}"
    echo ""
    echo "Descubre los dispositivos de bloque disponibles en el sistema."
    echo "Comando útil: lsblk"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Ver tabla de particiones${NC}"
    echo ""
    echo "Consulta la tabla de particiones de los discos del sistema."
    echo "Comando útil: sudo fdisk -l"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Crear disco virtual${NC}"
    echo ""
    echo "Crea un archivo de disco virtual de al menos 5 MB usando dd."
    echo "Comando útil: dd if=/dev/zero of=/tmp/disco_virtual.img bs=1M count=5"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Formatear disco virtual${NC}"
    echo ""
    echo "Formatea el disco virtual creado con el sistema de archivos ext4."
    echo "Comando útil: sudo mkfs.ext4 /tmp/disco_virtual.img"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Montar disco virtual${NC}"
    echo ""
    echo "Monta el disco virtual en un directorio de tu sistema."
    echo "Comandos útiles: mkdir /tmp/montaje && sudo mount /tmp/disco_virtual.img /tmp/montaje"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Copiar archivos a disco${NC}"
    echo ""
    echo "Copia archivos al disco virtual montado."
    echo "Comando útil: echo \"hola\" > /tmp/montaje/archivo.txt"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Desmontar disco${NC}"
    echo ""
    echo "Desmonta el disco virtual de forma segura."
    echo "Comando útil: sudo umount /tmp/montaje"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Ver espacio en disco${NC}"
    echo ""
    echo "Consulta el espacio en disco disponible en el sistema."
    echo "Comando útil: df -h"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Medir tamaño de directorio${NC}"
    echo ""
    echo "Mide el tamaño que ocupa un directorio."
    echo "Comando útil: du -sh ~/laboratorio/"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Limpiar disco virtual${NC}"
    echo ""
    echo "Elimina el disco virtual que creaste para liberar espacio."
    echo "Comando útil: rm ~/laboratorio/storage/disco_virtual.img"
    separador
}
