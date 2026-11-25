#!/bin/bash
# tests/docker_cleanup_test.sh — flujo público sintético y seguro del reto 10
# Ejecutar: bash tests/docker_cleanup_test.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_TMPDIR=$(mktemp -d)
trap 'rm -rf "$TEST_TMPDIR"' EXIT

failures=0
assert_status() {
    local description="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  ✔ $description"
    else
        echo "  ✘ $description (esperado $expected, obtenido $actual)"
        failures=$((failures + 1))
    fi
}

assert_file() {
    local description="$1" path="$2"
    if [ -f "$path" ]; then
        echo "  ✔ $description"
    else
        echo "  ✘ $description"
        failures=$((failures + 1))
    fi
}

# El setup y validador se ejecutan sin la interfaz del curso.
awk 'NR == 6 { print ": # common.sh no es necesario para reto10"; next } { print }' \
    "$LAB_DIR/units/viii/test.sh" > "$TEST_TMPDIR/evaluator.sh"
awk 'NR == 6 { print "CYAN= RESET= AMARILLO=; banner_unidad() { :; }; exito() { :; }"; next } { print }' \
    "$LAB_DIR/units/viii/setup.sh" > "$TEST_TMPDIR/setup.sh"

mkdir -p "$TEST_TMPDIR/bin" "$TEST_TMPDIR/home"
cat > "$TEST_TMPDIR/bin/docker" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$DOCKER_CALL_LOG"
exit 125
EOF
chmod +x "$TEST_TMPDIR/bin/docker"

export PATH="$TEST_TMPDIR/bin:$PATH"
export HOME="$TEST_TMPDIR/home"
export DOCKER_CALL_LOG="$TEST_TMPDIR/docker.calls"
: > "$DOCKER_CALL_LOG"

source "$TEST_TMPDIR/evaluator.sh"

# Prístino: no existe un plan y el validador debe rechazarlo.
mkdir -p "$HOME/laboratorio/docker"
set +e
reto10
status=$?
set -e
assert_status "reto10 rechaza un entorno prístino sin plan" 1 "$status"

# Flujo público: setup genera inventario y el alumno crea un plan explícito.
set +e
bash "$TEST_TMPDIR/setup.sh"
status=$?
set -e
assert_status "setup sintético prepara el reto 10" 0 "$status"
INVENTORY="$HOME/laboratorio/docker/reto10_inventario.txt"
PLAN="$HOME/laboratorio/docker/reto10_plan.txt"
assert_file "setup genera el inventario sintético" "$INVENTORY"

cat > "$PLAN" <<'EOF'
eliminar id=practica-volumen-viii
eliminar id=practica-contenedor-viii
EOF
set +e
bash "$HOME/laboratorio/docker/reto10.sh"
status=$?
set -e
assert_status "el ayudante acepta los dos ID propios en cualquier orden" 0 "$status"
set +e
reto10
status=$?
set -e
assert_status "el validador acepta el plan válido" 0 "$status"

# Regresión del runner: un fallo de setup no puede reutilizar el ayudante ni el
# plan válido de esta ejecución anterior. Se ejecuta la rama pública exacta.
mkdir -p "$TEST_TMPDIR/runner/units/viii"
printf '%s\n' '#!/bin/bash' 'exit 1' > "$TEST_TMPDIR/runner/units/viii/setup.sh"
chmod +x "$TEST_TMPDIR/runner/units/viii/setup.sh"
awk '/^        # Unit VIII reto10 has a public synthetic workflow\./,/^        # Run every other validator directly\./ { if (!/^        # Run every other validator directly\./) { sub(/^        /, ""); print } }' \
    "$LAB_DIR/run-all-retos.sh" > "$TEST_TMPDIR/runner-reto10.sh"
printf '%s\n' 'fi' >> "$TEST_TMPDIR/runner-reto10.sh"
runner_reto10_called=0
reto10() { runner_reto10_called=$((runner_reto10_called + 1)); return 0; }
SCRIPT_DIR="$TEST_TMPDIR/runner"
unit=viii
i=10
status=PASS
notes=
pass=0
fail=0
source "$TEST_TMPDIR/runner-reto10.sh"
assert_status "el runner falla si setup falla pese a archivos previos" FAIL "$status"
assert_status "el runner registra el fallo de setup" synthetic_setup_failed "$notes"
assert_status "el runner no valida archivos obsoletos" 0 "$runner_reto10_called"
source "$TEST_TMPDIR/evaluator.sh"

