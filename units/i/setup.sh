#!/bin/bash
# Unit I: Fundamentos de Linux y WSL2 — setup.sh
# Creates environment and 10 theoretical multiple-choice challenges

set -e
source /shared/common.sh

UNIT_NAME="unit-I"
UNIT_NUM=1
export TOTAL_RETOS=10

banner_unidad "$UNIT_NUM" "Fundamentos de Linux y WSL2"

echo -e "${CYAN}Esta unidad cubre: navegación FHS, comandos esenciales, permisos y WSL2.${RESET}"
echo -e "${AMARILLO}Completarás 10 preguntas teóricas de selección múltiple.${RESET}\n"

mkdir -p "$HOME/laboratorio/fundamentos"
cd "$HOME/laboratorio/fundamentos"

# ============================================================
# Reto 1: Jerarquía FHS
# ============================================================
cat > reto1.sh << 'EOF'
#!/bin/bash
# Reto 1: ¿Cuál es el propósito del directorio /etc en la jerarquía FHS?
cat << 'PREGUNTA'
===========================================
RETO 1 — Jerarquía FHS: Directorio /etc
===========================================

¿Cuál es el propósito principal del directorio /etc 
en el Filesystem Hierarchy Standard (FHS)?

A) Almacenar archivos temporales del sistema
B) Contener archivos de configuración del sistema
C) Guardar logs y archivos variables
D) Almacenar binarios de usuario

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    B) echo "✓ Correcto: /etc contiene archivos de configuración del sistema"; exit 0 ;;
    *) echo "✗ Incorrecto: /etc es para configuración del sistema (respuesta B)"; exit 1 ;;
esac
EOF
chmod +x reto1.sh

# ============================================================
# Reto 2: Diferencia entre /var y /tmp
# ============================================================
cat > reto2.sh << 'EOF'
#!/bin/bash
# Reto 2: Diferencia entre /var y /tmp
cat << 'PREGUNTA'
===========================================
RETO 2 — Directorios variables: /var vs /tmp
===========================================

¿Cuál es la diferencia principal entre /var y /tmp?

A) /var es para archivos temporales, /tmp para logs persistentes
B) /var persiste entre reinicios, /tmp se limpia al arranque
C) Ambos son iguales, solo cambia el nombre
D) /var es de solo lectura, /tmp es de lectura/escritura

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    B) echo "✓ Correcto: /var persiste (logs, spool), /tmp se limpia al reinicio"; exit 0 ;;
    *) echo "✗ Incorrecto: /var persiste, /tmp es temporal (respuesta B)"; exit 1 ;;
esac
EOF
chmod +x reto2.sh

# ============================================================
# Reto 3: Comando para ver directorio actual
# ============================================================
cat > reto3.sh << 'EOF'
#!/bin/bash
# Reto 3: Comando pwd
cat << 'PREGUNTA'
===========================================
RETO 3 — Navegación: Comando pwd
===========================================

¿Qué comando muestra el directorio de trabajo actual (ruta absoluta)?

A) ls
B) cd
C) pwd
D) dir

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    C) echo "✓ Correcto: pwd = Print Working Directory"; exit 0 ;;
    *) echo "✗ Incorrecto: pwd muestra el directorio actual (respuesta C)"; exit 1 ;;
esac
EOF
chmod +x reto3.sh

# ============================================================
# Reto 4: Listar archivos ocultos
# ============================================================
cat > reto4.sh << 'EOF'
#!/bin/bash
# Reto 4: Ver archivos ocultos
cat << 'PREGUNTA'
===========================================
RETO 4 — Listar archivos: ocultos
===========================================

¿Qué opción de 'ls' muestra archivos ocultos (los que empiezan con punto)?

A) -h
B) -l
C) -a
D) -r

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    C) echo "✓ Correcto: ls -a muestra todos (all), incluyendo ocultos"; exit 0 ;;
    *) echo "✗ Incorrecto: -a = all (respuesta C)"; exit 1 ;;
esac
EOF
chmod +x reto4.sh

# ============================================================
# Reto 5: Permisos octales
# ============================================================
cat > reto5.sh << 'EOF'
#!/bin/bash
# Reto 5: Permisos 755
cat << 'PREGUNTA'
===========================================
RETO 5 — Permisos: Significado de 755
===========================================

¿Qué permisos otorga 'chmod 755 archivo'?

