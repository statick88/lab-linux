#!/bin/bash
# Unit V: Processes & Services — setup.sh
# Creates the environment and 10 challenges for learning process/service management

set -e
source /shared/common.sh

UNIT_NAME="unit-V"
UNIT_NUM=5
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Procesos y Servicios"

echo -e "${CYAN}Esta unidad ensena a gestionar procesos, servicios y tareas programadas.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/procesos"
cd "$HOME/laboratorio/procesos"

# Reto 1: Listar procesos en ejecucion
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Listar todos los procesos en ejecucion
ps aux | head -20
EOF
chmod +x reto1.sh

# Reto 2: Buscar un proceso especifico
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Buscar procesos de bash
ps aux | grep bash | grep -v grep
EOF
chmod +x reto2.sh

# Reto 3: Crear un proceso en background
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Ejecutar sleep en background y mostrar su PID
sleep 60 &
PID=$!
echo "Proceso sleep iniciado con PID: $PID"
ps aux | grep $PID | grep -v grep
EOF
chmod +x reto3.sh

# Reto 4: Matar un proceso
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Crear un proceso y luego eliminarlo
sleep 120 &
PID=$!
echo "Proceso sleep creado con PID: $PID"
sleep 1
kill $PID 2>/dev/null && echo "Proceso eliminado" || echo "Error al eliminar"
ps aux | grep $PID | grep -v grep || echo "Proceso ya no existe"
EOF
chmod +x reto4.sh

# Reto 5: Usar top para ver procesos
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Mostrar los 5 procesos que mas CPU usan
echo "Top 5 procesos por CPU:"
ps aux --sort=-%cpu | head -6
EOF
chmod +x reto5.sh

# Reto 6: Usar top para ver memoria
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Mostrar los 5 procesos que mas memoria usan
echo "Top 5 procesos por memoria:"
ps aux --sort=-%mem | head -6
EOF
chmod +x reto6.sh

# Reto 7: Procesos por usuario
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Contar cuantos procesos tiene cada usuario
echo "Procesos por usuario:"
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn
EOF
chmod +x reto7.sh

# Reto 8: Crear un cron job
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Programar un cron job que ejecute algo cada minuto
(crontab -l 2>/dev/null; echo "* * * * * echo 'Cron ejecutado' >> /tmp/cron_log.txt") | crontab -
echo "Cron job configurado"
crontab -l
EOF
chmod +x reto8.sh

# Reto 9: Verificar un servicio
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Verificar el estado de un servicio
echo "Estado del servicio ssh:"
systemctl status ssh 2>/dev/null || service ssh status 2>/dev/null || echo "Servicio no disponible"
EOF
chmod +x reto9.sh

# Reto 10: Verificar servicios activos
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Listar servicios activos
echo "Servicios activos:"
systemctl list-units --type=service --state=running 2>/dev/null | head -15 || \
    ps aux | awk '$3 > 0.0 {print $0}' | head -10
EOF
chmod +x reto10.sh

exito "Entorno de Unit V preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
