#!/bin/bash
# shared/metrics.sh — Modulo de metricas del lab-linux
# Recolecta timing, estado y progreso por reto en CSV persistente.
# Sin dependencias externas. Integra via guard-check: METRICS_INITIALIZED=1
#
# API:
#   metrics_init [student_id]          — Inicializa sesion (idempotente)
#   metrics_record <unit> <reto> <status> <ms> [output]  — Append CSV
#   metrics_summary [csv_path]         — Imprime resumen por unidad
#   metrics_report [--csv] [--html]    — Genera reportes
#   metrics_cleanup [retention_days]   — Elimina archivos viejos (default 30)
#   metrics_time_ms                    — Retorna milisegundos actuales

# ── Estado global ──────────────────────────────────────────
METRICS_INITIALIZED=0
METRICS_STUDENT_ID=""
METRICS_DIR=""
METRICS_STUDENT_DIR=""

# ── Helpers internos ───────────────────────────────────────

# Log warn-once (evita spam en sesiones largas)
_metrics_warned=""
_metrics_log() {
    local level="$1" msg="$2"
    local key="${level}:${msg}"
    #允许多次warn para errores diferentes
    case "$_metrics_warned" in
        *"|${key}|"*) return 0 ;;
    esac
    _metrics_warned="${_metrics_warned}${key}|"
    case "$level" in
        WARN) echo "[metrics WARN] $msg" >&2 ;;
        ERR)  echo "[metrics ERR] $msg" >&2 ;;
    esac
}

# Timer: milisegundos desde epoch. Fallback automatico si %N no disponible.
_metrics_time_ms() {
    local ns
    ns=$(date +%s%N 2>/dev/null)
    # Si %N no soportado, date retorna literal "%N" o algo corto
    if [ ${#ns} -gt 3 ] && [ "$ns" != "%N" ]; then
        echo $((ns / 1000000))
    else
        echo $(( $(date +%s) * 1000 ))
    fi
}

# Alias publico para el timer
metrics_time_ms() { _metrics_time_ms; }

# RFC 4180 CSV escaping: envolver en comillas si contiene , " o newline
_metrics_csv_escape() {
    local val="$1"
    # Si vacio, retornar campo vacio entre comillas
    [ -z "$val" ] && { echo '""'; return; }
    # Si contiene comilla doble, escapar duplicando
    local need_quote=0
    case "$val" in
        *'"'*)  val="${val//\"/\"\"}"; need_quote=1 ;;
    esac
    case "$val" in
        *','*|*$'\n'*) need_quote=1 ;;
    esac
    if [ "$need_quote" -eq 1 ]; then
        echo "\"${val}\""
    else
        echo "$val"
    fi
}

# Sanitizar student ID: strip /, ;, ", \n, .. y otros peligrosos
_metrics_sanitize_id() {
    local raw="$1"
    # Strip caracteres peligrosos
    raw="${raw//\//}"
    raw="${raw//;/}"
    raw="${raw//\"/}"
    raw="${raw//\'/}"
    raw="${raw//$'\n'/}"
    raw="${raw//$'\r'/}"
    raw="${raw//../}"
    # Trim espacios
    raw="$(echo "$raw" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    echo "$raw"
}

# ── API publica ────────────────────────────────────────────

# Inicializar metricas. Idempotente.
# Si student_id proviene de arg, lo usa. Sino: $STUDENT_ID -> prompt -> $USER
metrics_init() {
    # Idempotente: si ya inicializado, retornar ok
    [ "$METRICS_INITIALIZED" -eq 1 ] && return 0

    local student_id="${1:-}"

    # Resolution chain: arg -> env -> prompt -> $USER
    if [ -z "$student_id" ]; then
        student_id="${STUDENT_ID:-}"
    fi
    if [ -z "$student_id" ]; then
        # Solo preguntar si stdin es tty
        if [ -t 0 ] 2>/dev/null; then
            echo -n "Ingresa tu ID de estudiante: "
            read -r student_id
        fi
    fi
    if [ -z "$student_id" ]; then
        student_id="${USER:-unknown}"
    fi

    # Sanitizar
    student_id=$(_metrics_sanitize_id "$student_id")
    if [ -z "$student_id" ]; then
        student_id="unknown"
    fi

    METRICS_STUDENT_ID="$student_id"

    # Determinar directorio de storage
    METRICS_DIR="${HOME}/.lab_metrics"
    METRICS_STUDENT_DIR="${METRICS_DIR}/${METRICS_STUDENT_ID}"

    # Intentar crear directorio; fallback a /tmp si no escribe
    if ! mkdir -p "$METRICS_STUDENT_DIR" 2>/dev/null; then
        _metrics_log "WARN" "No se pudo crear ${METRICS_DIR}, usando /tmp"
        METRICS_DIR="/tmp/lab_metrics_${USER:-unknown}"
        METRICS_STUDENT_DIR="${METRICS_DIR}/${METRICS_STUDENT_ID}"
        mkdir -p "$METRICS_STUDENT_DIR" 2>/dev/null || {
            _metrics_log "ERR" "No se pudo crear directorio de metricas"
            return 1
        }
    fi

    # Verificar escritura
    if [ ! -w "$METRICS_STUDENT_DIR" ]; then
        _metrics_log "WARN" "Directorio ${METRICS_STUDENT_DIR} no escribe, usando /tmp"
        METRICS_DIR="/tmp/lab_metrics_${USER:-unknown}"
        METRICS_STUDENT_DIR="${METRICS_DIR}/${METRICS_STUDENT_ID}"
        mkdir -p "$METRICS_STUDENT_DIR" 2>/dev/null || {
            _metrics_log "ERR" "No se pudo crear directorio fallback"
            return 1
        }
    fi

    # Crear header CSV si archivo no existe
    local csv_file="${METRICS_STUDENT_DIR}/results.csv"
    if [ ! -s "$csv_file" ]; then
        echo "student_id,unit,reto,status,duration_ms,timestamp,test_output" > "$csv_file" 2>/dev/null
    fi

    METRICS_INITIALIZED=1
    return 0
}