A) Propietario: rwx | Grupo: r-x | Otros: r-x
B) Propietario: rw- | Grupo: r-- | Otros: r--
C) Propietario: rwx | Grupo: rwx | Otros: rwx
D) Propietario: r-x | Grupo: r-x | Otros: r-x

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    A) echo "✓ Correcto: 7=rwx, 5=r-x, 5=r-x"; exit 0 ;;
    *) echo "✗ Incorrecto: 7=rwx(4+2+1), 5=r-x(4+0+1) (respuesta A)"; exit 1 ;;
esac
EOF
chmod +x reto5.sh

# ============================================================
# Reto 6: WSL2 - Integración Windows/Linux
# ============================================================
cat > reto6.sh << 'EOF'
#!/bin/bash
# Reto 6: WSL2
cat << 'PREGUNTA'
===========================================
RETO 6 — WSL2: Diferencia clave con WSL1
===========================================

¿Cuál es la diferencia arquitectural principal de WSL2 respecto a WSL1?

A) WSL2 usa una VM ligera con kernel Linux real; WSL1 traduce syscalls
B) WSL2 es más lento pero más compatible
C) WSL1 tiene kernel Linux; WSL2 usa traducción
D) No hay diferencia, son iguales

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    A) echo "✓ Correcto: WSL2 = VM ligera + kernel Linux real"; exit 0 ;;
    *) echo "✗ Incorrecto: WSL2 tiene kernel Linux real via VM (respuesta A)"; exit 1 ;;
esac
EOF
chmod +x reto6.sh

# ============================================================
# Reto 7: Montaje de disco en Linux
# ============================================================
cat > reto7.sh << 'EOF'
#!/bin/bash
# Reto 7: mount
cat << 'PREGUNTA'
===========================================
RETO 7 — Almacenamiento: Comando mount
===========================================

¿Qué comando se usa para montar un sistema de archivos en un directorio?

A) fsck
B) mount
C) fdisk
D) mkfs

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    B) echo "✓ Correcto: mount une un FS al árbol de directorios"; exit 0 ;;
    *) echo "✗ Incorrecto: mount monta, mkfs formatea, fdisk particiona (respuesta B)"; exit 1 ;;
esac
EOF
chmod +x reto7.sh

# ============================================================
# Reto 8: Diferencia entre usuario root y usuario normal
# ============================================================
cat > reto8.sh << 'EOF'
#!/bin/bash
# Reto 8: UID 0
cat << 'PREGUNTA'
===========================================
RETO 8 — Usuarios: Identificador root
===========================================

¿Qué UID (User ID) tiene siempre el usuario root en Linux?

A) 1
B) 1000
C) 0
D) 65535

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    C) echo "✓ Correcto: root siempre tiene UID 0"; exit 0 ;;
    *) echo "✗ Incorrecto: root = UID 0 (respuesta C)"; exit 1 ;;
esac
EOF
chmod +x reto8.sh

# ============================================================
# Reto 9: Redirección y pipes
# ============================================================
cat > reto9.sh << 'EOF'
#!/bin/bash
# Reto 9: Pipe
cat << 'PREGUNTA'
===========================================
RETO 9 — Redirección: Símbolo de pipe
===========================================

¿Qué símbolo se usa para encadenar la salida de un comando 
como entrada de otro (pipe)?

A) >
B) <
C) |
D) >>

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    C) echo "✓ Correcto: | (pipe) conecta stdout de uno a stdin del otro"; exit 0 ;;
    *) echo "✗ Incorrecto: | es el pipe (respuesta C)"; exit 1 ;;
esac
EOF
chmod +x reto9.sh

# ============================================================
# Reto 10: Comando para ver espacio en disco
# ============================================================
cat > reto10.sh << 'EOF'
#!/bin/bash
# Reto 10: df -h
cat << 'PREGUNTA'
===========================================
RETO 10 — Espacio en disco: df -h
===========================================

¿Qué comando muestra el espacio disponible en disco 
de forma legible (human-readable)?

A) du -h
B) df -h
C) ls -h
D) free -h

PREGUNTA

echo -n "Tu respuesta (A/B/C/D): "
read -r respuesta
case "${respuesta^^}" in
    B) echo "✓ Correcto: df -h = disk free human-readable"; exit 0 ;;
    *) echo "✗ Incorrecto: df = disk free, du = disk usage (respuesta B)"; exit 1 ;;
esac
EOF
chmod +x reto10.sh

exito "Entorno de Unit I preparado con 10 retos teóricos"
echo -e "${AMARILLO}Escribe ${CYAN}'manual'${AMARILLO} para ver la guía o ${CYAN}'evaluar'${AMARILLO} para evaluar.${RESET}"