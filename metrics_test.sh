#!/bin/bash
# metrics_test.sh — Cronometra cada reto usando los validadores REALES del lab
# Ejecuta como estudiante, usa los test.sh oficiales, mide tiempo por reto
#
# Uso:
#   bash metrics_test.sh                       # Modo interactivo (prompt para student ID)
#   bash metrics_test.sh --batch               # Sin prompts, usa $USER
#   bash metrics_test.sh --batch --student X   # Sin prompts, student ID = X
#
# Requiere: shared/metrics.sh (fallback a logica inline si no existe)

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Cargar metrics.sh si existe ─────────────────────────────
METRICS_SH_AVAILABLE=0
if [ -f "${SCRIPT_DIR}/shared/metrics.sh" ]; then
    source "${SCRIPT_DIR}/shared/metrics.sh" 2>/dev/null && METRICS_SH_AVAILABLE=1
fi

# ── Fallback: si metrics.sh no esta disponible ──────────────
# Mantener la logica inline como fallback para ejecucion standalone
FALLBACK_CSV="/tmp/metrics_results.csv"
FALLBACK_SUMMARY="/tmp/metrics_summary.txt"

# Roman numerals mapping
ROMAN=("I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" "XI")
UNIT_NAMES=(
    "Fundamentos de Linux y WSL2"
    "Gestion de Paquetes y APT"
    "Scripting Bash"
    "Gestion de Usuarios y SSH"
    "Gestion de Procesos y systemd"
    "Gestion de Almacenamiento y LVM"
    "Hardening del Sistema"
    "Contenedores con Docker"
    "Servidor Web con Nginx"
    "Certificados SSL y HTTPS"
    "Respaldo y Recuperacion"
)

# ── Parse flags ─────────────────────────────────────────────
BATCH_MODE=0
STUDENT_FLAG=""

while [ $# -gt 0 ]; do
    case "$1" in
        --batch) BATCH_MODE=1; shift ;;
        --student)
            [ -n "${2:-}" ] && STUDENT_FLAG="$2"
            shift 2
            ;;
        *) shift ;;
    esac
done

