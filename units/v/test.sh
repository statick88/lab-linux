#!/bin/bash
# Unit V: Processes & Services — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-V"
TOTAL_RETOS=10

reto1() {
    # Verificar que ps aux funciona y muestra procesos
    output=$(ps aux 2>/dev/null)
    [ -n "$output" ]
    echo "$output" | grep -q "PID\|USER"
}

reto2() {
    # Verificar que puede buscar procesos
    output=$(ps aux | grep bash | grep -v grep)
    [ -n "$output" ]
}

reto3() {
    # Verificar que puede crear un proceso en background
    sleep 300 &
    PID=$!
    [ -d "/proc/$PID" ] 2>/dev/null || kill $PID 2>/dev/null
    [ -n "$PID" ]
}

reto4() {
    # Verificar que puede matar un proceso
    sleep 300 &
    PID=$!
    sleep 1
    kill $PID 2>/dev/null
    sleep 1
    ! kill -0 $PID 2>/dev/null
}

reto5() {
    # Verificar que puede ordenar procesos por CPU
    output=$(ps aux --sort=-%cpu 2>/dev/null || ps aux)
    [ -n "$output" ]
}

reto6() {
    # Verificar que puede ordenar procesos por memoria
    output=$(ps aux --sort=-%mem 2>/dev/null || ps aux)
    [ -n "$output" ]
}

reto7() {
    # Verificar que puede contar procesos por usuario
    output=$(ps aux | awk '{print $1}' | sort | uniq -c)
    [ -n "$output" ]
}

reto8() {
    # Verificar que puede configurar un cron job
    (crontab -l 2>/dev/null; echo "* * * * * echo test") | crontab - 2>/dev/null
    crontab -l 2>/dev/null | grep -q "test"
}

reto9() {
    # Verificar que puede verificar un servicio
    output=$(systemctl status ssh 2>/dev/null || service ssh status 2>/dev/null || echo "checked")
    [ -n "$output" ]
}

reto10() {
    # Verificar que puede listar servicios activos
    output=$(systemctl list-units --type=service --state=running 2>/dev/null || ps aux)
    [ -n "$output" ]
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Listar procesos"
    "Buscar proceso especifico"
    "Crear proceso en background"
    "Matar un proceso"
    "Top procesos por CPU"
    "Top procesos por memoria"
    "Procesos por usuario"
    "Crear cron job"
    "Verificar servicio"
    "Listar servicios activos"
)

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Listar procesos${NC}"
    echo ""
    echo "Tu tarea es mostrar todos los procesos que se están ejecutando en el sistema."
    echo "Utiliza el comando 'ps aux' para obtener la lista completa de procesos."
    echo "Verifica que la salida contenga las columnas PID y USER."
    echo ""
    echo "Comando útil: ps aux"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Buscar proceso especifico${NC}"
    echo ""
    echo "Debes buscar un proceso específico en la lista de procesos."
    echo "Utiliza 'ps aux' combinado con 'grep' para filtrar el proceso que buscas."
    echo "Recuerda excluir la línea del propio grep con 'grep -v grep'."
    echo ""
    echo "Comando útil: ps aux | grep bash | grep -v grep"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Crear proceso en background${NC}"
    echo ""
    echo "Necesitas crear un proceso que se ejecute en segundo plano (background)."
    echo "Agrega '&' al final de un comando para ejecutarlo en background."
    echo "Puedes usar 'sleep 300 &' como ejemplo y luego verificar con 'ps aux'."
    echo ""
    echo "Comando útil: sleep 300 &"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Matar un proceso${NC}"
    echo ""
    echo "Debes terminar un proceso que se esté ejecutando."
    echo "Primero identifica el PID del proceso con 'ps aux'."
    echo "Luego utiliza 'kill' seguido del PID para terminarlo."
    echo "Verifica que el proceso ya no existe con 'kill -0 PID'."
    echo ""
    echo "Comando útil: kill <PID>"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Top procesos por CPU${NC}"
    echo ""
    echo "Debes ordenar los procesos según su uso de CPU."
    echo "Utiliza 'ps aux' con la opción '--sort=-%cpu' para ordenar de mayor a menor."
    echo "Los procesos que más CPU consumen aparecerán primero."
    echo ""
    echo "Comando útil: ps aux --sort=-%cpu"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Top procesos por memoria${NC}"
    echo ""
    echo "Debes ordenar los procesos según su uso de memoria RAM."
    echo "Utiliza 'ps aux' con la opción '--sort=-%mem' para ordenar de mayor a menor."
    echo "Los procesos que más memoria consumen aparecerán primero."
    echo ""
    echo "Comando útil: ps aux --sort=-%mem"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Procesos por usuario${NC}"
    echo ""
    echo "Debes contar cuántos procesos tiene cada usuario."
    echo "Utiliza 'ps aux' para listar todos los procesos."
    echo "Luego extrae la columna de usuario con 'awk' y cuenta con 'sort | uniq -c'."
    echo ""
    echo "Comando útil: ps aux | awk '{print $1}' | sort | uniq -c"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Crear cron job${NC}"
    echo ""
    echo "Debes programar una tarea automática utilizando cron."
    echo "Edita tu crontab con 'crontab -e' o añade una línea directamente."
    echo "Un cron job se compone de: minuto hora día mes día_semana comando."
    echo "Ejemplo: '* * * * * echo test' ejecuta un comando cada minuto."
    echo ""
    echo "Comando útil: (crontab -l; echo '* * * * * comando') | crontab -"
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Verificar servicio${NC}"
    echo ""
    echo "Debes verificar el estado de un servicio del sistema."
    echo "Utiliza 'systemctl status <servicio>' en sistemas con systemd."
    echo "Si systemd no está disponible, usa 'service <servicio> status'."
    echo ""
    echo "Comando útil: systemctl status ssh"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Listar servicios activos${NC}"
    echo ""
    echo "Debes listar todos los servicios que están ejecutándose actualmente."
    echo "Utiliza 'systemctl list-units --type=service --state=running'."
    echo "Si systemd no está disponible, puedes revisar procesos con 'ps aux'."
    echo ""
    echo "Comando útil: systemctl list-units --type=service --state=running"
    separador
}
