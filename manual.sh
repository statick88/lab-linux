#!/bin/bash
# =============================================================================
# manual.sh - Manual interactivo del laboratorio Linux
# =============================================================================
# Diseñado con principios de cognitive-doc-design:
#   - Lead with the answer: qué aprenderán ANTES del reto
#   - Progressive disclosure: solo lo necesario en cada paso
#   - Chunking: tareas complejas en piezas pequeñas
#   - Signposting: marcadores visuales de progreso
#   - Recognition over recall: hints y referencias de comandos
#   - Interactive engagement: read -p, colores, tracking de progreso
# =============================================================================

# ─── Colores ANSI ──────────────────────────────────────────────────────────────
ROJO=$'\033[0;31m'
VERDE=$'\033[0;32m'
AMARILLO=$'\033[1;33m'
AZUL=$'\033[0;34m'
MAGENTA=$'\033[0;35m'
CYAN=$'\033[0;36m'
BLANCO=$'\033[1;37m'
GRIS=$'\033[0;90m'
FONDO_VERDE=$'\033[42m'
FONDO_ROJO=$'\033[41m'
FONDO_AZUL=$'\033[44m'
FONDO_AMARILLO=$'\033[43m'
FONDO_MAGENTA=$'\033[45m'
NEGRITA=$'\033[1m'
SIN_COLOR=$'\033[0m'

# ─── Directorio base ──────────────────────────────────────────────────────────
LAB_DIR="$HOME/laboratorio"
WORKSPACE="$LAB_DIR"

# ─── CLI: flags de línea de comandos ──────────────────────────────────────────
# Soporta: manual.sh --borrar-retos
if [[ "$1" == "--borrar-retos" ]]; then
    # Cargar funciones necesarias sin mostrar menú
    RETO_NAMES=("Navegación" "Estructura de directorios" "Creación de archivos" "Copia y movimiento" "Eliminación" "Permisos" "Búsqueda" "Tuberías" "Procesos" "Compresión")
    borrar_retos() {
        printf '%b\n' "${AMARILLO}🗑️  Borrando progreso de retos...${SIN_COLOR}"
        echo ""
        local eliminados=0
        for i in $(seq 1 10); do
            if [ -f "$LAB_DIR/.reto${i}_completado" ]; then
                rm -f "$LAB_DIR/.reto${i}_completado"
                printf '%b\n' "  ${VERDE}✓${SIN_COLOR} Reto $i — ${RETO_NAMES[$((i-1))]} eliminado"
                eliminados=$((eliminados + 1))
            fi
        done
        echo ""
        if [ -f "$LAB_DIR/plantilla.md" ]; then
            for i in $(seq 1 10); do
                sed -i '' "s/✅ Resuelto/pending/g" "$LAB_DIR/plantilla.md" 2>/dev/null
                sed -i '' "s/❌ pending/pending/g" "$LAB_DIR/plantilla.md" 2>/dev/null
                sed -i '' "s/^| Reto $i.*|.*|$/| Reto $i | ${RETO_NAMES[$((i-1))]} | ⏳ pending |/g" "$LAB_DIR/plantilla.md" 2>/dev/null
            done
            printf '%b\n' "  ${VERDE}✓${SIN_COLOR} plantilla.md restaurado"
        fi
        echo ""
        if [ $eliminados -eq 0 ]; then
            printf '%b\n' "${AMARILLO}No había retos completados. Todo limpio.${SIN_COLOR}"
        else
            printf '%b\n' "${VERDE}Progreso borrado. ¡Listo para empezar de nuevo!${SIN_COLOR}"
        fi
        echo ""
    }
    borrar_retos
    exit 0
fi

# ─── Palabras de la frase oculta ──────────────────────────────────────────────
declare -a PALABRAS=("EL" "CONOCIMIENTO" "ES" "PODER" "QUE" "DA" "LA" "PRACTICA" "Y" "EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA")
declare -a RETO_NAMES=(
    "Navegación Básica"
    "Estructura de Directorios"
    "Creación de Archivos"
    "Copia y Movimiento"
    "Eliminación Limpia"
    "Permisos con chmod"
    "Búsqueda de Archivos"
    "Tuberías y Redirección"
    "Procesos en Ejecución"
    "Compresión y Archivos"
)
declare -a RETO_ICONS=("🧭" "📁" "✏️" "📋" "🗑️" "🔒" "🔍" "🔗" "⚙️" "📦")

# ─── Funciones auxiliares ──────────────────────────────────────────────────────

# Imprimir línea separadora con estilo
separador() {
    printf '%b\n' "${CYAN}────────────────────────────────────────────────────────────────${SIN_COLOR}"
}

# Imprimir separador doble
separador_doble() {
    printf '%b\n' "${CYAN}══════════════════════════════════════════════════════════════════${SIN_COLOR}"
}

# Banner principal con animación
mostrar_banner() {
    clear
    echo ""
    printf '%b\n' "${CYAN}╔══════════════════════════════════════════════════════════════════╗${SIN_COLOR}"
    printf '%b\n' "${CYAN}║${SIN_COLOR}  ${NEGRITA}${BLANCO}  🐧  LABORATORIO DE LINUX — SISTEMAS DE ARCHIVOS${SIN_COLOR}         ${CYAN}║${SIN_COLOR}"
    printf '%b\n' "${CYAN}║${SIN_COLOR}  ${GRIS}  Aprende navegación, archivos, permisos y más${SIN_COLOR}                ${CYAN}║${SIN_COLOR}"
    printf '%b\n' "${CYAN}╚══════════════════════════════════════════════════════════════════╝${SIN_COLOR}"
    echo ""
}

# Verificar si un reto está completado (marker file)
reto_completado() {
    local num=$1
    [ -f "$LAB_DIR/.reto${num}_completado" ]
}

# Contar retos completados
contar_completados() {
    local count=0
    for i in $(seq 1 10); do
        reto_completado $i && count=$((count + 1))
    done
    echo $count
}

# ─── Borrar todos los retos completados (reiniciar progreso) ─────────────────
borrar_retos() {
    printf '%b\n' "${AMARILLO}🗑️  Borrando progreso de retos...${SIN_COLOR}"
    echo ""
    local eliminados=0
    for i in $(seq 1 10); do
        if [ -f "$LAB_DIR/.reto${i}_completado" ]; then
            rm -f "$LAB_DIR/.reto${i}_completado"
            printf '%b\n' "  ${VERDE}✓${SIN_COLOR} Reto $i — ${RETO_NAMES[$((i-1))]} eliminado"
            eliminados=$((eliminados + 1))
        fi
    done
    echo ""
    # Restaurar plantilla.md
    if [ -f "$LAB_DIR/plantilla.md" ]; then
        for i in $(seq 1 10); do
            sed -i '' "s/✅ Resuelto/pending/g" "$LAB_DIR/plantilla.md" 2>/dev/null
            sed -i '' "s/❌ pending/pending/g" "$LAB_DIR/plantilla.md" 2>/dev/null
            sed -i '' "s/^| Reto $i.*|.*|$/| Reto $i | ${RETO_NAMES[$((i-1))]} | ⏳ pending |/g" "$LAB_DIR/plantilla.md" 2>/dev/null
        done
        printf '%b\n' "  ${VERDE}✓${SIN_COLOR} plantilla.md restaurado"
    fi
    echo ""
    if [ $eliminados -eq 0 ]; then
        printf '%b\n' "${AMARILLO}No había retos completados. Todo limpio.${SIN_COLOR}"
    else
        printf '%b\n' "${VERDE}Progreso borrado. ¡Listo para empezar de nuevo!${SIN_COLOR}"
    fi
    echo ""
}

