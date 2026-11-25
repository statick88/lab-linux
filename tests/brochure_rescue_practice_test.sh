#!/bin/bash
# Comprobaciones públicas estructurales: no ejecuta la práctica.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT/docs/practicas/12-rescate-proyecto.md"
FAILURES=0
ok() { echo "  ✔ $1"; }
fail() { echo "  ✘ $1"; FAILURES=$((FAILURES + 1)); }
need() { grep -Fq -- "$2" "$DOC" && ok "$3" || fail "$3"; }
forbid() { grep -Eq -- "$1" "$DOC" && fail "$2" || ok "$2"; }

[ -f "$DOC" ] || { echo "  ✘ falta docs/practicas/12-rescate-proyecto.md"; exit 1; }
for text in \
    '# XII — Rescate y proyecto integrador' 'XII-inicial' 'red desconectada' \
    'rescate.img' 'fsck -n' 'Imagen sin montar' 'PID=$!' \
    '(*[!0-9]*' 'kill -0 "$PID"' 'lsof -p "$PID"' \
    'strace -f -tt -e trace=openat,read,close -p "$PID"' \
    'timeout 3' 'Resultados esperados y rúbrica trazable (100 puntos)' \
    'Integración previa' 'Apache/Nginx' 'DHCP/redes' 'Cierre y rollback'; do
    need "$DOC" "$text" "incluye: $text"
done
forbid '(^[[:space:]]*(sudo[[:space:]]+)?(mount|umount|mkfs|dd)[[:space:]]|fsck[[:space:]]+(-[ayp]|--(?:yes|preen)))' \
    'sin montaje, creación o reparación de disco'
forbid '(curl|wget|nc[[:space:]]|ssh[[:space:]]|apt(-get)?[[:space:]].*install)' \
    'sin red ni instalación'
forbid '^[[:space:]]*(sudo[[:space:]]+)?(passwd|chpasswd|usermod|useradd|authconfig)([[:space:]]|$)' \
    'sin cambios o evasión de autenticación'
forbid '(systemctl|service)[[:space:]].*(start|restart|reload)' \
    'sin servicios administrados'

if [ "$FAILURES" -eq 0 ]; then
    echo "brochure_rescue_practice_test.sh: PASS"; exit 0
fi
echo "brochure_rescue_practice_test.sh: FAIL ($FAILURES fallos)"; exit 1