# Grabar una fila de metricas por reto
# metrics_record <unit_id> <reto_id> <status> <duration_ms> [test_output]
metrics_record() {
    [ "$METRICS_INITIALIZED" -eq 1 ] || return 0

    local unit="$1" reto="$2" status="$3" duration_ms="$4" output="${5:-}"

    # Validar status
    case "$status" in
        PASS|FAIL|SKIP) ;;
        *) _metrics_log "WARN" "Status invalido: $status (usando FAIL)"; status="FAIL" ;;
    esac

    local csv_file="${METRICS_STUDENT_DIR}/results.csv"

    # Escribir header si archivo no existe o esta vacio
    if [ ! -s "$csv_file" ]; then
        echo "student_id,unit,reto,status,duration_ms,timestamp,test_output" > "$csv_file" 2>/dev/null || {
            _metrics_log "ERR" "No se pudo escribir header en $csv_file"
            return 1
        }
    fi

    # Timestamp ISO 8601 UTC
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)

    # Escape cada campo
    local esc_id esc_unit esc_reto esc_status esc_ms esc_ts esc_out
    esc_id=$(_metrics_csv_escape "$METRICS_STUDENT_ID")
    esc_unit=$(_metrics_csv_escape "$unit")
    esc_reto=$(_metrics_csv_escape "$reto")
    esc_status=$(_metrics_csv_escape "$status")
    esc_ms=$(_metrics_csv_escape "$duration_ms")
    esc_ts=$(_metrics_csv_escape "$timestamp")
    esc_out=$(_metrics_csv_escape "$output")

    # Append (append-only: nunca sobreescribir)
    echo "${esc_id},${esc_unit},${esc_reto},${esc_status},${esc_ms},${esc_ts},${esc_out}" >> "$csv_file" 2>/dev/null || {
        _metrics_log "ERR" "No se pudo escribir en $csv_file"
        return 1
    }

    return 0
}

# Imprimir resumen por unidad a stdout
# metrics_summary [csv_path]
metrics_summary() {
    local csv_file="${1:-${METRICS_STUDENT_DIR}/results.csv}"

    if [ ! -f "$csv_file" ] || [ ! -s "$csv_file" ]; then
        echo "No hay datos de metricas disponibles."
        return 0
    fi

    echo "=== RESUMEN DE METRICAS ==="
    echo "Estudiante: ${METRICS_STUDENT_ID:-N/A}"
    echo "Fecha: $(date -u +"%Y-%m-%d %H:%M:%S UTC" 2>/dev/null || date)"
    echo ""

    # Procesar con awk
    awk -F, '
    NR == 1 { next }  # skip header
    {
        unit = $2
        status = $4
        ms = $5 + 0

        total[unit]++
        if (status == "PASS") passes[unit]++
        time_sum[unit] += ms
    }
    END {
        if (length(total) == 0) {
            print "  No hay retos registrados."
            next
        }
        printf "  %-12s %8s %8s %8s %10s\n", "UNIDAD", "PASSED", "TOTAL", "TASA", "PROM(ms)"
        printf "  %-12s %8s %8s %8s %10s\n", "--------", "------", "-----", "----", "-------"
        for (u in total) {
            p = passes[u] + 0
            t = total[u]
            rate = (t > 0) ? int(p * 100 / t) : 0
            avg = (t > 0) ? int(time_sum[u] / t) : 0
            printf "  %-12s %8d %8d %7d%% %10d\n", u, p, t, rate, avg
        }
        printf "  %-12s %8s %8s %8s %10s\n", "--------", "------", "-----", "----", "-------"

        total_all = 0; pass_all = 0; time_all = 0
        for (u in total) {
            total_all += total[u]
            pass_all += passes[u] + 0
            time_all += time_sum[u]
        }
        rate_all = (total_all > 0) ? int(pass_all * 100 / total_all) : 0
        avg_all = (total_all > 0) ? int(time_all / total_all) : 0
        printf "  %-12s %8d %8d %7d%% %10d\n", "TOTAL", pass_all, total_all, rate_all, avg_all
    }
    ' "$csv_file"

    echo ""
}

