#!/bin/bash
# =============================================================================
# test.sh - Script de Validación de Retos del Laboratorio
# =============================================================================
# Evalúa cada reto individualmente y muestra una calificación final
# con colores ANSI para una experiencia visual moderna.
#
# Uso: ./test.sh  o  evaluar (si se configuró el alias)
# =============================================================================

# ─── Colores ANSI ──────────────────────────────────────────────────────────────
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BLANCO='\033[1;37m'
FONDO_VERDE='\033[42m'
FONDO_ROJO='\033[41m'
GRIS='\033[0;90m'
NEGRITA='\033[1m'
SIN_COLOR='\033[0m'

# ─── Variables de conteo ───────────────────────────────────────────────────────
TOTAL=0
CORRECTAS=0
FALLIDAS=0

# ─── Colores adicionales para celebración ─────────────────────────────────────
Morado='\033[0;35m'
Cyan='\033[0;36m'

# ─── Nombres de los retos ─────────────────────────────────────────────────────
declare -a RETO_NOMBRES=("Navegación" "Creación de Directorios" "Creación de Archivos" "Copia y Movimiento" "Eliminación Limpia" "Permisos con chmod" "Búsqueda de Archivos" "Tuberías y Redirección" "Procesos en Ejecución" "Compresión y Archivos")
declare -a RETO_ICONS=("🧭" "📁" "📄" "📋" "🗑️" "🔒" "🔍" "🔗" "⚙️" "📦")

# ─── Directorio base del laboratorio ───────────────────────────────────────────
LAB_DIR="$HOME/laboratorio"

# ─── Mapa de la frase oculta ──────────────────────────────────────────────────
# Palabra por reto: 1=EL, 2=CONOCIMIENTO, 3=ES, 4=PODER, 5=QUE, 6=DA, 7=LA, 8=PRACTICA, 9=Y, 10=FRASE COMPLETA
declare -a FRASE_PALABRAS=("EL" "CONOCIMIENTO" "ES" "PODER" "QUE" "DA" "LA" "PRACTICA" "Y" "EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA")
FRASE_COMPLETA="EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA Y EL CONOCIMIENTO"

# ─── Funciones de frase oculta ────────────────────────────────────────────────

# Revelar palabra en plantilla.md
revelar_palabra() {
    local reto_num=$1
    local palabra=$2
    local plantilla="$LAB_DIR/plantilla.md"

    if [ ! -f "$plantilla" ]; then
        return
    fi

    # Reemplazar la línea de estado correspondiente al reto
    # Formato: | N | ??? | ⬜ Pendiente |
    sed -i "s/| ${reto_num} | ??? | ⬜ Pendiente |/| ${reto_num} | **${palabra}** | ✅ Completado |/" "$plantilla"

    echo ""
    echo -e "  ${CYAN}🔓 Palabra revelada: ${BLANCO}${palabra}${SIN_COLOR}"
    echo ""
}

# Crear marcador de reto completado
marcar_reto_completado() {
    local reto_num=$1
    local marker="$LAB_DIR/.reto${reto_num}_completado"
    touch "$marker"
}

# Celebrar completar un reto
celebrar_reto() {
    local num=$1
    local palabra=$2
    local icon="${RETO_ICONS[$((num-1))]}"
    local nombre="${RETO_NOMBRES[$((num-1))]}"
    local completados=0
    
    for i in $(seq 1 10); do
        if [ -f "$LAB_DIR/.reto${i}_completado" ]; then
            completados=$((completados + 1))
        fi
    done
    
    echo ""
    echo -e "  ${FONDO_VERDE}${BLANCO}  ${icon} ¡RETO ${num} COMPLETADO!  ${SIN_COLOR}"
    echo ""
    echo -e "  ${CYAN}Palabra revelada:${SIN_COLOR} ${NEGRITA}${AMARILLO}\"${palabra}\"${SIN_COLOR}"
    echo ""
    echo -ne "  ${CYAN}Frase hasta ahora:${SIN_COLOR} "
    for ((i=1; i<=num; i++)); do
        if [ -f "$LAB_DIR/.reto${i}_completado" ]; then
            echo -ne "${AMARILLO}${FRASE_PALABRAS[$((i-1))]} ${SIN_COLOR}"
        fi
    done
    echo ""
    echo ""
    echo -e "  ${GRIS}Progreso: ${completados}/10 retos completados${SIN_COLOR}"
    echo ""
}