# Mostrar barra de progreso visual
mostrar_barra_progreso() {
    local completados=$1
    local total=10
    printf '%b' "  ${NEGRITA}Progreso: ${SIN_COLOR}"
    printf '%b' "${GRIS}[${SIN_COLOR}"
    for ((i=1; i<=total; i++)); do
        if [ $i -le $completados ]; then
            printf '%b' "${VERDE}██${SIN_COLOR}"
        else
            printf '%b' "${GRIS}░░${SIN_COLOR}"
        fi
    done
    printf '%b\n' "${GRIS}]${SIN_COLOR} ${VERDE}${completados}/${total}${SIN_COLOR}"
}

# Mostrar estado de todos los retos
mostrar_estado_retos() {
    echo ""
    printf '%b\n' "  ${NEGRITA}Estado de los retos:${SIN_COLOR}"
    echo ""
    for i in $(seq 1 10); do
        local icon="${RETO_ICONS[$((i-1))]}"
        local name="${RETO_NAMES[$((i-1))]}"
        if reto_completado $i; then
            printf '%b\n' "    ${FONDO_VERDE}${BLANCO} ✓ ${SIN_COLOR} ${icon} Reto ${i}: ${VERDE}${name}${SIN_COLOR} ${GRIS}— completado${SIN_COLOR}"
        else
            printf '%b\n' "    ${FONDO_ROJO}${BLANCO} ✗ ${SIN_COLOR} ${icon} Reto ${i}: ${ROJO}${name}${SIN_COLOR} ${GRIS}— pendiente${SIN_COLOR}"
        fi
    done
    echo ""
}

# Actualizar plantilla.md con la palabra revelada
actualizar_plantilla() {
    local num=$1
    local palabra=$2
    local plantilla="$LAB_DIR/plantilla.md"

    if [ -f "$plantilla" ]; then
        # Reemplazar la línea correspondiente del reto en la tabla
        local linea_tabla="| ${num} | ??? | ⬜ Pendiente |"
        local nueva_linea="| ${num} | **${palabra}** | ✅ Completado |"
        sed -i '' "s#${linea_tabla}#${nueva_linea}#" "$plantilla" 2>/dev/null

        # También actualizar la sección del reto específico
        local frase_linea="**Frase revelada:** ⬜ ⬜ ⬜"
        local nueva_frase="**Frase revelada:** 🔓 ${palabra}"
        # Solo reemplazar la primera aparición que coincida con el reto
        local marker_reto="## Reto ${num} —"
        sed -i '' "/${marker_reto}/,/^---$/s#${frase_linea}#${nueva_frase}#" "$plantilla" 2>/dev/null
    fi
}

# Mostrar mensaje de felicitación al completar un reto
felicitacion_reto() {
    local num=$1
    local palabra=$2
    echo ""
    printf '%b\n' "${FONDO_VERDE}${BLANCO}  🎉 ¡RETO ${num} COMPLETADO!  ${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${VERDE}Palabra revelada:${SIN_COLOR} ${NEGRITA}${AMARILLO}\"${palabra}\"${SIN_COLOR}"
    echo ""
    # Mostrar frase parcial construida
    printf '%b' "  ${CYAN}Frase hasta ahora: ${SIN_COLOR}"
    for ((i=1; i<=num; i++)); do
        reto_completado $i && printf '%b' "${AMARILLO}${PALABRAS[$((i-1))]} ${SIN_COLOR}"
    done
    echo ""
    echo ""
    printf '%b\n' "  ${GRIS}Guarda tu progreso y continúa con el siguiente reto.${SIN_COLOR}"
    echo ""
}

# ─── Funciones de cada reto ───────────────────────────────────────────────────

# ─── RETO 1: Navegación Básica ────────────────────────────────────────────────
reto1() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_AZUL}${BLANCO}  🧭 RETO 1: NAVEGACIÓN BÁSICA  ${SIN_COLOR}"
    echo ""

    # Lead with the answer
    printf '%b\n' "  ${NEGRITA}${AMARILLO}¿Qué aprenderás?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Navegar entre directorios y crear carpetas en Linux.${SIN_COLOR}"
    printf '%b\n' "  ${GRIS}Estos son los cimientos de todo lo que viene después.${SIN_COLOR}"
    echo ""
    separador
    echo ""

    # Verificar si ya está completado
    if reto_completado 1; then
        printf '%b\n' "  ${VERDE}✓ Este reto ya fue completado.${SIN_COLOR}"
        printf '%b\n' "  ${GRIS}Palabra revelada: \"${PALABRAS[0]}\"${SIN_COLOR}"
        echo ""
        return 0
    fi

    # Contexto del reto
    printf '%b\n' "  ${NEGRITA}${CYAN}📜 Contexto:${SIN_COLOR}"
    printf '%b\n' "  Estás en un sistema Linux. Necesitas crear un directorio de"
    printf '%b\n' "  respaldo en una ubicación específica del sistema."
    echo ""

    # Paso 1
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 1: Ubicarte en el sistema ─────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Primero, descubre dónde estás:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ pwd${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}Esto muestra el directorio de trabajo actual.${SIN_COLOR}"
    printf '%b\n' "  ${GRIS}Deberías ver algo como: /home/estudiante${SIN_COLOR}"
    echo ""

    # Hinta
    read -p "  ${AMARILLO}💡 Hint: ¿Qué comando muestra tu ubicación? → ${SIN_COLOR}" respuesta1
    if [[ "$respuesta1" == "pwd" ]]; then
        printf '%b\n' "  ${VERDE}¡Correcto! pwd = Print Working Directory${SIN_COLOR}"
    else
        printf '%b\n' "  ${GRIS}El comando es: pwd — pero sigue adelante, lo lograrás.${SIN_COLOR}"
    fi
    echo ""

    # Paso 2
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 2: Navegar a /tmp ────────────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Ahora ve al directorio temporal del sistema:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd /tmp${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}/tmp es un directorio especial donde el sistema almacena${SIN_COLOR}"
    printf '%b\n' "  ${GRIS}archivos temporales. Se limpia al reiniciar.${SIN_COLOR}"
    echo ""

    # Paso 3
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 3: Crear el directorio backup ────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Crea una carpeta llamada 'backup':${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ mkdir backup${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}mkdir = Make Directory (Crear Directorio)${SIN_COLOR}"
    echo ""

    # Paso 4
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 4: Verificar tu creación ─────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Comprueba que el directorio existe:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ ls -la /tmp/${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}Deberías ver 'backup' en la lista de salida.${SIN_COLOR}"
    echo ""

    # Paso 5
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 5: Volver a home ────────────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Regresa a tu directorio personal:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}# El signo ~ siempre representa tu home directory${SIN_COLOR}"
    echo ""

    separador
    echo ""

    # Referencia de comandos
    printf '%b\n' "  ${NEGRITA}${MAGENTA}📖 Referencia rápida:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}pwd${SIN_COLOR}         Muestra directorio actual"
    printf '%b\n' "  ${BLANCO}cd /ruta${SIN_COLOR}     Navegar a una ruta"
    printf '%b\n' "  ${BLANCO}cd ~${SIN_COLOR}         Volver al home"
    printf '%b\n' "  ${BLANCO}mkdir nombre${SIN_COLOR} Crear directorio"
    printf '%b\n' "  ${BLANCO}ls -la${SIN_COLOR}       Listar archivos con detalles"
    echo ""
    separador
    echo ""

    # Verificación
    printf '%b\n' "  ${NEGRITA}${CYAN}✅ Verificación:${SIN_COLOR} Cuando termines, escribe ${BLANCO}evaluar${SIN_COLOR} para comprobar."
    echo ""
    read -p "  ${AMARILLO}¿Completaste el Reto 1? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        # Verificar condiciones
        if [ -d "/tmp/backup" ]; then
            # ¡Éxito!
            touch "$LAB_DIR/.reto1_completado"
            actualizar_plantilla 1 "${PALABRAS[0]}"
            felicitacion_reto 1 "${PALABRAS[0]}"
        else
            printf '%b\n' "  ${ROJO}✗ No se detectó /tmp/backup. Aún no está completo.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Asegúrate de ejecutar: mkdir backup dentro de /tmp${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 2: Estructura de Directorios ────────────────────────────────────────