# Generar reportes
# metrics_report [--csv] [--html] [--output-dir <dir>]
metrics_report() {
    [ "$METRICS_INITIALIZED" -eq 1 ] || return 0

    local do_csv=0 do_html=0 out_dir="${METRICS_STUDENT_DIR}"
    local csv_file="${METRICS_STUDENT_DIR}/results.csv"

    # Parse args
    while [ $# -gt 0 ]; do
        case "$1" in
            --csv)  do_csv=1 ;;
            --html) do_html=1 ;;
            --output-dir) shift; out_dir="$1" ;;
        esac
        shift
    done

    # Default: ambos
    [ "$do_csv" -eq 0 ] && [ "$do_html" -eq 0 ] && { do_csv=1; do_html=1; }

    [ ! -f "$csv_file" ] && { _metrics_log "WARN" "No hay datos para reporte"; return 0; }

    # CSV summary
    if [ "$do_csv" -eq 1 ]; then
        local summary_file="${out_dir}/summary.csv"
        awk -F, '
        NR == 1 { next }
        {
            unit = $2; status = $4; ms = $5 + 0
            total[unit]++
            if (status == "PASS") passes[unit]++
            time_sum[unit] += ms
        }
        END {
            print "unit,total_reto,passed,pass_rate,avg_ms"
            for (u in total) {
                p = passes[u] + 0
                t = total[u]
                rate = (t > 0) ? int(p * 100 / t) : 0
                avg = (t > 0) ? int(time_sum[u] / t) : 0
                printf "%s,%d,%d,%d%%,%d\n", u, t, p, rate, avg
            }
        }
        ' "$csv_file" > "$summary_file" 2>/dev/null
        [ $? -eq 0 ] && echo "CSV summary: $summary_file"
    fi

    # HTML report
    if [ "$do_html" -eq 1 ]; then
        local html_file="${out_dir}/report.html"
        {
            echo "<!DOCTYPE html>"
            echo "<html><head><meta charset='utf-8'>"
            echo "<title>Metricas Lab Linux - ${METRICS_STUDENT_ID}</title>"
            echo "<style>"
            echo "body{font-family:sans-serif;margin:2em;background:#f5f5f5}"
            echo "table{border-collapse:collapse;width:100%;background:#fff}"
            echo "th,td{border:1px solid #ddd;padding:8px;text-align:left}"
            echo "th{background:#2196F3;color:#fff}"
            echo ".pass{color:#4CAF50;font-weight:bold}"
            echo ".fail{color:#f44336;font-weight:bold}"
            echo "h1{color:#333}h2{color:#555}"
            echo "</style></head><body>"
            echo "<h1>Metricas Lab Linux</h1>"
            echo "<p>Estudiante: <strong>${METRICS_STUDENT_ID}</strong> | Fecha: $(date -u +"%Y-%m-%d %H:%M UTC" 2>/dev/null || date)</p>"
            echo "<h2>Detalle por Reto</h2>"
            echo "<table><tr><th>Unidad</th><th>Reto</th><th>Estado</th><th>Tiempo (ms)</th><th>Fecha</th></tr>"

            awk -F, '
            NR == 1 { next }
            {
                status_class = ($4 == "PASS") ? "pass" : "fail"
                printf "<tr><td>%s</td><td>%s</td><td class=\"%s\">%s</td><td>%s</td><td>%s</td></tr>\n",
                    $2, $3, status_class, $4, $5, $6
            }
            ' "$csv_file"

            echo "</table>"

            echo "<h2>Resumen por Unidad</h2>"
            echo "<table><tr><th>Unidad</th><th>Total</th><th>Pasados</th><th>Tasa</th><th>Promedio (ms)</th></tr>"

            awk -F, '
            NR == 1 { next }
            {
                unit = $2; status = $4; ms = $5 + 0
                total[unit]++
                if (status == "PASS") passes[unit]++
                time_sum[unit] += ms
            }
            END {
                for (u in total) {
                    p = passes[u] + 0
                    t = total[u]
                    rate = (t > 0) ? int(p * 100 / t) : 0
                    avg = (t > 0) ? int(time_sum[u] / t) : 0
                    printf "<tr><td>%s</td><td>%d</td><td>%d</td><td>%d%%</td><td>%d</td></tr>\n",
                        u, t, p, rate, avg
                }
            }
            ' "$csv_file"

            echo "</table>"
            echo "</body></html>"
        } > "$html_file" 2>/dev/null
        [ $? -eq 0 ] && echo "HTML report: $html_file"
    fi

    return 0
}

# Limpiar archivos viejos
# metrics_cleanup [retention_days]
metrics_cleanup() {
    local retention_days="${1:-30}"
    local base_dir="${METRICS_DIR:-${HOME}/.lab_metrics}"

    [ -d "$base_dir" ] || return 0

    find "$base_dir" -name "*.csv" -mtime +"$retention_days" -delete 2>/dev/null
    find "$base_dir" -name "*.html" -mtime +"$retention_days" -delete 2>/dev/null

    return 0
}
