#!/bin/bash
# revelar-frase.sh — Muestra la frase oculta cuando todos los retos están completos

WORKSPACE="/home/estudiante/laboratorio"
FRASE_COMPLETA="EL CONOCIMIENTO ES PODER QUE DA LA PRACTICA"

# Check if all 10 reto completions exist
COMPLETADOS=0
for i in $(seq 1 10); do
    if [ -f "$WORKSPACE/.reto${i}_completado" ]; then
        COMPLETADOS=$((COMPLETADOS + 1))
    fi
done

if [ "$COMPLETADOS" -eq 10 ]; then
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "  ¡FELICIDADES! Has completado todos los retos."
    echo ""
    echo "  La frase oculta es:"
    echo ""
    echo "  ✨  $FRASE_COMPLETA  ✨"
    echo ""
    echo "  Copia esta frase en tu plantilla.md como respuesta final."
    echo "═══════════════════════════════════════════════════"
    echo ""
else
    echo ""
    echo "  Aún te faltan $((10 - COMPLETADOS)) reto(s) por completar."
    echo "  Continúa trabajando para revelar la frase completa."
    echo ""
fi