reto2() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_AZUL}${BLANCO}  📁 RETO 2: ESTRUCTURA DE DIRECTORIOS  ${SIN_COLOR}"
    echo ""

    # Lead with the answer
    printf '%b\n' "  ${NEGRITA}${AMARILLO}¿Qué aprenderás?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Crear carpetas anidadas con mkdir -p — una habilidad${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}esencial para organizar proyectos reales.${SIN_COLOR}"
    echo ""
    separador
    echo ""

    if reto_completado 2; then
        printf '%b\n' "  ${VERDE}✓ Este reto ya fue completado.${SIN_COLOR}"
        printf '%b\n' "  ${GRIS}Palabra revelada: \"${PALABRAS[1]}\"${SIN_COLOR}"
        echo ""
        return 0
    fi

    # Contexto
    printf '%b\n' "  ${NEGRITA}${CYAN}📜 Contexto:${SIN_COLOR}"
    printf '%b\n' "  Estás construyendo la estructura de un proyecto web."
    printf '%b\n' "  Necesitas crear carpetas dentro de otras carpetas."
    echo ""

    # Paso 1
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 1: Navegar al laboratorio ────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Ve al directorio del laboratorio:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~/laboratorio${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}Si no existe, créalo primero con: mkdir -p ~/laboratorio${SIN_COLOR}"
    echo ""

    # Paso 2
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 2: Crear la estructura con -p ────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Crea las carpetas html y css dentro de proyectos/web:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ mkdir -p proyectos/web/html${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ mkdir -p proyectos/web/css${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}${AMARILLO}💡 ¿Por qué -p?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Sin -p, mkdir falla si la carpeta padre no existe.${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Con -p, crea todas las carpetas intermedias necesarias.${SIN_COLOR}"
    echo ""

    # Paso 3
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 3: Verificar la estructura ───────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Mira cómo quedó tu árbol de carpetas:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ tree ~/laboratorio${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}# Si tree no está disponible, usa:${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ ls -R ~/laboratorio${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}Deberías ver:${SIN_COLOR}"
    printf '%b\n' "  ${CYAN}~/laboratorio/${SIN_COLOR}"
    printf '%b\n' "  ${CYAN}└── proyectos/${SIN_COLOR}"
    printf '%b\n' "  ${CYAN}    └── web/${SIN_COLOR}"
    printf '%b\n' "  ${CYAN}        ├── html/${SIN_COLOR}"
    printf '%b\n' "  ${CYAN}        └── css/${SIN_COLOR}"
    echo ""

    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${MAGENTA}📖 Referencia rápida:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}mkdir -p a/b/c${SIN_COLOR}  Crea estructura completa"
    printf '%b\n' "  ${BLANCO}tree ruta${SIN_COLOR}        Muestra árbol de carpetas"
    printf '%b\n' "  ${BLANCO}ls -R ruta${SIN_COLOR}       Lista recursiva"
    echo ""
    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${CYAN}✅ Verificación:${SIN_COLOR} Cuando termines, escribe ${BLANCO}evaluar${SIN_COLOR} para comprobar."
    echo ""
    read -p "  ${AMARILLO}¿Completaste el Reto 2? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ -d "$LAB_DIR/proyectos/web/html" ] && [ -d "$LAB_DIR/proyectos/web/css" ]; then
            touch "$LAB_DIR/.reto2_completado"
            actualizar_plantilla 2 "${PALABRAS[1]}"
            felicitacion_reto 2 "${PALABRAS[1]}"
        else
            printf '%b\n' "  ${ROJO}✗ No se detectaron las carpetas requeridas.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Verifica: ~/laboratorio/proyectos/web/html y css${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 3: Creación de Archivos ─────────────────────────────────────────────
reto3() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_AZUL}${BLANCO}  ✏️  RETO 3: CREACIÓN DE ARCHIVOS  ${SIN_COLOR}"
    echo ""

    # Lead with the answer
    printf '%b\n' "  ${NEGRITA}${AMARILLO}¿Qué aprenderás?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Crear archivos con contenido usando echo y el operador >.${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Es la forma más rápida de generar archivos desde la terminal.${SIN_COLOR}"
    echo ""
    separador
    echo ""

    if reto_completado 3; then
        printf '%b\n' "  ${VERDE}✓ Este reto ya fue completado.${SIN_COLOR}"
        printf '%b\n' "  ${GRIS}Palabra revelada: \"${PALABRAS[2]}\"${SIN_COLOR}"
        echo ""
        return 0
    fi

    # Contexto
    printf '%b\n' "  ${NEGRITA}${CYAN}📜 Contexto:${SIN_COLOR}"
    printf '%b\n' "  Ya tienes la estructura de carpetas. Ahora necesitas crear"
    printf '%b\n' "  archivos con contenido específico dentro de ellas."
    echo ""

    # Paso 1
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 1: Crear index.html ──────────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Navega a la carpeta html y crea el archivo:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~/laboratorio/proyectos/web/html${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ echo '<h1>Servidor Linux Abacom</h1>' > index.html${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}${AMARILLO}💡 ¿Qué hace > ?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}El operador > redirige la salida de un comando a un archivo.${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Si el archivo no existe, lo crea. Si existe, sobrescribe su contenido.${SIN_COLOR}"
    echo ""

    # Paso 2
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 2: Crear main.css ────────────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Ahora crea el archivo de estilos:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~/laboratorio/proyectos/web/css${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ echo 'body { background-color: #f0f0f0; }' > main.css${SIN_COLOR}"
    echo ""

    # Paso 3
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 3: Verificar el contenido ────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Comprueba que los archivos tienen el contenido correcto:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cat ~/laboratorio/proyectos/web/html/index.html${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ cat ~/laboratorio/proyectos/web/css/main.css${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}cat = concatenate (mostrar contenido de archivo)${SIN_COLOR}"
    echo ""

    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${MAGENTA}📖 Referencia rápida:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}echo 'texto' > archivo${SIN_COLOR}   Crear/escribir archivo"
    printf '%b\n' "  ${BLANCO}cat archivo${SIN_COLOR}               Ver contenido"
    printf '%b\n' "  ${BLANCO}>> archivo${SIN_COLOR}                Agregar al final (no sobrescribir)"
    echo ""
    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${CYAN}✅ Verificación:${SIN_COLOR} Cuando termines, escribe ${BLANCO}evaluar${SIN_COLOR} para comprobar."
    echo ""
    read -p "  ${AMARILLO}¿Completaste el Reto 3? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ -f "$LAB_DIR/proyectos/web/html/index.html" ] && [ -f "$LAB_DIR/proyectos/web/css/main.css" ]; then
            if grep -q '<h1>Servidor Linux Abacom</h1>' "$LAB_DIR/proyectos/web/html/index.html" 2>/dev/null && \
               grep -q 'body { background-color: #f0f0f0; }' "$LAB_DIR/proyectos/web/css/main.css" 2>/dev/null; then
                touch "$LAB_DIR/.reto3_completado"
                actualizar_plantilla 3 "${PALABRAS[2]}"
                felicitacion_reto 3 "${PALABRAS[2]}"
            else
                printf '%b\n' "  ${ROJO}✗ Los archivos existen pero el contenido no es correcto.${SIN_COLOR}"
                printf '%b\n' "  ${GRIS}Verifica el texto exacto con cat.${SIN_COLOR}"
                echo ""
            fi
        else
            printf '%b\n' "  ${ROJO}✗ No se detectaron los archivos requeridos.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Verifica: index.html y main.css en las carpetas correctas.${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 4: Copia y Movimiento ───────────────────────────────────────────────
reto4() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_AZUL}${BLANCO}  📋 RETO 4: COPIA Y MOVIMIENTO  ${SIN_COLOR}"
    echo ""

    # Lead with the answer
    printf '%b\n' "  ${NEGRITA}${AMARILLO}¿Qué aprenderás?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Copiar archivos con cp y renombrar con mv — dos comandos${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}que usarás constantemente en tu día a día con Linux.${SIN_COLOR}"
    echo ""
    separador
    echo ""

    if reto_completado 4; then
        printf '%b\n' "  ${VERDE}✓ Este reto ya fue completado.${SIN_COLOR}"
        printf '%b\n' "  ${GRIS}Palabra revelada: \"${PALABRAS[3]}\"${SIN_COLOR}"
        echo ""
        return 0
    fi

    # Contexto
    printf '%b\n' "  ${NEGRITA}${CYAN}📜 Contexto:${SIN_COLOR}"
    printf '%b\n' "  Tienes archivos en tu proyecto web. Necesitas crear una"
    printf '%b\n' "  copia de seguridad y renombrar un archivo existente."
    echo ""

    # Paso 1
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 1: Copiar index.html como respaldo ───────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Crea una copia de index.html llamada index.bak:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~/laboratorio/proyectos/web${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ cp html/index.html index.bak${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}${AMARILLO}💡 cp = copy${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Sintaxis: cp origen destino${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}.bak es una extensión común para archivos de respaldo.${SIN_COLOR}"
    echo ""

    # Paso 2
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 2: Renombrar styles.css ──────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Crea un archivo styles.css, luego renómbralo a main.css:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~/laboratorio/proyectos/web/css${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ echo 'h1 { color: blue; }' > styles.css${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ mv styles.css main.css${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}${AMARILLO}💡 mv = move (mover o renombrar)${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Cuando origen y destino están en la misma carpeta,${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}mv funciona como un renombrado.${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${ROJO}⚠ Importante: styles.css debe DEJAR de existir después de mv.${SIN_COLOR}"
    echo ""

    # Paso 3
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 3: Verificar ─────────────────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Comprueba que todo quedó correcto:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ ls ~/laboratorio/proyectos/web/${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}# Deberías ver: html/ css/ index.bak${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ ls ~/laboratorio/proyectos/web/css/${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}# Deberías ver: main.css (NO styles.css)${SIN_COLOR}"
    echo ""

    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${MAGENTA}📖 Referencia rápida:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}cp origen destino${SIN_COLOR}    Copiar archivo"
    printf '%b\n' "  ${BLANCO}mv origen destino${SIN_COLOR}    Mover o renombrar"
    printf '%b\n' "  ${BLANCO}ls ruta${SIN_COLOR}              Listar contenido"
    echo ""
    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${CYAN}✅ Verificación:${SIN_COLOR} Cuando termines, escribe ${BLANCO}evaluar${SIN_COLOR} para comprobar."
    echo ""
    read -p "  ${AMARILLO}¿Completaste el Reto 4? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ -f "$LAB_DIR/proyectos/web/index.bak" ] && [ ! -f "$LAB_DIR/proyectos/web/css/styles.css" ]; then
            touch "$LAB_DIR/.reto4_completado"
            actualizar_plantilla 4 "${PALABRAS[3]}"
            felicitacion_reto 4 "${PALABRAS[3]}"
        else
            printf '%b\n' "  ${ROJO}✗ Las condiciones no se cumplen.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Verifica: index.bak debe existir y styles.css debe NO existir.${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 5: Eliminación Limpia ───────────────────────────────────────────────
reto5() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_AZUL}${BLANCO}  🗑️  RETO 5: ELIMINACIÓN LIMPIA  ${SIN_COLOR}"
    echo ""

    # Lead with the answer
    printf '%b\n' "  ${NEGRITA}${AMARILLO}¿Qué aprenderás?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Eliminar archivos y directorios de forma segura con rm.${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Un paso avanzado: saber DESHACER lo que creaste.${SIN_COLOR}"
    echo ""
    separador
    echo ""

    if reto_completado 5; then
        printf '%b\n' "  ${VERDE}✓ Este reto ya fue completado.${SIN_COLOR}"
        printf '%b\n' "  ${GRIS}Palabra revelada: \"${PALABRAS[4]}\"${SIN_COLOR}"
        echo ""
        return 0
    fi

    # Contexto
    printf '%b\n' "  ${NEGRITA}${CYAN}📜 Contexto:${SIN_COLOR}"
    printf '%b\n' "  Tienes un directorio temporal lleno de archivos que ya"
    printf '%b\n' "  no necesitas. Es momento de limpiar el sistema."
    echo ""

    # Paso 1
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 1: Navegar al laboratorio ────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Ve al directorio del laboratorio:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ cd ~/laboratorio${SIN_COLOR}"
    echo ""

    # Paso 2
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 2: Verificar que temp_dir existe ─────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Antes de eliminar, confirma que estás en el lugar correcto:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ ls -la${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}Deberías ver temp_dir en la lista.${SIN_COLOR}"
    echo ""

    # Paso 3
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 3: Eliminar temp_dir ─────────────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Elimina el directorio de forma limpia:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ rm -rf temp_dir${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}${AMARILLO}💡 ¿Qué significan las banderas?${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}-r${SIN_COLOR}  Recursive (eliminar contenido recursivamente)"
    printf '%b\n' "  ${BLANCO}-f${SIN_COLOR}  Force (forzar sin pedir confirmación)"
    echo ""
    printf '%b\n' "  ${ROJO}⚠ ¡Cuidado! rm -rf es poderoso. Verifica SIEMPRE la ruta${SIN_COLOR}"
    printf '%b\n' "  ${ROJO}  antes de ejecutarlo. No hay papelera de reciclaje en terminal.${SIN_COLOR}"
    echo ""

    # Paso 4
    printf '%b\n' "  ${NEGRITA}${AZUL}┌─ Paso 4: Confirmar la eliminación ──────────────────┐${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Verifica que temp_dir ya no existe:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${GRIS}\$ ls -la${SIN_COLOR}"
    printf '%b\n' "    ${GRIS}\$ [ ! -d temp_dir ] && echo 'Eliminado correctamente'${SIN_COLOR}"
    echo ""

    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${MAGENTA}📖 Referencia rápida:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}rm archivo${SIN_COLOR}         Eliminar archivo"
    printf '%b\n' "  ${BLANCO}rm -r carpeta${SIN_COLOR}      Eliminar directorio recursivamente"
    printf '%b\n' "  ${BLANCO}rm -rf carpeta${SIN_COLOR}     Forzar eliminación (¡con cuidado!)"
    printf '%b\n' "  ${BLANCO}[ -d nombre ]${SIN_COLOR}      Verificar si existe un directorio"
    echo ""
    separador
    echo ""

    printf '%b\n' "  ${NEGRITA}${CYAN}✅ Verificación:${SIN_COLOR} Cuando termines, escribe ${BLANCO}evaluar${SIN_COLOR} para comprobar."
    echo ""
    read -p "  ${AMARILLO}¿Completaste el Reto 5? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ ! -d "$LAB_DIR/temp_dir" ]; then
            touch "$LAB_DIR/.reto5_completado"
            actualizar_plantilla 5 "${PALABRAS[4]}"
            felicitacion_reto 5 "${PALABRAS[4]}"
        else
            printf '%b\n' "  ${ROJO}✗ temp_dir aún existe. Aún no está completo.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Ejecuta: rm -rf temp_dir dentro de ~/laboratorio${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 6: Permisos con chmod ───────────────────────────────────────────────
reto6() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_CYAN}${BLANCO}  🔒 RETO 6: Permisos con chmod  ${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}Objetivo:${SIN_COLOR} Dominar los permisos de archivos en Linux."
    echo ""
    printf '%b\n' "  ${CYAN}En Linux, cada archivo tiene permisos de lectura (r), escritura (w)"
    printf '%b\n' "  y ejecución (x) para tres categorías: usuario (u), grupo (g) y"
    printf '%b\n' "  otros (o). Se representan así:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${VERDE}rwxrwxrwx${SIN_COLOR} → 777 (todos los permisos)"
    printf '%b\n' "    ${VERDE}rwxr-xr-x${SIN_COLOR} → 755 (lectura/ejecución para todos)"
    printf '%b\n' "    ${VERDE}rw-r--r--${SIN_COLOR} → 644 (solo usuario escribe)"
    printf '%b\n' "    ${VERDE}rwx------${SIN_COLOR} → 700 (solo el usuario)"
    echo ""
    printf '%b\n' "  ${CYAN}El comando ${BLANCO}chmod${CYAN} cambia permisos:${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${VERDE}chmod 755 archivo${SIN_COLOR}     # Asignar permisos numéricos"
    printf '%b\n' "    ${VERDE}chmod u+x archivo${SIN_COLOR}    # Agregar ejecución al usuario"
    printf '%b\n' "    ${VERDE}chmod go-w archivo${SIN_COLOR}   # Quitar escritura a grupo/otros"
    printf '%b\n' "    ${VERDE}chmod -R 644 directorio${SIN_COLOR} # Recursivo para todo el árbol"
    echo ""
    printf '%b\n' "  ${NEGRITA}Tu misión:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}El directorio ${VERDE}secret_dir${BLANCO} tiene permisos ${ROJO}000${BLANCO} (ninguno)."
    printf '%b\n' "  ${BLANCO}Cambia sus permisos a ${VERDE}755${BLANCO} para que puedas entrar y ver su contenido.${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${AMARILLO}Comandos para practicar:${SIN_COLOR}"
    printf '%b\n' "    ls -ld secret_dir          # Ver permisos actuales"
    printf '%b\n' "    chmod 755 secret_dir       # Cambiar a rwxr-xr-x"
    printf '%b\n' "    ls -ld secret_dir          # Verificar cambio"
    echo ""
    separador
    echo ""

    read -p "  ${AMARILLO}¿Completaste el Reto 6? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        local permisos
        permisos=$(stat -c "%a" "$LAB_DIR/secret_dir" 2>/dev/null || stat -f "%Lp" "$LAB_DIR/secret_dir" 2>/dev/null)
        if [ "$permisos" = "755" ]; then
            touch "$LAB_DIR/.reto6_completado"
            actualizar_plantilla 6 "${PALABRAS[5]}"
            felicitacion_reto 6 "${PALABRAS[5]}"
        else
            printf '%b\n' "  ${ROJO}✗ Los permisos de secret_dir son ${permisos}, debería ser 755.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Ejecuta: chmod 755 secret_dir dentro de ~/laboratorio${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 7: Búsqueda de Archivos ────────────────────────────────────────────
reto7() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_CYAN}${BLANCO}  🔍 RETO 7: Búsqueda de Archivos  ${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}Objetivo:${SIN_COLOR} Encontrar archivos usando find, locate y grep."
    echo ""
    printf '%b\n' "  ${CYAN}Linux ofrece herramientas poderosas para buscar archivos:${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${VERDE}find${SIN_COLOR} — búsqueda en tiempo real por nombre, tamaño, fecha:"
    printf '%b\n' "    find . -name '*.txt'              # Por nombre exacto"
    printf '%b\n' "    find . -name '*.txt' -type f      # Solo archivos"
    printf '%b\n' "    find . -name '*.txt' -type d      # Solo directorios"
    printf '%b\n' "    find . -size +1M                   # Archivos mayores a 1MB"
    printf '%b\n' "    find . -mtime -7                   # Modificados en los últimos 7 días"
    echo ""
    printf '%b\n' "  ${VERDE}grep${SIN_COLOR} — búsqueda de contenido dentro de archivos:"
    printf '%b\n' "    grep -r 'texto' .                 # Buscar en todos los archivos"
    printf '%b\n' "    grep -rl 'texto' .                # Solo mostrar nombres"
    printf '%b\n' "    grep -i 'texto' archivo           # Ignorar mayúsculas/minúsculas"
    echo ""
    printf '%b\n' "  ${NEGRITA}Tu misión:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Hay archivos ocultos escondidos en el directorio del laboratorio."
    printf '%b\n' "  Usa ${VERDE}find${BLANCO} y ${VERDE}grep${BLANCO} para localizar los archivos ${ROJO}.oculto1.txt${BLANCO} y"
    printf '%b\n' "  ${ROJO}.oculto2.txt${BLANCO} que están en el directorio raíz de ~/laboratorio.${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${AMARILLO}Comandos para practicar:${SIN_COLOR}"
    printf '%b\n' "    find . -name 'oculto*'            # Archivos que empiezan con 'oculto'"
    printf '%b\n' "    find . -name '.oculto*'           # Archivos ocultos que empiezan con '.oculto'"
    printf '%b\n' "    find . -name '*.txt' -type f      # Todos los .txt"
    echo ""
    separador
    echo ""

    read -p "  ${AMARILLO}¿Completaste el Reto 7? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ -f "$LAB_DIR/.oculto1.txt" ] && [ -f "$LAB_DIR/.oculto2.txt" ]; then
            touch "$LAB_DIR/.reto7_completado"
            actualizar_plantilla 7 "${PALABRAS[6]}"
            felicitacion_reto 7 "${PALABRAS[6]}"
        else
            printf '%b\n' "  ${ROJO}✗ No se encontraron ambos archivos .oculto1.txt y .oculto2.txt.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Ejecuta: find . -name '.oculto*' dentro de ~/laboratorio${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 8: Tuberías y Redirección ──────────────────────────────────────────
reto8() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_CYAN}${BLANCO}  🔗 RETO 8: Tuberías y Redirección  ${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}Objetivo:${SIN_COLOR} Conectar comandos con tuberías y redirigir salida."
    echo ""
    printf '%b\n' "  ${CYAN}Las tuberías (|) conectan la salida de un comando con la entrada"
    printf '%b\n' "  de otro. La redirección (>, >>) envía salida a un archivo:${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${VERDE}|${SIN_COLOR}  Tubería — pasa salida de un comando a otro:"
    printf '%b\n' "    cat archivo.txt | grep 'texto'    # Buscar en archivo"
    printf '%b\n' "    ls -la | wc -l                    # Contar archivos"
    printf '%b\n' "    cat log.txt | sort | uniq          # Ordenar y eliminar duplicados"
    echo ""
    printf '%b\n' "  ${VERDE}>${SIN_COLOR}   Redirección — sobrescribir archivo:"
    printf '%b\n' "    echo 'hola' > archivo.txt         # Crear/sobrescribir"
    printf '%b\n' "  ${VERDE}>>${SIN_COLOR}  Redirección — agregar al final:"
    printf '%b\n' "    echo 'línea' >> archivo.txt       # Agregar al final"
    echo ""
    printf '%b\n' "  ${NEGRITA}Tu misión:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}El archivo ${VERDE}acceso.log${BLANCO} contiene registros de acceso."
    printf '%b\n' "  Usa tuberías para:${SIN_COLOR}"
    printf '%b\n' "  1. Contar cuántas líneas tienen ${ROJO}ERROR${BLANCO}:"
    printf '%b\n' "     ${VERDE}grep 'ERROR' acceso.log | wc -l${SIN_COLOR}"
    printf '%b\n' "  2. Extraer solo los usuarios que hicieron ${ROJO}ERROR${BLANCO}:"
    printf '%b\n' "     ${VERDE}grep 'ERROR' acceso.log | awk '{print \$3}' | sort | uniq${SIN_COLOR}"
    printf '%b\n' "  3. Guardar el resultado en un archivo ${VERDE}errores.txt${SIN_COLOR}:"
    printf '%b\n' "     ${VERDE}grep 'ERROR' acceso.log | awk '{print \$3}' | sort | uniq > errores.txt${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${AMARILLO}Comandos para practicar:${SIN_COLOR}"
    printf '%b\n' "    cat acceso.log                   # Ver el contenido"
    printf '%b\n' "    grep 'ERROR' acceso.log          # Filtrar errores"
    printf '%b\n' "    grep 'ERROR' acceso.log | wc -l  # Contar errores"
    echo ""
    separador
    echo ""

    read -p "  ${AMARILLO}¿Completaste el Reto 8? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ -f "$LAB_DIR/errores.txt" ]; then
            local contenido
            contenido=$(cat "$LAB_DIR/errores.txt" 2>/dev/null)
            if echo "$contenido" | grep -qi "usuario"; then
                touch "$LAB_DIR/.reto8_completado"
                actualizar_plantilla 8 "${PALABRAS[7]}"
                felicitacion_reto 8 "${PALABRAS[7]}"
            else
                printf '%b\n' "  ${ROJO}✗ errors.txt no contiene usuarios extraídos.${SIN_COLOR}"
                printf '%b\n' "  ${GRIS}Revisa los comandos de grep y awk.${SIN_COLOR}"
                echo ""
            fi
        else
            printf '%b\n' "  ${ROJO}✗ errors.txt no existe. Debes crearlo con tuberías.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Ejecuta: grep 'ERROR' acceso.log | awk '{print \$3}' | sort | uniq > errores.txt${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 9: Procesos en Ejecución ───────────────────────────────────────────
reto9() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_CYAN}${BLANCO}  ⚙️  RETO 9: Procesos en Ejecución  ${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}Objetivo:${SIN_COLOR} Gestionar procesos en Linux."
    echo ""
    printf '%b\n' "  ${CYAN}Linux es un sistema multitarea. Puedes ver y controlar procesos:${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${VERDE}ps${SIN_COLOR}    — ver procesos en ejecución:"
    printf '%b\n' "    ps aux                     # Todos los procesos (formato detallado)"
    printf '%b\n' "    ps aux | grep bash         # Buscar procesos bash"
    printf '%b\n' "    ps -ef                     # Formato alternativo"
    echo ""
    printf '%b\n' "  ${VERDE}top${SIN_COLOR}   — vista en tiempo real de procesos (presiona q para salir)"
    printf '%b\n' "  ${VERDE}htop${SIN_COLOR}  — versión mejorada de top (si está instalado)"
    echo ""
    printf '%b\n' "  ${VERDE}kill${SIN_COLOR}  — terminar un proceso:"
    printf '%b\n' "    kill PID                    # Terminar proceso por ID (señal 15/SIGTERM)"
    printf '%b\n' "    kill -9 PID                 # Forzar terminación (señal 9/SIGKILL)"
    printf '%b\n' "    killall nombre              # Terminar todos los procesos con ese nombre"
    echo ""
    printf '%b\n' "  ${VERDE}jobs${SIN_COLOR}  — ver procesos en background de esta sesión"
    printf '%b\n' "  ${VERDE}bg${SIN_COLOR}    — reanudar proceso en background"
    printf '%b\n' "  ${VERDE}fg${SIN_COLOR}    — traer proceso al foreground"
    echo ""
    printf '%b\n' "  ${NEGRITA}Tu misión:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}Hay un proceso ${ROJO}watcher.sh${BLANCO} ejecutándose en background que está"
    printf '%b\n' "  consumiendo recursos innecesariamente. Encuéントralo y termínalo."
    echo ""
    printf '%b\n' "  ${AMARILLO}Pasos:${SIN_COLOR}"
    printf '%b\n' "  1. ${VERDE}ps aux | grep watcher${SIN_COLOR}     # Encontrar el PID"
    printf '%b\n' "  2. ${VERDE}kill <PID>${SIN_COLOR}                   # Terminarlo"
    printf '%b\n' "  3. ${VERDE}ps aux | grep watcher${SIN_COLOR}     # Verificar que ya no existe"
    echo ""
    separador
    echo ""

    read -p "  ${AMARILLO}¿Completaste el Reto 9? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        local watcher_count
        watcher_count=$(ps aux 2>/dev/null | grep -c "[w]atcher.sh" || echo "0")
        if [ "$watcher_count" -eq 0 ]; then
            touch "$LAB_DIR/.reto9_completado"
            actualizar_plantilla 9 "${PALABRAS[8]}"
            felicitacion_reto 9 "${PALABRAS[8]}"
        else
            printf '%b\n' "  ${ROJO}✗ El proceso watcher.sh aún está ejecutándose.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Ejecuta: ps aux | grep watcher para encontrar su PID y kill <PID>${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── RETO 10: Compresión y Archivos Comprimidos ──────────────────────────────
