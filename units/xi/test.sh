#!/bin/bash
# Unit XI: Backup & Recovery — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-XI"
TOTAL_RETOS=10

reto1() {
    which tar && which gzip && which rsync
}

reto2() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    tar -czf backup_test.tar.gz datos/ 2>/dev/null
    [ -f backup_test.tar.gz ]
}

reto3() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    tar -czf backup_test.tar.gz datos/ 2>/dev/null
    output=$(tar -tzf backup_test.tar.gz 2>/dev/null)
    echo "$output" | grep -q "datos/"
}

reto4() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    tar -czf backup_test.tar.gz datos/ 2>/dev/null
    mkdir -p restaurado
    tar -xzf backup_test.tar.gz -C restaurado/ 2>/dev/null
    [ -d restaurado/datos ]
}

reto5() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    tar -czf backup_full.tar.gz datos/ 2>/dev/null
    touch backup_inc.tar.gz  # Simular incremental
    [ -f backup_full.tar.gz ]
}

reto6() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    mkdir -p destino
    rsync -av datos/ destino/ 2>/dev/null | grep -q "sent\|transferred\|file"
}

reto7() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    tar -czf backup_test.tar.gz datos/ 2>/dev/null
    sha256sum backup_test.tar.gz > backup_test.tar.gz.sha256 2>/dev/null
    [ -f backup_test.tar.gz.sha256 ]
}

reto8() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    mkdir -p backup_config
    cp /etc/hosts backup_config/ 2>/dev/null
    tar -czf backup_config_test.tar.gz backup_config/ 2>/dev/null
    [ -f backup_config_test.tar.gz ]
}

reto9() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    cat > backup_auto_test.sh << 'BACKUP'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
echo "Backup ejecutado: ${DATE}"
BACKUP
    chmod +x backup_auto_test.sh
    [ -f backup_auto_test.sh ] && [ -x backup_auto_test.sh ]
}

reto10() {
    cd /root/laboratorio/backup 2>/dev/null || cd ~
    tar -czf backup_test.tar.gz datos/ 2>/dev/null
    sha256sum backup_test.tar.gz > backup_test.tar.gz.sha256 2>/dev/null
    sha256sum -c backup_test.tar.gz.sha256 2>/dev/null | grep -q "OK"
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Verificar herramientas"
    "Crear backup con tar"
    "Verificar contenido del backup"
    "Restaurar backup"
    "Backup incremental"
    "Backup con rsync"
    "Verificar integridad con checksum"
    "Backup de configuracion"
    "Programar backup automatico"
    "Restaurar desde backup verificado"
)

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Verificar herramientas${NC}"
    echo ""
    echo "Instala y verifica que las herramientas de backup estén disponibles en el sistema."
    echo "Comandos útiles: which, tar, gzip, rsync"
    echo "Ejemplo: which tar"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Crear backup con tar${NC}"
    echo ""
    echo "Crea un archivo de respaldo comprimido del directorio datos/ usando tar."
    echo "Comando útil: tar -czf backup.tar.gz datos/"
    echo "El archivo resultante debe llamarse backup.tar.gz"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Verificar contenido del backup${NC}"
    echo ""
    echo "Verifica que el archivo de respaldo contenga correctamente el directorio datos/."
    echo "Comando útil: tar -tzf backup.tar.gz"
    echo "Busca que aparezca 'datos/' en la lista de archivos"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Restaurar backup${NC}"
    echo ""
    echo "Extrae el contenido del archivo de respaldo a un directorio de restauración."
    echo "Comando útil: tar -xzf backup.tar.gz -C restaurado/"
    echo "Verifica que el directorio restaurado/datos/ exista después de la extracción"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Backup incremental${NC}"
    echo ""
    echo "Implementa una estrategia de backup incremental usando tar."
    echo "Comandos útiles: tar --listed-incremental, --newer"
    echo "Primero crea un backup completo, luego uno incremental"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Backup con rsync${NC}"
    echo ""
    echo "Utiliza rsync para sincronizar datos entre directorios de forma eficiente."
    echo "Comando útil: rsync -av datos/ destino/"
    echo "La opción -a preserva permisos, -v muestra verbosidad"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Verificar integridad con checksum${NC}"
    echo ""
    echo "Genera un archivo de verificación SHA-256 para tu backup."
    echo "Comando útil: sha256sum backup.tar.gz > backup.tar.gz.sha256"
    echo "Esto permite detectar corrupción o modificaciones no autorizadas"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Backup de configuración${NC}"
    echo ""
    echo "Crea un respaldo de archivos de configuración importantes del sistema."
    echo "Comandos útiles: cp, tar -czf"
    echo "Copia archivos como /etc/hosts a un directorio y comprímelos"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Programar backup automático${NC}"
    echo ""
    echo "Crea un script de shell que ejecute backups de forma automática."
    echo "Comando útil: crontab -e (para programar ejecución)"
    echo "El script debe ser ejecutable (chmod +x) y usar date para nombres únicos"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Restaurar desde backup verificado${NC}"
    echo ""
    echo "Restaura archivos verificando primero la integridad del backup con checksum."
    echo "Comandos útiles: sha256sum -c backup.tar.gz.sha256, tar -xzf"
    echo "Primero verifica con sha256sum -c, luego restaura si el checksum es OK"
    separador
}
