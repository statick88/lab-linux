#!/bin/bash
# Unit III: Shell Scripting — setup.sh
# Creates the environment and 10 challenges for learning bash scripting

set -e
source /shared/common.sh

UNIT_NAME="unit-III"
UNIT_NUM=3
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Scripting en Shell"

echo -e "${CYAN}Esta unidad ensena los fundamentos del scripting en Bash.${RESET}"
echo -e "${AMARILLO}Completarás 10 retos progresivos.${RESET}\n"

mkdir -p "$HOME/laboratorio/shell"
cd "$HOME/laboratorio/shell"

# Reto 1: Crear tu primer script
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: Crear y ejecutar un script que imprima tu nombre
# Crea un archivo saludar.sh que imprima "Hola, [tu nombre]"
cat > saludar.sh << 'INNER'
#!/bin/bash
echo "Hola, estudiante de Linux"
INNER
chmod +x saludar.sh
./saludar.sh
EOF
chmod +x reto1.sh

# Reto 2: Variables y lectura de entrada
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Crear un script que pida tu nombre y lo imprima
cat > pedir_nombre.sh << 'INNER'
#!/bin/bash
echo -n "¿Como te llamas? "
read nombre
echo "Bienvenido, $nombre"
INNER
chmod +x pedir_nombre.sh
./pedir_nombre.sh
EOF
chmod +x reto2.sh

# Reto 3: Condicionales
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Script con if/else que verifique si un numero es par o impar
cat > par_o_impar.sh << 'INNER'
#!/bin/bash
echo -n "Ingresa un numero: "
read num
if [ $((num % 2)) -eq 0 ]; then
    echo "$num es par"
else
    echo "$num es impar"
fi
INNER
chmod +x par_o_impar.sh
./par_o_impar.sh
EOF
chmod +x reto3.sh

# Reto 4: Bucles for
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Script que imprima los numeros del 1 al 10 usando un bucle for
cat > contar.sh << 'INNER'
#!/bin/bash
for i in {1..10}; do
    echo "Numero: $i"
done
INNER
chmod +x contar.sh
./contar.sh
EOF
chmod +x reto4.sh

# Reto 5: Bucles while
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Script que cuente desde 1 hasta 5 usando while
cat > contar_while.sh << 'INNER'
#!/bin/bash
count=1
while [ $count -le 5 ]; do
    echo "Contador: $count"
    count=$((count + 1))
done
INNER
chmod +x contar_while.sh
./contar_while.sh
EOF
chmod +x reto5.sh

# Reto 6: Funciones
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: Crear una funcion que sume dos numeros
cat > sumar.sh << 'INNER'
#!/bin/bash
sumar() {
    echo $(( $1 + $2 ))
}
resultado=$(sumar 5 3)
echo "5 + 3 = $resultado"
INNER
chmod +x sumar.sh
./sumar.sh
EOF
chmod +x reto6.sh

# Reto 7: Arrays
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: Crear un array e imprimir sus elementos
cat > frutas.sh << 'INNER'
#!/bin/bash
frutas=("manzana" "pera" "naranja" "plátano" "uva")
for fruta in "${frutas[@]}"; do
    echo "Fruta: $fruta"
done
INNER
chmod +x frutas.sh
./frutas.sh
EOF
chmod +x reto7.sh

# Reto 8: Argumentos de linea de comandos
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: Script que reciba un argumento y lo imprima
cat > saludo.sh << 'INNER'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Uso: ./saludo.sh nombre"
    exit 1
fi
echo "Hola, $1"
INNER
chmod +x saludo.sh
./saludo.sh Mundo
EOF
chmod +x reto8.sh

# Reto 9: Redireccion de salida
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Guardar la salida de un comando en un archivo
cat > registrar.sh << 'INNER'
#!/bin/bash
fecha=$(date)
echo "Fecha de ejecucion: $fecha" > registro.txt
echo "Log guardado en registro.txt"
INNER
chmod +x registrar.sh
./registrar.sh
cat registro.txt
EOF
chmod +x reto9.sh

# Reto 10: Script con manejo de errores
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: Script que verifique si un archivo existe antes de leerlo
cat > verificar_archivo.sh << 'INNER'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Uso: ./verificar_archivo.sh archivo"
    exit 1
fi
if [ -f "$1" ]; then
    echo "El archivo existe:"
    ls -la "$1"
else
    echo "Error: El archivo '$1' no existe"
fi
INNER
chmod +x verificar_archivo.sh
./verificar_archivo.sh registro.txt
./verificar_archivo.sh archivo_inexistente.txt
EOF
chmod +x reto10.sh

exito "Entorno de Unit III preparado con 10 retos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver las instrucciones o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"