# Verificar si todos los retos están completados
verificar_todos_completados() {
    local todos=true
    for i in $(seq 1 10); do
        if [ ! -f "$LAB_DIR/.reto${i}_completado" ]; then
            todos=false
            break
        fi
    done
    echo "$todos"
}

# Mostrar la frase completa
mostrar_frase_completa() {
    local plantilla="$LAB_DIR/plantilla.md"

    echo ""
    echo -e "${FONDO_VERDE}${BLANCO}  ✨ ¡TODOS LOS RETOS COMPLETADOS! ✨  ${SIN_COLOR}"
    echo ""
    echo -e "  ${BLANCO}La frase oculta es:${SIN_COLOR}"
    echo ""
    echo -e "  ${VERDE}  $FRASE_COMPLETA  ${SIN_COLOR}"
    echo ""

    # Actualizar plantilla con frase completa
    if [ -f "$plantilla" ]; then
        sed -i "s|**Frase completa:** _________________________________|**Frase completa:** ${FRASE_COMPLETA}|" "$plantilla" 2>/dev/null || true
        echo -e "  ${CYAN}📝 plantilla.md actualizado con la frase completa.${SIN_COLOR}"
        echo ""
    fi
}

# ─── Funciones auxiliares ──────────────────────────────────────────────────────

# Imprimir separador
separador() {
    echo -e "${CYAN}────────────────────────────────────────────────────────────────${SIN_COLOR}"
}

# Imprimir resultado de un test
resultado_test() {
    local num=$1
    local nombre=$2
    local pass=$3
    
    TOTAL=$((TOTAL + 1))
    
    if [ "$pass" = "true" ]; then
        CORRECTAS=$((CORRECTAS + 1))
        echo -e "  ${FONDO_VERDE}${BLANCO} ✓ PASS ${SIN_COLOR}  Reto ${num}: ${VERDE}${nombre}${SIN_COLOR}"
    else
        FALLIDAS=$((FALLIDAS + 1))
        echo -e "  ${FONDO_ROJO}${BLANCO} ✗ FAIL ${SIN_COLOR}  Reto ${num}: ${ROJO}${nombre}${SIN_COLOR}"
    fi
}

# ─── Inicio del script ─────────────────────────────────────────────────────────
clear
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${SIN_COLOR}"
echo -e "${CYAN}║${SIN_COLOR}  ${BLANCO}  SISTEMA DE EVALUACIÓN - LABORATORIO LINUX${SIN_COLOR}                    ${CYAN}║${SIN_COLOR}"
echo -e "${CYAN}║${SIN_COLOR}  ${AMARILLO}  Fundamentos de Sistemas de Archivos y Terminal${SIN_COLOR}              ${CYAN}║${SIN_COLOR}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${SIN_COLOR}"
echo ""
echo -e "  ${BLANCO}Estudiante:${SIN_COLOR} $(whoami)"
echo -e "  ${BLANCO}Fecha:${SIN_COLOR} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
separador
echo ""

# ─── RETO 1: Navegación ───────────────────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 1] Navegación: /tmp, backup, ~${SIN_COLOR}"
echo ""

test1_pass="true"

# Verificar que /tmp/backup existe y es un directorio
if [ -d "/tmp/backup" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} /tmp/backup existe y es un directorio"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} /tmp/backup NO existe o no es un directorio"
    test1_pass="false"
fi

resultado_test "1" "Navegación" "$test1_pass"
if [ "$test1_pass" = "true" ]; then
    marcar_reto_completado 1
    revelar_palabra 1 "EL"
    celebrar_reto 1 "EL"
fi
echo ""

# ─── RETO 2: Creación de Directorios y Estructura ─────────────────────────────
echo -e "${MAGENTA}  [RETO 2] Creación de Directorios y Estructura${SIN_COLOR}"
echo ""

test2_pass="true"

# Verificar ~/laboratorio/proyectos/web/html
if [ -d "$LAB_DIR/proyectos/web/html" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} ~/laboratorio/proyectos/web/html existe"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} ~/laboratorio/proyectos/web/html NO existe"
    test2_pass="false"
fi

