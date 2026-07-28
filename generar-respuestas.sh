#!/bin/bash
# generar-respuestas.sh — Genera el archivo final de respuestas del estudiante

WORKSPACE="/home/estudiante/laboratorio"
FECHA=$(date +"%d/%m/%Y %H:%M")
ARCHIVO_SALIDA="$WORKSPACE/mis_respuestas_$(date +%Y%m%d_%H%M%S).md"

# Check if plantilla exists
if [ ! -f "$WORKSPACE/plantilla.md" ]; then
    echo "Error: No se encontró plantilla.md"
    exit 1
fi

# Copy template as base
cp "$WORKSPACE/plantilla.md" "$ARCHIVO_SALIDA"

# Update date
sed -i "s|Fecha de inicio:.*|Fecha de inicio: $FECHA|g" "$ARCHIVO_SALIDA"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Archivo de respuestas generado:"
echo ""
echo "  $ARCHIVO_SALIDA"
echo ""
echo "  Puedes copiarlo a tu máquina con:"
echo "  docker cp laboratorio:$(basename $ARCHIVO_SALIDA) ~/Desktop/"
echo ""
echo "  O usar el alias: copiar-respuestas"
echo "═══════════════════════════════════════════════════"
echo ""
