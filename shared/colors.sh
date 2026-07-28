#!/bin/bash
# Colores ANSI y funciones de formato
ROJO='\033[0;31m'; VERDE='\033[0;32m'; AMARILLO='\033[0;33m'
AZUL='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'; BLANCO='\033[0;37m'
ROJO_B='\033[1;31m'; VERDE_B='\033[1;32m'; AMARILLO_B='\033[1;33m'
AZUL_B='\033[1;34m'; CYAN_B='\033[1;36m'; RESET='\033[0m'

negrita() { echo -e "\033[1m$1${RESET}"; }
separador() { echo -e "${CYAN}──────────────────────────────────────────────────${RESET}"; }
separador_doble() { echo -e "${CYAN}══════════════════════════════════════════════════${RESET}"; }

mostrar_barra_progreso() {
    local completados=$1 total=$2 porcentaje=0 largo=30 llenados=0
    [ "$total" -gt 0 ] && porcentaje=$(( completados * 100 / total ))
    llenados=$(( completados * largo / total ))
    echo -ne "${VERDE}["
    printf '█%.0s' $(seq 1 $llenados 2>/dev/null)
    printf '░%.0s' $(seq 1 $((largo - llenados)) 2>/dev/null)
    echo -e "] ${AMARILLO}${porcentaje}%${RESET} (${completados}/${total})"
}

exito() { echo -e "${VERDE}✔ $1${RESET}"; }
error() { echo -e "${ROJO}✘ $1${RESET}"; }
advertencia() { echo -e "${AMARILLO}⚠ $1${RESET}"; }
info() { echo -e "${CYAN}ℹ $1${RESET}"; }

titulo() { separador_doble; echo -e "${CYAN_B}$1${RESET}"; separador_doble; }
