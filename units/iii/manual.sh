#!/bin/bash
# Unit III: Shell Scripting — manual.sh
# Interactive guide for learning bash scripting

source /shared/common.sh

UNIT_NAME="unit-III"
banner_unidad 3 "Scripting en Shell"

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  Guia de Scripting en Shell (Bash)                         ║
║  Aprende a automatizar tareas con scripts                   ║
╚══════════════════════════════════════════════════════════════╝

📚 CONCEPTOS CLAVE
═══════════════════

  Un script de shell es un archivo de texto que contiene
  comandos que el shell ejecuta secuencialmente.

  La primera linea '#!/bin/bash' se llama "shebang" y
  indica que el script debe ejecutarse con Bash.

🔧 SINTAXIS BASICA
════════════════════

  Variables
  ─────────
  nombre="valor"          # Asignar (sin espacios)
  echo "$nombre"          # Usar variable
  $(comando)              # Capturar salida de comando
  $#                      # Numero de argumentos
  $1, $2, ...             # Argumentos posicionales
  $@                      # Todos los argumentos

  Condicionales
  ─────────────
  if [ condicion ]; then
      # codigo
  elif [ otra_cond ]; then
      # codigo
  else
      # codigo
  fi

  Bucles
  ──────
  for i in 1 2 3; do echo $i; done
  for i in {1..10}; do echo $i; done
  while [ cond ]; do echo "loop"; done

  Funciones
  ─────────
  mi_funcion() {
      echo "Argumento: $1"
      return 0
  }
  resultado=$(mi_funcion "hola")

🎯 RETOS
══════════

  Los retos estan en ~/laboratorio/shell/reto[1-10].sh
  Ejecuta cada reto con: bash reto1.sh
  Usa 'evaluar' para verificar tu progreso.

💡 EJEMPLOS UTILES
════════════════════

  #!/bin/bash
  echo "Hola, $1"

  # Verificar si un archivo existe
  if [ -f "archivo.txt" ]; then
      echo "Existe"
  fi

  # Contar archivos en un directorio
  count=$(ls -1 | wc -l)
  echo "Hay $count archivos"

  # Crear backup de un archivo
  cp archivo.txt archivo.txt.bak

  # Ejecutar comando y guardar exit code
  comando
  if [ $? -eq 0 ]; then
      echo "Exito"
  fi

📌 COMANDOS UTILES EN SCRIPTS
════════════════════════════════

  echo "texto"              # Imprimir texto
  read variable             # Leer entrada del usuario
  exit 0                    # Terminar con codigo de exito
  exit 1                    # Terminar con codigo de error
  date                      # Fecha y hora actual
  ls -la                    # Listar archivos
  grep "patron" archivo     # Buscar texto en archivo
  wc -l archivo             # Contar lineas
  chmod +x script.sh        # Hacer ejecutable

EOF

echo -e "\n${AMARILLO}Escribe ${CYAN}'evaluar'${AMARILLO} para verificar tu progreso o ${CYAN}'retos'${AMARILLO} para ver los retos.${RESET}"