# Verificar ~/laboratorio/proyectos/web/css
if [ -d "$LAB_DIR/proyectos/web/css" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} ~/laboratorio/proyectos/web/css existe"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} ~/laboratorio/proyectos/web/css NO existe"
    test2_pass="false"
fi

resultado_test "2" "Creación de Directorios" "$test2_pass"
if [ "$test2_pass" = "true" ]; then
    marcar_reto_completado 2
    revelar_palabra 2 "CONOCIMIENTO"
    celebrar_reto 2 "CONOCIMIENTO"
fi
echo ""

# ─── RETO 3: Creación y Edición de Archivos ───────────────────────────────────
echo -e "${MAGENTA}  [RETO 3] Creación y Edición de Archivos${SIN_COLOR}"
echo ""

test3_pass="true"

# Verificar index.html existe
if [ -f "$LAB_DIR/proyectos/web/html/index.html" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} index.html existe"
    
    # Verificar contenido exacto de index.html
    if grep -q '<h1>Servidor Linux Abacom</h1>' "$LAB_DIR/proyectos/web/html/index.html"; then
        echo -e "    ${VERDE}✓${SIN_COLOR} index.html contiene el texto correcto"
    else
        echo -e "    ${ROJO}✗${SIN_COLOR} index.html NO contiene '<h1>Servidor Linux Abacom</h1>'"
        test3_pass="false"
    fi
else
    echo -e "    ${ROJO}✗${SIN_COLOR} index.html NO existe en proyectos/web/html/"
    test3_pass="false"
fi

# Verificar main.css existe
if [ -f "$LAB_DIR/proyectos/web/css/main.css" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} main.css existe"
    
    # Verificar contenido de main.css (check properties individually)
    if grep -q 'background-color' "$LAB_DIR/proyectos/web/css/main.css" && grep -q '#f0f0f0' "$LAB_DIR/proyectos/web/css/main.css"; then
        echo -e "    ${VERDE}✓${SIN_COLOR} main.css contiene el estilo correcto"
    else
        echo -e "    ${ROJO}✗${SIN_COLOR} main.css NO contiene background-color con #f0f0f0"
        test3_pass="false"
    fi
else
    echo -e "    ${ROJO}✗${SIN_COLOR} main.css NO existe en proyectos/web/css/"
    test3_pass="false"
fi

resultado_test "3" "Creación y Edición de Archivos" "$test3_pass"
if [ "$test3_pass" = "true" ]; then
    marcar_reto_completado 3
    revelar_palabra 3 "ES"
    celebrar_reto 3 "ES"
fi
echo ""

# ─── RETO 4: Copia y Movimiento ───────────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 4] Copia y Movimiento de Archivos${SIN_COLOR}"
echo ""

test4_pass="true"

# Verificar que index.bak existe
if [ -f "$LAB_DIR/proyectos/web/index.bak" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} index.bak existe (copia realizada)"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} index.bak NO existe en proyectos/web/"
    test4_pass="false"
fi

# Verificar que main.css tiene contenido (indica que se movió correctamente)
if [ -f "$LAB_DIR/proyectos/web/css/main.css" ]; then
    if [ -s "$LAB_DIR/proyectos/web/css/main.css" ]; then
        echo -e "    ${VERDE}✓${SIN_COLOR} main.css existe con contenido"
    else
        echo -e "    ${ROJO}✗${SIN_COLOR} main.css existe pero está vacío"
        test4_pass="false"
    fi
else
    echo -e "    ${ROJO}✗${SIN_COLOR} main.css NO existe en proyectos/web/css/"
    test4_pass="false"
fi

resultado_test "4" "Copia y Movimiento" "$test4_pass"
if [ "$test4_pass" = "true" ]; then
    marcar_reto_completado 4
    revelar_palabra 4 "PODER"
    celebrar_reto 4 "PODER"
fi
echo ""

# ─── RETO 5: Eliminación Limpia ───────────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 5] Eliminación Limpia${SIN_COLOR}"
echo ""

test5_pass="true"

# Verificar que temp_dir NO exista
if [ ! -d "$LAB_DIR/temp_dir" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} temp_dir NO existe (eliminado correctamente)"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} temp_dir AÚN existe (debería haber sido eliminado)"
    test5_pass="false"
fi