reto10() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_CYAN}${BLANCO}  📦 RETO 10: Compresión y Archivos  ${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${NEGRITA}Objetivo:${SIN_COLOR} Comprimir y extraer archivos con diferentes formatos."
    echo ""
    printf '%b\n' "  ${CYAN}Linux soporta varios formatos de compresión:${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${VERDE}tar.gz${SIN_COLOR} — formato más común en Linux (GNU tar):"
    printf '%b\n' "    tar -czf archivo.tar.gz directorio/    # Comprimir"
    printf '%b\n' "    tar -xzf archivo.tar.gz               # Extraer"
    printf '%b\n' "    tar -tzf archivo.tar.gz               # Listar contenido"
    echo ""
    printf '%b\n' "  ${VERDE}zip/unzip${SIN_COLOR} — formato compatible con Windows:"
    printf '%b\n' "    zip -r archivo.zip directorio/         # Comprimir"
    printf '%b\n' "    unzip archivo.zip                     # Extraer"
    printf '%b\n' "    unzip -l archivo.zip                  # Listar contenido"
    echo ""
    printf '%b\n' "  ${VERDE}gzip${SIN_COLOR} — compresión individual (reemplaza el original):"
    printf '%b\n' "    gzip archivo.txt                      # Genera archivo.txt.gz"
    printf '%b\n' "    gunzip archivo.txt.gz                 # Descomprimir"
    echo ""
    printf '%b\n' "  ${NEGRITA}Tu misión:${SIN_COLOR}"
    printf '%b\n' "  ${BLANCO}El directorio ${VERDE}para_comprimir${BLANCO} tiene archivos de prueba."
    printf '%b\n' "  1. Comprime todo el directorio a ${VERDE}respaldo.tar.gz${SIN_COLOR}"
    printf '%b\n' "  2. Extrae el contenido en un nuevo directorio ${VERDE}restaurado/${SIN_COLOR}"
    printf '%b\n' "  3. Verifica que los archivos extraídos coincidan con los originales${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${AMARILLO}Comandos para practicar:${SIN_COLOR}"
    printf '%b\n' "    ls para_comprimir/                  # Ver contenido original"
    printf '%b\n' "    tar -czf respaldo.tar.gz para_comprimir/"
    printf '%b\n' "    mkdir restaurado && tar -xzf respaldo.tar.gz -C restaurado/"
    printf '%b\n' "    diff -r para_comprimir restaurado/para_comprimir"
    echo ""
    separador
    echo ""

    read -p "  ${AMARILLO}¿Completaste el Reto 10? (s/n) → ${SIN_COLOR}" confirmacion
    echo ""

    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
        if [ -f "$LAB_DIR/respaldo.tar.gz" ]; then
            local restaurados
            restaurados=$(find "$LAB_DIR" -path "*/restaurado/*" -type f 2>/dev/null | wc -l)
            if [ "$restaurados" -gt 0 ]; then
                touch "$LAB_DIR/.reto10_completado"
                actualizar_plantilla 10 "${PALABRAS[9]}"
                felicitacion_reto 10 "${PALABRAS[9]}"
            else
                printf '%b\n' "  ${ROJO}✗ El archivo respaldo.tar.gz existe, pero no se encontraron archivos restaurados.${SIN_COLOR}"
                printf '%b\n' "  ${GRIS}Ejecuta: mkdir restaurado && tar -xzf respaldo.tar.gz -C restaurado/${SIN_COLOR}"
                echo ""
            fi
        else
            printf '%b\n' "  ${ROJO}✗ respaldo.tar.gz no existe. Debes comprimir el directorio primero.${SIN_COLOR}"
            printf '%b\n' "  ${GRIS}Ejecuta: tar -czf respaldo.tar.gz para_comprimir/${SIN_COLOR}"
            echo ""
        fi
    fi
}

