#!/bin/bash
# =============================================================================
# entrypoint.sh - Punto de entrada del contenedor del laboratorio
# =============================================================================
# Crea alias persistentes, muestra manual interactivo y mantiene
# la terminal interactiva abierta para el estudiante.
# ============================================================================

# Cargar biblioteca compartida
source /shared/common.sh

# ─── Detectar primer inicio y limpiar progreso anterior ──────────────────────
# Si existe el volume pero no hay marker de inicialización, limpiar retos previos
MARKER="$HOME/.lab_initialized"
if [ ! -f "$MARKER" ]; then
    rm -f "$HOME/laboratorio/.reto"_completado 2>/dev/null
    rm -f "$HOME/laboratorio/.reto"*"_completado" 2>/dev/null
    rm -f "/shared/.state/progress" 2>/dev/null
    touch "$MARKER"
fi

# Crear alias persistentes en ~/.bash_aliases ( ~/.bashrc lo carga automáticamente )
if [ ! -f ~/.bash_aliases ] || ! grep -q "alias evaluar=" ~/.bash_aliases 2>/dev/null; then
    cat > ~/.bash_aliases <<'EOF'
alias evaluar='/test.sh'
alias retos='cat ~/laboratorio/README.md'
alias manual='bash /manual.sh'
alias borrar-retos='bash /manual.sh --borrar-retos'
alias revelar-frase='bash /revelar-frase.sh'
alias generar-respuestas='bash /generar-respuestas.sh'
EOF
fi

# Crear script ~/bin/lab con chmod 755
mkdir -p ~/bin
cat > ~/bin/lab <<'SCRIPT'
#!/bin/bash
# lab script — evaluar progreso del laboratorio
echo ""
echo "  📋 Evaluando progreso del laboratorio..."
echo ""
cd ~/laboratorio && /test.sh
SCRIPT
chmod 755 ~/bin/lab
export PATH="$HOME/bin:$PATH"

# Cargar alias en la sesión actual
. ~/.bash_aliases

# ─── Preparar directorios para retos 6-10 ────────────────────────────────────
# Reto 6: Permisos con chmod — crear directorio con permisos restringidos
if [ ! -d "$HOME/laboratorio/secret_dir" ]; then
    mkdir -p "$HOME/laboratorio/secret_dir"
    chmod 000 "$HOME/laboratorio/secret_dir"
fi

# Reto 7: Búsqueda de archivos — crear archivos ocultos para encontrar
if [ ! -f "$HOME/laboratorio/.oculto1.txt" ]; then
    mkdir -p "$HOME/laboratorio/busqueda/profundidad/nivel2"
    touch "$HOME/laboratorio/busqueda/archivo_a.txt"
    touch "$HOME/laboratorio/busqueda/archivo_b.txt"
    touch "$HOME/laboratorio/busqueda/profundidad/oculto1.txt"
    touch "$HOME/laboratorio/busqueda/profundidad/nivel2/oculto2.txt"
    touch "$HOME/laboratorio/.oculto1.txt"
    touch "$HOME/laboratorio/.oculto2.txt"
fi

# Reto 8: Tuberías y Redirección — crear archivo de log para analizar
if [ ! -f "$HOME/laboratorio/acceso.log" ]; then
    cat > "$HOME/laboratorio/acceso.log" <<'LOGEOF'
2024-01-15 08:23:15 INFO  usuario:admin accedio:/home
2024-01-15 08:25:30 ERROR usuario:desconocido accedio:/admin
2024-01-15 09:01:45 INFO  usuario:maria accedio:/proyectos
2024-01-15 09:15:20 WARN  usuario:pedro intento:/root
2024-01-15 09:30:00 INFO  usuario:admin accedio:/etc
2024-01-15 10:05:10 ERROR usuario:robot accedio:/tmp
2024-01-15 10:20:45 INFO  usuario:maria accedio:/var/log
2024-01-15 11:00:00 WARN  usuario:desconocido accedio:/bin
2024-01-15 11:30:30 INFO  usuario:pedro accedio:/usr
2024-01-15 12:00:00 ERROR usuario:admin accedio:/root
LOGEOF
fi

# Reto 9: Procesos — crear script que se ejecuta en background
if [ ! -f "$HOME/laboratorio/watcher.sh" ]; then
    cat > "$HOME/laboratorio/watcher.sh" <<'WATCHEOF'
#!/bin/bash
# Proceso watchdog que se ejecuta en background
while true; do
    sleep 30
done
WATCHEOF
    chmod +x "$HOME/laboratorio/watcher.sh"
fi

# Reto 10: Compresión — crear directorio con archivos para comprimir
if [ ! -d "$HOME/laboratorio/para_comprimir" ]; then
    mkdir -p "$HOME/laboratorio/para_comprimir/documentos"
    mkdir -p "$HOME/laboratorio/para_comprimir/imagenes"
    echo "Contenido del documento 1" > "$HOME/laboratorio/para_comprimir/documentos/doc1.txt"
    echo "Contenido del documento 2" > "$HOME/laboratorio/para_comprimir/documentos/doc2.txt"
    echo "Contenido del documento 3" > "$HOME/laboratorio/para_comprimir/documentos/doc3.txt"
    echo "Datos de imagen 1" > "$HOME/laboratorio/para_comprimir/imagenes/img1.dat"
    echo "Datos de imagen 2" > "$HOME/laboratorio/para_comprimir/imagenes/img2.dat"
    echo " Este es un archivo grande de prueba " > "$HOME/laboratorio/para_comprimir/archivo_grande.txt"
    for ((i=1; i<=20; i++)); do
        echo "Línea de relleno número $i con datos adicionales para hacer el archivo más pesado" >> "$HOME/laboratorio/para_comprimir/archivo_grande.txt"
    done
fi

# Mostrar manual interactivo al iniciar
if [ -f "/manual.sh" ]; then
    bash /manual.sh
else
    # Fallback: mostrar banner si manual.sh no existe
    banner_bienvenida
    echo -e "${AMARILLO}  BIENVENIDO. Escribe 'manual' para ver las instrucciones.${RESET}"
    echo ""
fi

# Mantener la terminal interactiva abierta (-i = interactivo, carga ~/.bashrc)
exec bash -i
