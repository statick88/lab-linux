#!/bin/bash
# Unit I: Fundamentos de Linux y WSL2 — test.sh
# Supports both interactive mode (bash test.sh) and evaluation mode (evaluar-unidad.sh)

set -e
source /shared/common.sh

UNIT_NAME="unit-I"
TOTAL_RETOS=10

ANSWERS_FILE="$HOME/.unit-I_answers"
[ -f "$ANSWERS_FILE" ] || touch "$ANSWERS_FILE"

# Detect if running in evaluation mode (non-interactive)
EVAL_MODE=false
if [ -t 0 ]; then
    # stdin is a terminal - interactive mode
    EVAL_MODE=false
else
    # stdin is not a terminal - evaluation mode
    EVAL_MODE=true
fi

get_answer() {
    local prompt="$1"
    local answer=""
    
    if [ "$EVAL_MODE" = true ]; then
        # In evaluation mode, read from a predefined answers file or env
        if [ -n "${TEST_ANSWERS[$RETO_NUM]}" ]; then
            echo "${TEST_ANSWERS[$RETO_NUM]}"
            return 0
        fi
        # Try to read from a file if provided
        if [ -f "/tmp/test_answers_${RETO_NUM}" ]; then
            cat "/tmp/test_answers_${RETO_NUM}"
            return 0
        fi
        # No answer available in eval mode
        echo ""
        return 1
    else
        # Interactive mode - prompt user
        echo -n "$1" >&2
        read -r respuesta
        echo "${respuesta^^}"
    fi
}

# Helper to ask question and validate answer
ask_question() {
    local prompt="$1"
    local correct="$2"
    local hint="$3"
    local key="$4"
    
    local answer=$(get_answer "$prompt")
    
    if [ "$EVAL_MODE" = true ]; then
        # In eval mode, just check if answer matches expected
        if [ "$answer" = "$correct" ]; then
            echo "✓ $key: OK"
            echo "$key" >> "$ANSWERS_FILE"
            return 0
        else
            echo "✗ $key: FALLIDO (esperado: $correct, recibido: $answer)"
            return 1
        fi
    else
        # Interactive mode
        case "$answer" in
            "$correct") echo "✓ Correcto: $hint"; echo "$key" >> "$ANSWERS_FILE"; return 0 ;;
            *) echo "✗ Incorrecto: $hint (respuesta $correct)"; return 1 ;;
        esac
    fi
}

reto1() {
    ask_question "PREGUNTA 1: ¿Cuál es el propósito principal del directorio /etc en FHS?
  A) Almacenar archivos temporales del sistema
  B) Contener archivos de configuración del sistema
  C) Guardar logs y archivos variables
  D) Almacenar binarios de usuario
Tu respuesta (A/B/C/D): " "B" "/etc = configuración del sistema" "CONFIGURACION"
}

reto2() {
    ask_question "PREGUNTA 2: ¿Qué directorio contiene datos variables que PERSISTEN entre reinicios (logs, spool)?
  A) /tmp
  B) /var
  C) /run
  D) /dev/shm
Tu respuesta (A/B/C/D): " "B" "/var = datos variables persistentes (logs, spool)" "VARIABLES"
}

reto3() {
    ask_question "PREGUNTA 3: ¿Qué comando muestra el directorio de trabajo actual?
  A) ls
  B) cd
  C) pwd
  D) dir
Tu respuesta (A/B/C/D): " "C" "pwd = print working directory" "PWD"
}

reto4() {
    ask_question "PREGUNTA 4: ¿Qué opción de 'ls' muestra archivos ocultos (los que empiezan con punto)?
  A) -h
  B) -l
  C) -a
  D) -r
Tu respuesta (A/B/C/D): " "C" "ls -a muestra all (incluye ocultos)" "OCULTOS"
}

reto5() {
    ask_question "PREGUNTA 5: ¿Qué permisos otorga 'chmod 755 archivo'?
  A) Propietario: rwx | Grupo: r-x | Otros: r-x
  B) Propietario: rw- | Grupo: r-- | Otros: r--
  C) Propietario: rwx | Grupo: rwx | Otros: rwx
  D) Propietario: r-x | Grupo: r-x | Otros: r-x
Tu respuesta (A/B/C/D): " "A" "7=rwx, 5=r-x, 5=r-x" "PERMISOS"
}

reto6() {
    ask_question "PREGUNTA 6: ¿Cuál es la diferencia arquitectural principal de WSL2 vs WSL1?
  A) WSL2 usa una VM ligera con kernel Linux real; WSL1 traduce syscalls
  B) WSL2 es más lento pero más compatible
  C) WSL1 tiene kernel Linux; WSL2 usa traducción
  D) No hay diferencia, son iguales
Tu respuesta (A/B/C/D): " "A" "WSL2 = VM ligera + kernel Linux real" "WSL2"
}

reto7() {
    ask_question "PREGUNTA 7: ¿Qué comando se usa para montar un sistema de archivos en un directorio?
  A) fsck
  B) mount
  C) fdisk
  D) mkfs
Tu respuesta (A/B/C/D): " "B" "mount une un FS al árbol de directorios" "MONTAR"
}

reto7() {
    ask_question "PREGUNTA 7: ¿Qué comando se usa para montar un sistema de archivos en un directorio?
  A) fsck
  B) mount
  C) fdisk
  D) mkfs
Tu respuesta (A/B/C/D): " "B" "mount une un FS al árbol de directorios" "MONTAR"
}

reto8() {
    ask_question "PREGUNTA 8: ¿Qué UID (User ID) tiene siempre el usuario root en Linux?
  A) 1
  B) 1000
  C) 0
  D) 65535
Tu respuesta (A/B/C/D): " "C" "root siempre tiene UID 0" "ROOT"
}

reto9() {
    ask_question "PREGUNTA 9: ¿Qué símbolo se usa para encadenar la salida de un comando como entrada de otro (pipe)?
  A) >
  B) <
  C) |
  D) >>
Tu respuesta (A/B/C/D): " "C" "| (pipe) conecta stdout de uno a stdin del otro" "PIPE"
}

reto10() {
    ask_question "PREGUNTA 10: ¿Qué comando muestra el espacio disponible en disco de forma legible (human-readable)?
  A) du -h
  B) df -h
  C) ls -h
  D) free -h
Tu respuesta (A/B/C/D): " "B" "df -h = disk free human-readable" "DISCO"
}

# Define validators array
validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Directorio /etc (FHS)"
    "/var vs /tmp"
    "Comando pwd"
    "Opción ls -a"
    "Permisos 755"
    "WSL2 arquitectura"
    "Comando mount"
    "UID de root"
    "Símbolo pipe"
    "df -h espacio disco"
)

# If EVAL_MODE is true and TEST_ANSWERS is provided, use it
if [ "$EVAL_MODE" = true ] && [ -n "${TEST_ANSWERS[*]}" ]; then
    export TEST_ANSWERS
fi

# Run all validators
for i in "${!validators[@]}"; do
    export RETO_NUM=$((i + 1))
    if ! ${validators[i]}; then
        echo "✗ ${challenge_names[i]}: FALLIDO"
        exit 1
    fi
    echo "✓ ${challenge_names[i]}: OK"
done

echo ""
echo "✓ Todos los retos completados"

# Mostrar frase oculta si todo correcto
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${AMARILLO}Frase oculta revelada:${RESET}"
    cat "$HOME/.unit-I_answers" | paste -sd " " -
    echo ""
fi