# ─── Comando: revelar-frase ───────────────────────────────────────────────────
revelar_frase() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_MAGENTA}${BLANCO}  🔮 REVELAR FRASE OCULTA  ${SIN_COLOR}"
    echo ""

    local completados=$(contar_completados)

    if [ $completados -eq 10 ]; then
        printf '%b\n' "  ${VERDE}¡FELICIDADES! Has completado todos los retos.${SIN_COLOR}"
        echo ""
        printf '%b\n' "  ${NEGRITA}${AMARILLO}  ✨  EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA  ✨${SIN_COLOR}"
        echo ""
        printf '%b\n' "  ${BLANCO}Copia esta frase en tu plantilla.md como respuesta final.${SIN_COLOR}"
        echo ""
        printf '%b\n' "  ${GRIS}\"El conocimiento es el poder más grande que puedes tener.\"${SIN_COLOR}"
        printf '%b\n' "  ${GRIS}— Richard Branson${SIN_COLOR}"
    else
        printf '%b\n' "  ${AMARILLO}Aún te faltan $((10 - completados)) reto(s) por completar.${SIN_COLOR}"
        echo ""
        printf '%b\n' "  ${BLANCO}Palabras descubiertas hasta ahora:${SIN_COLOR}"
        for i in $(seq 1 10); do
            if reto_completado $i; then
                printf '%b\n' "    ${VERDE}✓${SIN_COLOR} Reto ${i}: ${AMARILLO}${PALABRAS[$((i-1))]}${SIN_COLOR}"
            else
                printf '%b\n' "    ${ROJO}✗${SIN_COLOR} Reto ${i}: ${GRIS}???${SIN_COLOR}"
            fi
        done
        echo ""
        printf '%b\n' "  ${CYAN}Completa todos los retos para revelar la frase completa.${SIN_COLOR}"
    fi
    echo ""
    separador_doble
    echo ""
}