# ── Timer function (fallback-compatible) ────────────────────
time_ms() {
    if [ "$METRICS_SH_AVAILABLE" -eq 1 ]; then
        metrics_time_ms
    else
        # Fallback: date +%s%N with fallback to seconds
        local ns
        ns=$(date +%s%N 2>/dev/null)
        if [ ${#ns} -gt 3 ] && [ "$ns" != "%N" ]; then
            echo $((ns / 1000000))
        else
            echo $(( $(date +%s) * 1000 ))
        fi
    fi
}

# ── Initialize metrics ──────────────────────────────────────
init_metrics() {
    if [ "$METRICS_SH_AVAILABLE" -eq 1 ]; then
        # Use metrics.sh init with resolved student ID
        local student_id="${STUDENT_FLAG:-}"
        if [ -n "$student_id" ]; then
            metrics_init "$student_id"
        elif [ "$BATCH_MODE" -eq 1 ]; then
            # Batch mode: skip prompt, use $USER
            metrics_init "${USER:-unknown}"
        else
            # Interactive mode: metrics_init handles prompt
            metrics_init
        fi
    else
        # Fallback: initialize inline CSV
        FALLBACK_CSV="/tmp/metrics_results.csv"
        FALLBACK_SUMMARY="/tmp/metrics_summary.txt"
        echo "unit_num,unit_name,reto_num,reto_label,exec_time_ms,passed" > "$FALLBACK_CSV"
        echo "=== LAB LINUX METRICS — $(date) ===" > "$FALLBACK_SUMMARY"
        echo "" >> "$FALLBACK_SUMMARY"
    fi
}

# ── Record a reto result ────────────────────────────────────
record_reto() {
    local unit_num="$1" reto_num="$2" elapsed="$3" passed_str="$4" unit_name="$5"

    if [ "$METRICS_SH_AVAILABLE" -eq 1 ]; then
        local roman="${ROMAN[$((unit_num-1))]}"
        metrics_record "${roman}" "$reto_num" "$passed_str" "$elapsed" ""
    else
        echo "${unit_num},${unit_name},${reto_num},R${reto_num},${elapsed},${passed_str}" >> "$FALLBACK_CSV"
    fi
}

# ── Print reto result to stdout ─────────────────────────────
print_reto() {
    local unit_num="$1" reto_num="$2" elapsed="$3" passed_str="$4"
    echo "  U${unit_num}.R${reto_num}: ${elapsed}ms [${passed_str}]"
}

# ── Print unit subtotal ─────────────────────────────────────
print_unit_subtotal() {
    local roman="$1" unit_time="$2" unit_passed="$3"
    echo ""
    echo "  Subtotal Unidad ${roman}: ${unit_time}ms | ${unit_passed}/10 pasaron"
}

# ── Run one reto validator and measure time ──────────────────
run_reto() {
    local unit_num=$1
    local reto_num=$2
    local roman="${ROMAN[$((unit_num-1))]}"
    local unit_name="${UNIT_NAMES[$((unit_num-1))]}"

    TOTAL=$((TOTAL + 1))

    local test_file="/app/units/${roman}/test.sh"

    if [ ! -f "$test_file" ]; then
        record_reto "$unit_num" "$reto_num" 0 "SKIP" "$unit_name"
        echo "  U${unit_num}.R${reto_num}: [SKIP - test.sh not found]"
        FAILED=$((FAILED + 1))
        return
    fi

    local start=$(time_ms)

    local pass=0
    (
        source /shared/common.sh 2>/dev/null
        source "$test_file" 2>/dev/null
        "reto${reto_num}"
    ) >/dev/null 2>&1 && pass=1

    local end=$(time_ms)
    local elapsed=$((end - start))
    TOTAL_TIME_MS=$((TOTAL_TIME_MS + elapsed))

    local passed_str="PASS"
    [ $pass -eq 0 ] && passed_str="FAIL"

    if [ $pass -eq 1 ]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi

    record_reto "$unit_num" "$reto_num" "$elapsed" "$passed_str" "$unit_name"
    print_reto "$unit_num" "$reto_num" "$elapsed" "$passed_str"
}

# ── Run all retos for a unit ─────────────────────────────────
run_unit() {
    local unit_num=$1
    local roman="${ROMAN[$((unit_num-1))]}"
    local unit_name="${UNIT_NAMES[$((unit_num-1))]}"
    local total_retos=10

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  UNIDAD ${roman} — ${unit_name}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local unit_start=$(time_ms)

    for r in $(seq 1 $total_retos); do
        run_reto "$unit_num" "$r"
    done

    local unit_end=$(time_ms)
    local unit_time=$((unit_end - unit_start))

    # Count passes for this unit
    local unit_passed=0
    if [ "$METRICS_SH_AVAILABLE" -eq 1 ]; then
        local csv_file="${METRICS_STUDENT_DIR}/results.csv"
        if [ -f "$csv_file" ]; then
            unit_passed=$(awk -F, -v u="${ROMAN[$((unit_num-1))]}" '$2==u && $4=="PASS" {c++} END {print c+0}' "$csv_file")
        fi
    else
        unit_passed=$(awk -F, -v u="$unit_num" '$1==u && $6=="PASS" {c++} END {print c+0}' "$FALLBACK_CSV")
    fi

    unit_times+=("$unit_time")
    unit_counts+=("10")
    unit_passes+=("$unit_passed")

    print_unit_subtotal "$roman" "$unit_time" "$unit_passed"
}

# ── Print final summary ─────────────────────────────────────
print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  RESUMEN FINAL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total retos: $TOTAL"
    echo "Pasaron: $PASSED"
    echo "Fallaron: $FAILED"
    echo "Tiempo total: ${TOTAL_TIME_MS}ms ($(echo "scale=1; $TOTAL_TIME_MS/1000" | bc 2>/dev/null || echo "?")s)"
    echo ""

    if [ $TOTAL -gt 0 ]; then
        AVG=$((TOTAL_TIME_MS / TOTAL))
        echo "Tiempo promedio por reto: ${AVG}ms"
    fi

    echo ""
    echo "=== DESGLOSE POR UNIDAD ==="
    for i in "${!unit_times[@]}"; do
        local_idx=$((i+1))
        local_roman="${ROMAN[$i]}"
        local_name="${UNIT_NAMES[$i]}"
        local_time="${unit_times[$i]}"
        local_count="${unit_counts[$i]}"
        local_pass="${unit_passes[$i]}"
        echo "  ${local_roman} (${local_name}): ${local_time}ms | ${local_pass}/${local_count} pasaron"
    done

    echo ""

    # Use metrics_summary if available
    if [ "$METRICS_SH_AVAILABLE" -eq 1 ]; then
        echo "=== RESUMEN POR METRICS.SH ==="
        metrics_summary
    else
        echo "CSV: $FALLBACK_CSV"
        echo "Resumen: $FALLBACK_SUMMARY"
    fi
}

# ============================================================
# MAIN EXECUTION
# ============================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  LAB LINUX — METRICAS DE TIEMPO POR RETO"
echo "  $(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Initialize
TOTAL=0
PASSED=0
FAILED=0
TOTAL_TIME_MS=0
unit_times=()
unit_counts=()
unit_passes=()

init_metrics

# Skip Docker-dependent units if Docker socket not available
SKIP_DOCKER=false
if [ ! -S /var/run/docker.sock ]; then
    SKIP_DOCKER=true
    echo ""
    echo "  ⚠ Docker socket not found — Units VIII-IX will use mock validators"
fi

# Run units I-VII (no Docker dependency)
for u in 1 2 3 4 5 6 7; do
    run_unit "$u"
done

# Unit VIII: Docker
if [ "$SKIP_DOCKER" = false ]; then
    run_unit 8
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  UNIDAD VIII — Contenedores con Docker (MOCK)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for r in 1 2 3 4 5 6 7 8 9 10; do
        run_reto 8 "$r"
    done
fi

# Units IX-XI
for u in 9 10 11; do
    run_unit "$u"
done

# Print summary
print_summary
