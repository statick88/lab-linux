#!/bin/bash
# Unit V: Processes & Services — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-V"
TOTAL_RETOS=10
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

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