# ─── Comando: generar-respuestas ──────────────────────────────────────────────
generar_respuestas() {
    separador_doble
    echo ""
    printf '%b\n' "  ${FONDO_AZUL}${BLANCO}  📄 GENERAR ARCHIVO DE RESPUESTAS  ${SIN_COLOR}"
    echo ""

    local plantilla="$LAB_DIR/plantilla.md"
    if [ ! -f "$plantilla" ]; then
        printf '%b\n' "  ${ROJO}Error: No se encontró plantilla.md${SIN_COLOR}"
        echo ""
        return 1
    fi

    local fecha=$(date +"%d/%m/%Y %H:%M")
    local archivo_salida="$LAB_DIR/mis_respuestas_$(date +%Y%m%d_%H%M%S).md"

    cp "$plantilla" "$archivo_salida"
    sed -i '' "s|Fecha de inicio:.*|Fecha de inicio: $fecha|g" "$archivo_salida" 2>/dev/null

    printf '%b\n' "  ${VERDE}✓ Archivo de respuestas generado:${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${BLANCO}${archivo_salida}${SIN_COLOR}"
    echo ""
    printf '%b\n' "  ${GRIS}Puedes copiarlo a tu máquina con:${SIN_COLOR}"
    printf '%b\n' "  ${GRIS}docker cp laboratorio:$(basename $archivo_salida) ~/Desktop/${SIN_COLOR}"
    echo ""
    separador_doble
    echo ""
}

