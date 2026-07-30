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

reto1_info() {
    separador
    echo -e "${CYAN}Reto 1: Crear primer script${NC}"
    echo ""
    echo "Crea tu primer script en bash llamado saludar.sh"
    echo "debe ser un script que imprima un mensaje en pantalla."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/saludar.sh"
    echo "  2. Agrega la linea #!/bin/bash al inicio"
    echo "  3. Usa echo para imprimir un mensaje"
    echo "  4. Hazlo ejecutable: chmod +x ~/laboratorio/shell/saludar.sh"
    echo "  5. Ejecútalo para probar: ./saludar.sh"
    echo ""
    echo "Comandos útiles: echo, chmod +x"
    separador
}

reto2_info() {
    separador
    echo -e "${CYAN}Reto 2: Variables y entrada${NC}"
    echo ""
    echo "Crea un script pedir_nombre.sh que solicite al usuario"
    echo "su nombre usando la variable NAME y lo muestre en pantalla."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/pedir_nombre.sh"
    echo "  2. Usa read para capturar la entrada del usuario"
    echo "  3. Usa echo para mostrar el nombre ingresado"
    echo "  4. Hazlo ejecutable: chmod +x ~/laboratorio/shell/pedir_nombre.sh"
    echo ""
    echo "Comandos útiles: read, echo"
    echo "Ejemplo: read -p \"¿Cómo te llamas? \" nombre"
    separador
}

reto3_info() {
    separador
    echo -e "${CYAN}Reto 3: Condicionales if/else${NC}"
    echo ""
    echo "Crea un script par_o_impar.sh que determine si un numero"
    echo "ingresado es par o impar usando condicionales."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/par_o_impar.sh"
    echo "  2. Lee un numero del usuario con read"
    echo "  3. Usa un condicional if con la operación aritmética %"
    echo "  4. Imprime si es par o impar"
    echo "  5. Hazlo ejecutable: chmod +x ~/laboratorio/shell/par_o_impar.sh"
    echo ""
    echo "Comandos útiles: read, if, (( ))"
    echo "Ejemplo: if (( numero % 2 == 0 )); then echo \"Par\"; fi"
    separador
}

reto4_info() {
    separador
    echo -e "${CYAN}Reto 4: Bucle for${NC}"
    echo ""
    echo "Crea un script contar.sh que use un bucle for para"
    echo "imprimir los numeros del 1 al 10."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/contar.sh"
    echo "  2. Usa un bucle for con secuencia {1..10}"
    echo "  3. Imprime cada numero con echo \"Numero: \$i\""
    echo "  4. Hazlo ejecutable: chmod +x ~/laboratorio/shell/contar.sh"
    echo ""
    echo "Comandos útiles: for, {1..10}"
    echo "Ejemplo: for i in {1..10}; do echo \"Numero: \$i\"; done"
    separador
}

reto5_info() {
    separador
    echo -e "${CYAN}Reto 5: Bucle while${NC}"
    echo ""
    echo "Crea un script contar_while.sh que use un bucle while"
    echo "para contar de 1 a 5."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/contar_while.sh"
    echo "  2. Inicializa una variable contador en 1"
    echo "  3. Usa un bucle while con la condición -le 5"
    echo "  4. Incrementa el contador con (( contador++ ))"
    echo "  5. Hazlo ejecutable: chmod +x ~/laboratorio/shell/contar_while.sh"
    echo ""
    echo "Comandos útiles: while, -le, (( ))"
    echo "Ejemplo: while [ \$contador -le 5 ]; do ...; (( contador++ )); done"
    separador
}

reto6_info() {
    separador
    echo -e "${CYAN}Reto 6: Funciones${NC}"
    echo ""
    echo "Crea un script sumar.sh que defina una funcion llamada"
    echo "sumar que reciba dos argumentos y devuelva la suma."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/sumar.sh"
    echo "  2. Define la funcion: sumar() { echo \$(( \$1 + \$2 )); }"
    echo "  3. Llama a la funcion con valores de ejemplo"
    echo "  4. Hazlo ejecutable: chmod +x ~/laboratorio/shell/sumar.sh"
    echo ""
    echo "Comandos útiles: funciones, \$1, \$2, \$(( ))"
    echo "Ejemplo: sumar() { echo \$(( \$1 + \$2 )); }"
    separador
}

reto7_info() {
    separador
    echo -e "${CYAN}Reto 7: Arrays${NC}"
    echo ""
    echo "Crea un script frutas.sh que use un array para almacenar"
    echo "al menos 3 frutas y muestre cada una en pantalla."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/frutas.sh"
    echo "  2. Define un array: frutas=(manzana pera uva)"
    echo "  3. Recorre el array con un bucle for"
    echo "  4. Imprime cada fruta"
    echo "  5. Hazlo ejecutable: chmod +x ~/laboratorio/shell/frutas.sh"
    echo ""
    echo "Comandos útiles: arrays, for, \${array[@]}"
    echo "Ejemplo: for fruta in \${frutas[@]}; do echo \$fruta; done"
    separador
}

reto8_info() {
    separador
    echo -e "${CYAN}Reto 8: Argumentos de linea${NC}"
    echo ""
    echo "Crea un script saludo.sh que reciba un argumento"
    echo "(el nombre) y salude al usuario."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/saludo.sh"
    echo "  2. Usa \$1 para acceder al primer argumento"
    echo "  3. Imprime un saludo: echo \"Hola \$1\""
    echo "  4. Hazlo ejecutable: chmod +x ~/laboratorio/shell/saludo.sh"
    echo "  5. Prueba: ./saludo.sh Carlos"
    echo ""
    echo "Comandos útiles: \$1, \$2, \$#"
    echo "Ejemplo: echo \"Hola \$1, bienvenido\""
    separador
}

reto9_info() {
    separador
    echo -e "${CYAN}Reto 9: Redireccion de salida${NC}"
    echo ""
    echo "Crea un script registrar.sh que guarde información"
    echo "en un archivo llamado registro.txt usando redirección."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/registrar.sh"
    echo "  2. Usa echo con redirección >> para escribir en registro.txt"
    echo "  3. Guarda la fecha y algún mensaje"
    echo "  4. Hazlo ejecutable: chmod +x ~/laboratorio/shell/registrar.sh"
    echo "  5. Ejecútalo y verifica: cat ~/laboratorio/shell/registro.txt"
    echo ""
    echo "Comandos útiles: >>, >, date"
    echo "Ejemplo: echo \"Fecha: \$(date)\" >> registro.txt"
    separador
}

reto10_info() {
    separador
    echo -e "${CYAN}Reto 10: Manejo de errores${NC}"
    echo ""
    echo "Crea un script verificar_archivo.sh que reciba un nombre"
    echo "de archivo y verifique si existe, mostrando un mensaje"
    echo "de error si no lo encuentra."
    echo ""
    echo "Pasos:"
    echo "  1. Crea el archivo: nano ~/laboratorio/shell/verificar_archivo.sh"
    echo "  2. Usa un condicional if con -f para verificar el archivo"
    echo "  3. Si no existe, muestra: \"no existe\""
    echo "  4. Si existe, muestra confirmación"
    echo "  5. Hazlo ejecutable: chmod +x ~/laboratorio/shell/verificar_archivo.sh"
    echo ""
    echo "Comandos útiles: if, -f, -e, else"
    echo "Ejemplo: if [ -f \"\$1\" ]; then echo \"Existe\"; else echo \"no existe\"; fi"
    separador
}