resultado_test "5" "Eliminación Limpia" "$test5_pass"
if [ "$test5_pass" = "true" ]; then
    marcar_reto_completado 5
    todos=$(verificar_todos_completados)
    if [ "$todos" = "true" ]; then
        celebrar_reto 5 "QUE"
        mostrar_frase_completa
    else
        revelar_palabra 5 "QUE"
        celebrar_reto 5 "QUE"
    fi
fi
echo ""

# ─── RETO 6: Permisos con chmod ───────────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 6] Permisos con chmod${SIN_COLOR}"
echo ""

test6_pass="true"

# Verificar que secret_dir tiene permisos 755
permisos_dir=$(stat -c "%a" "$LAB_DIR/secret_dir" 2>/dev/null || stat -f "%Lp" "$LAB_DIR/secret_dir" 2>/dev/null)
if [ "$permisos_dir" = "755" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} secret_dir tiene permisos 755 (rwxr-xr-x)"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} secret_dir tiene permisos ${permisos_dir:-desconocidos} (debería ser 755)"
    test6_pass="false"
fi

resultado_test "6" "Permisos con chmod" "$test6_pass"
if [ "$test6_pass" = "true" ]; then
    marcar_reto_completado 6
    revelar_palabra 6 "DA"
    celebrar_reto 6 "DA"
fi
echo ""

# ─── RETO 7: Búsqueda de Archivos ────────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 7] Búsqueda de Archivos${SIN_COLOR}"
echo ""

test7_pass="true"

# Verificar que los archivos ocultos existen
if [ -f "$LAB_DIR/.oculto1.txt" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} .oculto1.txt encontrado"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} .oculto1.txt NO encontrado"
    test7_pass="false"
fi

if [ -f "$LAB_DIR/.oculto2.txt" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} .oculto2.txt encontrado"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} .oculto2.txt NO encontrado"
    test7_pass="false"
fi

resultado_test "7" "Búsqueda de Archivos" "$test7_pass"
if [ "$test7_pass" = "true" ]; then
    marcar_reto_completado 7
    revelar_palabra 7 "LA"
    celebrar_reto 7 "LA"
fi
echo ""

# ─── RETO 8: Tuberías y Redirección ──────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 8] Tuberías y Redirección${SIN_COLOR}"
echo ""

test8_pass="true"

# Verificar que errores.txt existe
if [ -f "$LAB_DIR/errores.txt" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} errores.txt existe"
    
    # Verificar que contiene datos procesados (at least one non-empty line)
    contenido=$(cat "$LAB_DIR/errores.txt" 2>/dev/null)
    if [ -n "$contenido" ]; then
        echo -e "    ${VERDE}✓${SIN_COLOR} errores.txt contiene datos procesados"
    else
        echo -e "    ${ROJO}✗${SIN_COLOR} errores.txt está vacío"
        test8_pass="false"
    fi
else
    echo -e "    ${ROJO}✗${SIN_COLOR} errores.txt NO existe (debe crearse con tuberías)"
    test8_pass="false"
fi

resultado_test "8" "Tuberías y Redirección" "$test8_pass"
if [ "$test8_pass" = "true" ]; then
    marcar_reto_completado 8
    revelar_palabra 8 "PRACTICA"
    celebrar_reto 8 "PRACTICA"
fi
echo ""

# ─── RETO 9: Procesos en Ejecución ───────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 9] Procesos en Ejecución${SIN_COLOR}"
echo ""

test9_pass="true"

# Verificar que watcher.sh ya no está ejecutándose
if ! ps aux 2>/dev/null | grep -q "[w]atcher.sh"; then
    echo -e "    ${VERDE}✓${SIN_COLOR} watcher.sh no está ejecutándose (terminado correctamente)"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} watcher.sh sigue ejecutándose"
    test9_pass="false"
fi

resultado_test "9" "Procesos en Ejecución" "$test9_pass"
if [ "$test9_pass" = "true" ]; then
    marcar_reto_completado 9
    revelar_palabra 9 "Y"
    celebrar_reto 9 "Y"
fi
echo ""

# ─── RETO 10: Compresión y Archivos ──────────────────────────────────────────
echo -e "${MAGENTA}  [RETO 10] Compresión y Archivos${SIN_COLOR}"
echo ""

test10_pass="true"

# Verificar que respaldo.tar.gz existe
if [ -f "$LAB_DIR/respaldo.tar.gz" ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} respaldo.tar.gz existe"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} respaldo.tar.gz NO existe"
    test10_pass="false"
