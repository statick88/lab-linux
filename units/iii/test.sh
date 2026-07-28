#!/bin/bash
# Unit III: Shell Scripting — test.sh
# Automated validation of 10 challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-III"
TOTAL_RETOS=10

reto1() {
    # Verificar que saludar.sh existe y es ejecutable
    [ -x "$HOME/laboratorio/shell/saludar.sh" ]
    # Verificar que imprime algo
    output=$(cd "$HOME/laboratorio/shell" && ./saludar.sh 2>&1)
    [ -n "$output" ]
}

reto2() {
    # Verificar que pedir_nombre.sh existe
    [ -x "$HOME/laboratorio/shell/pedir_nombre.sh" ]
    # Verificar que usa read
    grep -q "read" "$HOME/laboratorio/shell/pedir_nombre.sh"
}

reto3() {
    # Verificar que par_o_impar.sh existe y usa if
    [ -x "$HOME/laboratorio/shell/par_o_impar.sh" ]
    grep -q "if" "$HOME/laboratorio/shell/par_o_impar.sh"
}

reto4() {
    # Verificar que contar.sh existe y usa for
    [ -x "$HOME/laboratorio/shell/contar.sh" ]
    grep -q "for" "$HOME/laboratorio/shell/contar.sh"
    # Verificar que imprima numeros
    output=$(cd "$HOME/laboratorio/shell" && ./contar.sh 2>&1)
    echo "$output" | grep -q "Numero: 1"
}

reto5() {
    # Verificar que contar_while.sh existe y usa while
    [ -x "$HOME/laboratorio/shell/contar_while.sh" ]
    grep -q "while" "$HOME/laboratorio/shell/contar_while.sh"
}

reto6() {
    # Verificar que sumar.sh existe y define una funcion
    [ -x "$HOME/laboratorio/shell/sumar.sh" ]
    grep -q "sumar()" "$HOME/laboratorio/shell/sumar.sh"
    # Verificar que funcione
    output=$(cd "$HOME/laboratorio/shell" && ./sumar.sh 2>&1)
    echo "$output" | grep -q "8"
}

reto7() {
    # Verificar que frutas.sh existe y usa arrays
    [ -x "$HOME/laboratorio/shell/frutas.sh" ]
    grep -q "manzana" "$HOME/laboratorio/shell/frutas.sh"
    output=$(cd "$HOME/laboratorio/shell" && ./frutas.sh 2>&1)
    echo "$output" | grep -q "manzana"
}

reto8() {
    # Verificar que saludo.sh existe y usa $1
    [ -x "$HOME/laboratorio/shell/saludo.sh" ]
    grep -q '\$1' "$HOME/laboratorio/shell/saludo.sh"
    output=$(cd "$HOME/laboratorio/shell" && ./saludo.sh Test 2>&1)
    echo "$output" | grep -q "Test"
}

reto9() {
    # Verificar que registrar.sh existe y crea registro.txt
    [ -x "$HOME/laboratorio/shell/registrar.sh" ]
    output=$(cd "$HOME/laboratorio/shell" && ./registrar.sh 2>&1)
    [ -f "$HOME/laboratorio/shell/registro.txt" ]
    grep -q "Fecha" "$HOME/laboratorio/shell/registro.txt"
}

reto10() {
    # Verificar que verificar_archivo.sh existe y maneja errores
    [ -x "$HOME/laboratorio/shell/verificar_archivo.sh" ]
    grep -q "\-f" "$HOME/laboratorio/shell/verificar_archivo.sh"
    output=$(cd "$HOME/laboratorio/shell" && ./verificar_archivo.sh archivo_inexistente.txt 2>&1)
    echo "$output" | grep -q "no existe"
}

validators=(reto1 reto2 reto3 reto4 reto5 reto6 reto7 reto8 reto9 reto10)
challenge_names=(
    "Crear primer script"
    "Variables y entrada"
    "Condicionales if/else"
    "Bucle for"
    "Bucle while"
    "Funciones"
    "Arrays"
    "Argumentos de linea"
    "Redireccion de salida"
    "Manejo de errores"
)

ejecutar_evaluacion "$UNIT_NAME" "$TOTAL_RETOS" "${validators[@]}"
