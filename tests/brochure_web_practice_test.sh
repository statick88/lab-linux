#!/bin/bash
# Comprobaciones públicas estructurales: no inicia servicios ni realiza HTTP.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0
ok() { echo "  ✔ $1"; }
fail() { echo "  ✘ $1"; FAILURES=$((FAILURES + 1)); }
need() { grep -Fq -- "$2" "$1" && ok "$3" || fail "$3"; }
forbid() { grep -Eq -- "$2" "$1" && fail "$3" || ok "$3"; }

APACHE="$ROOT/docs/practicas/09-apache.md"
NGINX="$ROOT/docs/practicas/10-nginx-apache.md"
for file in "$APACHE" "$NGINX"; do
    [ -f "$file" ] && ok "existe ${file#$ROOT/}" || { fail "falta ${file#$ROOT/}"; continue; }
    forbid "$file" '(systemctl|service)[[:space:]].*(start|restart|reload)' "sin servicios del host"
    grep -E 'https?://' "$file" | grep -Fv '127.0.0.1' >/dev/null && fail "sin HTTP externo" || ok "sin HTTP externo"
done
[ -f "$APACHE" ] && for text in \
    'VirtualHost 127.0.0.1:8080' 'a2enmod headers' 'Require all granted' \
    'ErrorLog' 'CustomLog' 'apachectl -t' "curl --noproxy '*' -i http://127.0.0.1:8080/" 'Rúbrica'; do
    need "$APACHE" "$text" "IX: $text"
done
[ -f "$NGINX" ] && for text in \
    'listen 127.0.0.1:8081;' 'proxy_pass http://127.0.0.1:8080;' \
    'proxy_set_header Host $host;' 'add_header X-Lab-Proxy "TU_NOMBRE";' 'nginx -t' 'access_log' 'error_log' 'Rúbrica'; do
    need "$NGINX" "$text" "X: $text"
done
if [ "$FAILURES" -eq 0 ]; then
    echo "brochure_web_practice_test.sh: PASS"; exit 0
fi
echo "brochure_web_practice_test.sh: FAIL ($FAILURES fallos)"; exit 1
