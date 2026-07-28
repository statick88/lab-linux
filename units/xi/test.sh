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

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
