#!/bin/bash
# Unit XI: Backup & Recovery — setup.sh
# Creates the environment and 10 challenges for learning backup

set -e
source /shared/common.sh

UNIT_NAME="unit-XI"
UNIT_NUM=11
TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Respaldo y Recuperacion"

echo -e "${CYAN}Esta unidad ensena a crear, verificar y restaurar respaldos.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/backup"
cd "$HOME/laboratorio/backup"

# Crear datos de prueba
mkdir -p datos/usuarios datos/documentos datos/config
echo "usuario1:password123" > datos/usuarios/usuarios.txt
echo "Configuracion del sistema" > datos/config/sistema.conf
echo "Documento importante" > datos/documentos/doc1.txt
echo "Reporte mensual" > datos/documentos/doc2.txt
echo "Datos de base de datos" > datos/config/db.conf

# Reto 1: Verificar herramientas de backup
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Verificar que las herramientas de backup estan disponibles
which tar && echo "tar OK"
which gzip && echo "gzip OK"
which rsync && echo "rsync OK"
which pg_dump 2>/dev/null && echo "pg_dump OK" || echo "pg_dump no disponible"
EOF
chmod +x reto1.sh

# Reto 2: Crear backup con tar
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Crear un backup comprimido con tar
cd ~/laboratorio/backup
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz datos/
ls -la backup_*.tar.gz
EOF
chmod +x reto2.sh

# Reto 3: Verificar contenido del backup
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Verificar que el backup contiene los archivos correctos
cd ~/laboratorio/backup
backup_file=$(ls -t backup_*.tar.gz | head -1)
tar -tzf "$backup_file"
EOF
chmod +x reto3.sh

# Reto 4: Restaurar backup
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Restaurar un backup a un directorio temporal
cd ~/laboratorio/backup
mkdir -p restaurado
backup_file=$(ls -t backup_*.tar.gz | head -1)
tar -xzf "$backup_file" -C restaurado/
ls -la restaurado/datos/
EOF
chmod +x reto4.sh

# Reto 5: Backup incremental
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Crear un backup incremental con tar
cd ~/laboratorio/backup
# Backup completo inicial
tar -czf backup_full.tar.gz datos/
# Modificar un archivo
echo "Modificado" >> datos/documentos/doc1.txt
# Backup incremental
tar -czf backup_inc.tar.gz --newer=backup_full.tar.gz datos/
echo "Backups creados:"
ls -la backup_*.tar.gz
EOF
chmod +x reto5.sh

# Reto 6: Backup con rsync
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Usar rsync para sincronizar datos
cd ~/laboratorio/backup
mkdir -p destino
rsync -av datos/ destino/
echo "Archivos sincronizados:"
ls -la destino/
EOF
chmod +x reto6.sh

# Reto 7: Verificar integridad con checksum
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Verificar integridad del backup con checksums
cd ~/laboratorio/backup
backup_file=$(ls -t backup_*.tar.gz | head -1)
sha256sum "$backup_file" > "${backup_file}.sha256"
echo "Checksum generado:"
cat "${backup_file}.sha256"
# Verificar
sha256sum -c "${backup_file}.sha256"
EOF
chmod +x reto7.sh

# Reto 8: Backup de configuracion
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Respaldar configuraciones del sistema
cd ~/laboratorio/backup
mkdir -p backup_config
cp -r /etc/nginx backup_config/ 2>/dev/null || echo "nginx no encontrado"
cp /etc/passwd backup_config/ 2>/dev/null
cp /etc/hosts backup_config/ 2>/dev/null
tar -czf backup_config_$(date +%Y%m%d).tar.gz backup_config/
ls -la backup_config_*.tar.gz
EOF
chmod +x reto8.sh

# Reto 9: Programar backup automatico
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Crear script de backup programado
cd ~/laboratorio/backup
cat > backup_auto.sh << 'BACKUP'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf /root/laboratorio/backup/auto_backup_${DATE}.tar.gz /root/laboratorio/backup/datos/
find /root/laboratorio/backup/auto_backup_*.tar.gz -mtime +7 -delete
BACKUP
chmod +x backup_auto.sh
echo "Script de backup automatico creado"
cat backup_auto.sh
EOF
chmod +x reto9.sh

# Reto 10: Restaurar desde backup verificado
cat > reto10.sh << 'EOF'
#!/bin/bash
# Restaurar despues de verificar checksum
cd ~/laboratorio/backup
backup_file=$(ls -t backup_*.tar.gz | head -1)
if [ -f "${backup_file}.sha256" ]; then
    if sha256sum -c "${backup_file}.sha256" 2>/dev/null; then
        echo "Integridad verificada, restaurando..."
        mkdir -p restaurado_final
        tar -xzf "$backup_file" -C restaurado_final/
        echo "Restauracion completada"
    else
        echo "ERROR: Integridad del backup comprometida"
        exit 1
    fi
else
    echo "Sin checksum, restaurando directamente..."
    mkdir -p restaurado_final
    tar -xzf "$backup_file" -C restaurado_final/
fi
EOF
chmod +x reto10.sh

exito "Entorno de Unit XI preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