# ─── Mostrar menú principal ───────────────────────────────────────────────────
mostrar_menu() {
    mostrar_banner

    local completados=$(contar_completados)
    mostrar_barra_progreso $completados
    echo ""

    # ─── Frase secreta: progreso visible ──────────────────────────────────
    local frase_display=""
    local i
    for i in $(seq 1 10); do
        if reto_completado $i; then
            frase_display+="  ${VERDE}${NEGRITA}${PALABRAS[$((i-1))]}${SIN_COLOR}"
        else
            local word_len=${#PALABRAS[$((i-1))]}
            frase_display+="  ${GRIS}$(printf '%*s' "$word_len" '' | tr ' ' '?')${SIN_COLOR}"
        fi
    done
    if [ $completados -eq 10 ]; then
        frase_display="  ${VERDE}${NEGRITA}${PALABRAS[9]}${SIN_COLOR}"
    fi
    printf '%b\n' "${CYAN}  🔐 Frase secreta: ${SIN_COLOR}"
    printf '%b\n' "$frase_display"
    echo ""

    # Si todos completados, mostrar felicitación final
    if [ $completados -eq 10 ]; then
        printf '%b\n' "${FONDO_VERDE}${BLANCO}  🎉 ¡FELICIDADES! ¡Todos los retos completados exitosamente!  ${SIN_COLOR}"
        echo ""
        printf '%b\n' "  ${VERDE}Has demostrado un dominio sólido de los fundamentos de${SIN_COLOR}"
        printf '%b\n' "  ${VERDE}sistemas de archivos y comandos de terminal en Linux.${SIN_COLOR}"
        echo ""
        printf '%b\n' "  ${NEGRITA}${AMARILLO}Tu frase oculta: EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA${SIN_COLOR}"
        echo ""
        mostrar_estado_retos
        printf '%b\n' "  ${CYAN}Escribe ${BLANCO}revelar-frase${SIN_COLOR}${CYAN} para ver la frase completa.${SIN_COLOR}"
        printf '%b\n' "  ${CYAN}Escribe ${BLANCO}generar-respuestas${SIN_COLOR}${CYAN} para descargar tu plantilla.${SIN_COLOR}"
        echo ""
        return 0
    fi

    # Determinar siguiente reto pendiente
    local siguiente=0
    for i in $(seq 1 10); do
        if ! reto_completado $i; then
            siguiente=$i
            break
        fi
    done

    mostrar_estado_retos

    # Mostrar opciones
    printf '%b\n' "  ${NEGRITA}${BLANCO}¿Qué quieres hacer?${SIN_COLOR}"
    echo ""
    printf '%b\n' "    ${CYAN}1${SIN_COLOR})  ${RETO_ICONS[$((siguiente-1))]} Reto ${siguiente}: ${RETO_NAMES[$((siguiente-1))]} ${VERDE}(siguiente)${SIN_COLOR}"
    printf '%b\n' "    ${CYAN}2${SIN_COLOR})  📊 Ver todos los retos"
    printf '%b\n' "    ${CYAN}3${SIN_COLOR})  🔮 Revelar frase oculta"
    printf '%b\n' "    ${CYAN}4${SIN_COLOR})  📄 Generar archivo de respuestas"
    printf '%b\n' "    ${CYAN}5${SIN_COLOR})  🔄 Reiniciar progreso"
    printf '%b\n' "    ${CYAN}6${SIN_COLOR})  🚪 Salir"
    echo ""
    separador
    echo ""

    read -p "  ${AMARILLO}Selecciona una opción (1-6) → ${SIN_COLOR}" opcion
    echo ""

    case $opcion in
        1)
            case $siguiente in
                1) reto1 ;;
                2) reto2 ;;
                3) reto3 ;;
                4) reto4 ;;
                5) reto5 ;;
                6) reto6 ;;
                7) reto7 ;;
                8) reto8 ;;
                9) reto9 ;;
                10) reto10 ;;
            esac
            ;;
        2)
            # Menú para seleccionar cualquier reto
            printf '%b\n' "  ${NEGRITA}Selecciona un reto:${SIN_COLOR}"
            echo ""
            for i in $(seq 1 10); do
                local estado=""
                reto_completado $i && estado=" ${VERDE}(completado)${SIN_COLOR}"
                printf '%b\n' "    ${CYAN}${i}${SIN_COLOR}) ${RETO_ICONS[$((i-1))]} Reto ${i}: ${RETO_NAMES[$((i-1))]}${estado}"
            done
            echo ""
            read -p "  ${AMARILLO}Selecciona reto (1-10) → ${SIN_COLOR}" reto_num
            echo ""
            case $reto_num in
                1) reto1 ;;
                2) reto2 ;;
                3) reto3 ;;
                4) reto4 ;;
                5) reto5 ;;
                6) reto6 ;;
                7) reto7 ;;
                8) reto8 ;;
                9) reto9 ;;
                10) reto10 ;;
                *) printf '%b\n' "  ${ROJO}Opción no válida.${SIN_COLOR}" ;;
            esac
            ;;
        3)
            revelar_frase
            ;;
        4)
            generar_respuestas
            ;;
        5)
            read -p "  ${ROJO}¿Estás seguro? Esto eliminará todo tu progreso (s/n) → ${SIN_COLOR}" confirmar
            if [[ "$confirmar" == "s" || "$confirmar" == "S" ]]; then
                borrar_retos
            fi
            ;;
        6)
            printf '%b\n' "  ${CYAN}¡Hasta luego! 👋${SIN_COLOR}"
            echo ""
            exit 0
            ;;
        *)
            printf '%b\n' "  ${ROJO}Opción no válida. Intenta de nuevo.${SIN_COLOR}"
            echo ""
            ;;
    esac
}

# ─── Bucle principal ──────────────────────────────────────────────────────────
bucle_principal() {
    while true; do
        mostrar_menu
        echo ""
        read -p "  ${GRIS}Presiona Enter para continuar...${SIN_COLOR}" _dummy
        echo ""
    done
}

# ─── Punto de entrada ─────────────────────────────────────────────────────────
# Si se ejecuta con argumentos, manejar comandos directos
case "${1:-}" in
    revelar-frase|revelar_frase)
        revelar_frase
        ;;
    generar-respuestas|generar_respuestas)
        generar_respuestas
        ;;
    reto1) reto1 ;;
    reto2) reto2 ;;
    reto3) reto3 ;;
    reto4) reto4 ;;
    reto5) reto5 ;;
    reto6) reto6 ;;
    reto7) reto7 ;;
    reto8) reto8 ;;
    reto9) reto9 ;;
    reto10) reto10 ;;
    *)
        bucle_principal
        ;;
esac
