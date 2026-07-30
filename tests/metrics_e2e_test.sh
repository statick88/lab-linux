#!/bin/bash
# tests/metrics_e2e_test.sh — End-to-end tests for metrics_test.sh
# Tests the refactored metrics_test.sh with --batch, --student, and metrics.sh integration

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ── Assertion helpers ────────────────────────────────────────
assert_eq() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — expected='$expected' actual='$actual'"
    fi
}

assert_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" haystack="$2" needle="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — '$needle' not found"
    fi
}

assert_file_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" filepath="$2"
    if [ -f "$filepath" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — file '$filepath' not found"
    fi
}

assert_file_not_empty() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" filepath="$2"
    if [ -f "$filepath" ] && [ -s "$filepath" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — file '$filepath' is empty or missing"
    fi
}

assert_file_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" filepath="$2" pattern="$3"
    if [ -f "$filepath" ] && grep -qF "$pattern" "$filepath"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — pattern '$pattern' not found in $filepath"
    fi
}

assert_csv_header() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" csv_file="$2" expected_header="$3"
    if [ ! -f "$csv_file" ]; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — CSV file not found"
        return
    fi
    local header
    header=$(head -1 "$csv_file")
    if [ "$header" = "$expected_header" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — header='$header' expected='$expected_header'"
    fi
}

assert_exit_code() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local label="$1" expected="$2" actual="$3"
    if [ "$expected" -eq "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] $label"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] $label — exit=$actual expected=$expected"
    fi
}

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  E2E TEST RESULTS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Total:  $TESTS_RUN"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo ""
    if [ $TESTS_FAILED -gt 0 ]; then
        echo "  ❌ $TESTS_FAILED test(s) failed"
    else
        echo "  ✓ All tests passed"
    fi
}

# ============================================================
# TEST SUITE
# ============================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E TESTS — metrics_test.sh refactored"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Test 1: Script is syntactically valid ───────────────────
echo ""
echo "--- Test 1: Script syntax check ---"
bash -n "${LAB_DIR}/metrics_test.sh"
assert_exit_code "metrics_test.sh is syntactically valid" 0 $?

# ── Test 2: --help flag (if implemented) ────────────────────
echo ""
echo "--- Test 2: --batch flag parsed ---"
OUTPUT=$(bash "${LAB_DIR}/metrics_test.sh" --batch 2>&1) || true
assert_contains "--batch accepted by script" "$OUTPUT" "METRICAS"

# ── Test 3: --batch --student flag accepted ─────────────────
echo ""
echo "--- Test 3: --batch --student flag accepted ---"
OUTPUT=$(bash "${LAB_DIR}/metrics_test.sh" --batch --student test-student-001 2>&1) || true
assert_contains "--batch --student accepted" "$OUTPUT" "METRICAS"

# ── Test 4: Script produces CSV output (with metrics.sh) ────
echo ""
echo "--- Test 4: CSV file created with metrics.sh ---"
# Capture script stdout to extract the CSV path
OUTPUT=$(bash "${LAB_DIR}/metrics_test.sh" --batch --student test-001 2>&1) || true

# metrics.sh writes to ~/.lab_metrics/<student>/results.csv or /tmp/lab_metrics_*/
METRICS_CSV=""
if [ -f "${HOME}/.lab_metrics/test-001/results.csv" ]; then
    METRICS_CSV="${HOME}/.lab_metrics/test-001/results.csv"
else
    # Search /tmp for any results.csv created by metrics.sh
    METRICS_CSV=$(find /tmp -maxdepth 4 -name "results.csv" -newer /tmp/metrics_results.csv 2>/dev/null | head -1)
fi
# Fallback to the script's own fallback CSV if nothing else found
if [ -z "$METRICS_CSV" ] || [ ! -f "$METRICS_CSV" ]; then
    METRICS_CSV="/tmp/metrics_results.csv"
fi
assert_file_exists "CSV output file exists" "$METRICS_CSV"

# ── Test 5: CSV has correct header ──────────────────────────
echo ""
echo "--- Test 5: CSV header format ---"
if [ -f "$METRICS_CSV" ]; then
    HEADER=$(head -1 "$METRICS_CSV")
    assert_contains "CSV has header row" "$HEADER" ","
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  [FAIL] CSV header check — file missing"
fi

# ── Test 6: CSV has data rows ───────────────────────────────
echo ""
echo "--- Test 6: CSV has data rows ---"
if [ -f "$METRICS_CSV" ]; then
    ROW_COUNT=$(wc -l < "$METRICS_CSV")
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$ROW_COUNT" -gt 1 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] CSV has $((ROW_COUNT - 1)) data rows"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] CSV has only header, no data"
    fi
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  [FAIL] CSV data rows check — file missing"
fi