# El inventario es un fixture canónico: ni siquiera un recurso propio extra es válido.
printf '%s\n' 'id=practica-extra tipo=volumen nombre=temporal propietario=unidad-viii desechable=si' >> "$INVENTORY"
set +e
bash "$HOME/laboratorio/docker/reto10.sh"
status=$?
set -e
assert_status "el ayudante rechaza un inventario con registro extra" 1 "$status"
set +e
reto10
status=$?
set -e
assert_status "el validador rechaza un inventario con registro extra" 1 "$status"

# El rerun público de setup restaura el fixture canónico y conserva el plan válido.
set +e
bash "$TEST_TMPDIR/setup.sh"
status=$?
set -e
assert_status "el rerun de setup restaura el inventario canónico" 0 "$status"
set +e
reto10
status=$?
set -e
assert_status "el validador acepta el fixture restaurado" 0 "$status"

# Alterar y omitir registros también invalida el fixture completo.
printf '%s\n' \
    'id=practica-contenedor-viii tipo=contenedor nombre=cache-alterado propietario=unidad-viii desechable=si' \
    'id=practica-volumen-viii tipo=volumen nombre=datos-viii propietario=unidad-viii desechable=si' \
    'id=produccion-contenedor tipo=contenedor nombre=shared-cache propietario=cliente desechable=no' \
    'id=produccion-volumen tipo=volumen nombre=datos-clientes propietario=cliente desechable=no' > "$INVENTORY"
set +e
bash "$HOME/laboratorio/docker/reto10.sh"
helper_status=$?
reto10
validator_status=$?
set -e
assert_status "el ayudante rechaza un registro alterado" 1 "$helper_status"
assert_status "el validador rechaza un registro alterado" 1 "$validator_status"

set +e
bash "$TEST_TMPDIR/setup.sh"
status=$?
set -e
assert_status "setup restaura el fixture tras una alteración" 0 "$status"
printf '%s\n' \
    'id=practica-contenedor-viii tipo=contenedor nombre=shared-cache propietario=unidad-viii desechable=si' \
    'id=practica-volumen-viii tipo=volumen nombre=datos-viii propietario=unidad-viii desechable=si' \
    'id=produccion-contenedor tipo=contenedor nombre=shared-cache propietario=cliente desechable=no' > "$INVENTORY"
set +e
bash "$HOME/laboratorio/docker/reto10.sh"
helper_status=$?
reto10
validator_status=$?
set -e
assert_status "el ayudante rechaza un registro faltante" 1 "$helper_status"
assert_status "el validador rechaza un registro faltante" 1 "$validator_status"

set +e
bash "$TEST_TMPDIR/setup.sh"
status=$?
set -e
assert_status "setup restaura el fixture tras un registro faltante" 0 "$status"

# Un recurso ajeno con el mismo tipo nunca queda autorizado.
cat > "$PLAN" <<'EOF'
eliminar id=produccion-contenedor
EOF
set +e
bash "$HOME/laboratorio/docker/reto10.sh"
status=$?
set -e
assert_status "el ayudante rechaza un recurso ajeno" 1 "$status"
set +e
reto10
status=$?
set -e
assert_status "el validador rechaza un plan inseguro" 1 "$status"

# Repetir una decisión válida no modifica el plan ni depende de estado externo.
cat > "$PLAN" <<'EOF'
eliminar id=practica-contenedor-viii
eliminar id=practica-volumen-viii
EOF
cp "$PLAN" "$TEST_TMPDIR/plan.original"
set +e
bash "$HOME/laboratorio/docker/reto10.sh"
first_status=$?
bash "$HOME/laboratorio/docker/reto10.sh"
second_status=$?
set -e
assert_status "la primera ejecución válida tiene resultado determinista" 0 "$first_status"
assert_status "la repetición válida tiene resultado determinista" 0 "$second_status"
if cmp -s "$TEST_TMPDIR/plan.original" "$PLAN"; then
    echo "  ✔ repetir el flujo no modifica el plan"
else
    echo "  ✘ repetir el flujo modificó el plan"
    failures=$((failures + 1))
fi

# El log no se limpia antes de esta comprobación: cualquier invocación falla.
if [ -s "$DOCKER_CALL_LOG" ]; then
    echo "  ✘ el flujo sintético invocó Docker"
    failures=$((failures + 1))
else
    echo "  ✔ el flujo sintético no invoca Docker"
fi

if [ "$failures" -eq 0 ]; then
    echo "docker_cleanup_test.sh: PASS"
    exit 0
fi

echo "docker_cleanup_test.sh: FAIL ($failures fallos)"
exit 1