fi

# Verificar que restaurado tiene archivos
restaurados=$(find "$LAB_DIR" -path "*/restaurado/*" -type f 2>/dev/null | wc -l)
if [ "$restaurados" -gt 0 ]; then
    echo -e "    ${VERDE}✓${SIN_COLOR} restaurado contiene ${restaurados} archivos"
else
    echo -e "    ${ROJO}✗${SIN_COLOR} restaurado no tiene archivos extraídos"
    test10_pass="false"
fi

resultado_test "10" "Compresión y Archivos" "$test10_pass"
if [ "$test10_pass" = "true" ]; then
    marcar_reto_completado 10
    todos=$(verificar_todos_completados)
    if [ "$todos" = "true" ]; then
        celebrar_reto 10 "EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA"
        mostrar_frase_completa
    else
        revelar_palabra 10 "EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA"
        celebrar_reto 10 "EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA"
    fi
fi
echo ""

# ─── Resultado Final ───────────────────────────────────────────────────────────
separador
echo ""

# Calcular porcentaje
if [ $TOTAL -gt 0 ]; then
    PORCENTAJE=$(( (CORRECTAS * 100) / TOTAL ))
else
    PORCENTAJE=0
fi

# Mostrar puntaje
echo -e "  ${BLANCO}  RESULTADO FINAL:${SIN_COLOR}"
echo ""
echo -e "  ${BLANCO}  Retos completados:${SIN_COLOR} ${CORRECTAS} / ${TOTAL}"
echo -e "  ${BLANCO}  Porcentaje:${SIN_COLOR} ${PORCENTAJE}%"
echo ""

# Barra de progreso visual
echo -ne "  ["
for ((i=1; i<=TOTAL; i++)); do
    if [ $i -le $CORRECTAS ]; then
        echo -ne "${VERDE}██${SIN_COLOR}"
    else
        echo -ne "${ROJO}██${SIN_COLOR}"
    fi
done
for ((i=TOTAL+1; i<=10; i++)); do
    echo -ne "  "
done
echo -e "]"
echo ""

# Mensaje final según resultado
if [ $CORRECTAS -eq $TOTAL ]; then
    echo -e "  ${FONDO_VERDE}${BLANCO}  🎉 ¡FELICIDADES! ¡Todos los retos completados exitosamente!  ${SIN_COLOR}"
    echo ""
    echo -e "  ${VERDE}Has demostrado un dominio sólido de los fundamentos de${SIN_COLOR}"
    echo -e "  ${VERDE}sistemas de archivos y comandos de terminal en Linux.${SIN_COLOR}"
    echo ""
elif [ $CORRECTAS -ge 3 ]; then
    echo -e "  ${AMARILLO}  ⚠  ¡Buen trabajo! Has completado la mayoría de los retos.${SIN_COLOR}"
    echo ""
    echo -e "  ${AMARILLO}  Revisa los retos que fallaron y vuelve a intentarlos.${SIN_COLOR}"
    echo ""
else
    echo -e "  ${ROJO}  ⚠  Necesitas practicar más. Revisa los retos fallidos.${SIN_COLOR}"
    echo ""
    echo -e "  ${ROJO}  Lee las instrucciones en README.md y vuelve a intentar.${SIN_COLOR}"
    echo ""
fi

# Mostrar retos fallidos si los hay
if [ $FALLIDAS -gt 0 ]; then
    echo -e "  ${ROJO}  Retos pendientes:${SIN_COLOR}"
    [ "$test1_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 1: Navegación"
    [ "$test2_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 2: Creación de Directorios"
    [ "$test3_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 3: Creación y Edición de Archivos"
    [ "$test4_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 4: Copia y Movimiento"
    [ "$test5_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 5: Eliminación Limpia"
    [ "$test6_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 6: Permisos con chmod"
    [ "$test7_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 7: Búsqueda de Archivos"
    [ "$test8_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 8: Tuberías y Redirección"
    [ "$test9_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 9: Procesos en Ejecución"
    [ "$test10_pass" = "false" ] && echo -e "    ${ROJO}→${SIN_COLOR} Reto 10: Compresión y Archivos"
    echo ""
fi

separador
echo -e "  ${CYAN}Escribe 'evaluar' para volver a intentar.${SIN_COLOR}"
echo ""