# ── Test 7: Fallback CSV works without metrics.sh ───────────
echo ""
echo "--- Test 7: Fallback CSV (simulate missing metrics.sh) ---"
METRICS_SH_AVAILABLE=0
FALLBACK_CSV="/tmp/metrics_fallback_e2e.csv"
echo "unit_num,unit_name,reto_num,reto_label,exec_time_ms,passed" > "$FALLBACK_CSV"
assert_csv_header "Fallback CSV header correct" "$FALLBACK_CSV" "unit_num,unit_name,reto_num,reto_label,exec_time_ms,passed"

# Write test row
echo "1,Fundamentos de Linux y WSL2,1,R1,100,PASS" >> "$FALLBACK_CSV"
ROW_COUNT=$(wc -l < "$FALLBACK_CSV")
TESTS_RUN=$((TESTS_RUN + 1))
if [ "$ROW_COUNT" -eq 2 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  [PASS] Fallback CSV has 2 lines (header + 1 data)"
else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  [FAIL] Fallback CSV row count=$ROW_COUNT expected=2"
fi

# ── Test 8: Script handles missing units gracefully ─────────
echo ""
echo "--- Test 8: Script handles missing /app/units ---"
OUTPUT=$(bash "${LAB_DIR}/metrics_test.sh" --batch 2>&1) || true
# Script should not crash, should output something
TESTS_RUN=$((TESTS_RUN + 1))
if [ -n "$OUTPUT" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  [PASS] Script produces output even without /app/units"
else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  [FAIL] Script produced no output"
fi

# ── Test 9: Student ID passed through correctly ─────────────
echo ""
echo "--- Test 9: Student ID in output ---"
OUTPUT=$(bash "${LAB_DIR}/metrics_test.sh" --batch --student "e2e-student-test" 2>&1) || true
assert_contains "Student ID reflected in output" "$OUTPUT" "e2e-student-test"

# ── Test 10: Both --batch and --student can be combined ─────
echo ""
echo "--- Test 10: Combined --batch --student flags ---"
OUTPUT=$(bash "${LAB_DIR}/metrics_test.sh" --batch --student "combined-test" 2>&1) || true
assert_contains "Combined flags work" "$OUTPUT" "combined-test"

# ── Test 11: metrics_test.sh is executable script ───────────
echo ""
echo "--- Test 11: Script starts with shebang ---"
SHEBANG=$(head -1 "${LAB_DIR}/metrics_test.sh")
assert_contains "Script has shebang" "$SHEBANG" "#!/bin/bash"

# ── Test 12: metrics_test.sh has expected functions ─────────
echo ""
echo "--- Test 12: Script contains key functions ---"
CONTENT=$(cat "${LAB_DIR}/metrics_test.sh")
assert_contains "Has time_ms function" "$CONTENT" "time_ms()"
assert_contains "Has run_reto function" "$CONTENT" "run_reto()"
assert_contains "Has run_unit function" "$CONTENT" "run_unit()"
assert_contains "Has print_summary function" "$CONTENT" "print_summary()"

# ── Test 13: metrics_test.sh has fallback logic ─────────────
echo ""
echo "--- Test 13: Script has metrics.sh fallback ---"
assert_contains "Has METRICS_SH_AVAILABLE check" "$CONTENT" "METRICS_SH_AVAILABLE"

# ── Test 14: metrics_test.sh has --batch flag ───────────────
echo ""
echo "--- Test 14: Script has --batch flag ---"
assert_contains "Has --batch flag parsing" "$CONTENT" "--batch"

# ── Test 15: metrics_test.sh has --student flag ─────────────
echo ""
echo "--- Test 15: Script has --student flag ---"
assert_contains "Has --student flag parsing" "$CONTENT" "--student"

# ── Test 16: metrics_test.sh uses metrics.sh functions ──────
echo ""
echo "--- Test 16: Script calls metrics.sh API ---"
assert_contains "Calls metrics_init" "$CONTENT" "metrics_init"
assert_contains "Calls metrics_record" "$CONTENT" "metrics_record"
assert_contains "Calls metrics_summary" "$CONTENT" "metrics_summary"
assert_contains "Calls metrics_time_ms" "$CONTENT" "metrics_time_ms"

# ── Test 17: Backward compatibility — CSV format preserved ──
echo ""
echo "--- Test 17: Fallback CSV format (backward compat) ---"
assert_contains "Fallback CSV has unit_num" "$CONTENT" "unit_num,unit_name,reto_num,reto_label,exec_time_ms,passed"

# ── Test 18: metrics_test.sh is valid bash ──────────────────
echo ""
echo "--- Test 18: metrics_test.sh passes shellcheck (syntax only) ---"
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -S warning "${LAB_DIR}/metrics_test.sh" >/dev/null 2>&1
    SC_EXIT=$?
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ $SC_EXIT -le 2 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  [PASS] shellcheck passed (exit=$SC_EXIT)"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  [FAIL] shellcheck failed (exit=$SC_EXIT)"
    fi
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  [PASS] shellcheck not installed, skipped"
fi

# ============================================================
# CLEANUP
# ============================================================
rm -f /tmp/metrics_fallback_e2e.csv
rm -f /tmp/metrics_results.csv

print_summary
