#!/bin/bash
# tests/metrics_integration_test.sh — Integration tests for eval.sh + metrics.sh
# Ejecutar: bash tests/metrics_integration_test.sh
# Retorna exit 0 si todo pasa, exit 1 si hay fallos.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Contadores ─────────────────────────────────────────────
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ── Helpers de testing ─────────────────────────────────────
assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  ✔ $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  ✘ $desc"
        echo "    Expected: [$expected]"
        echo "    Got:      [$actual]"
    fi
}

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if echo "$haystack" | grep -q "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  ✔ $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  ✘ $desc"
        echo "    Expected to contain: [$needle]"
        echo "    In: [$haystack]"
    fi
}

assert_file_exists() {
    local desc="$1" filepath="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$filepath" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  ✔ $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  ✘ $desc"
        echo "    File not found: $filepath"
    fi
}

assert_file_contains() {
    local desc="$1" filepath="$2" pattern="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$filepath" ] && grep -q "$pattern" "$filepath"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  ✔ $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  ✘ $desc"
        echo "    Expected file $filepath to contain: [$pattern]"
    fi
}

assert_exit_code() {
    local desc="$1" expected="$2" actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expected" -eq "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  ✔ $desc"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "  ✘ $desc"
        echo "    Expected exit: $expected"
        echo "    Got exit:      $actual"
    fi
}

# Helper: trim leading/trailing whitespace (macOS wc -l adds spaces)
trim() { echo "$1" | xargs; }

# ── Mock validators for testing ────────────────────────────
mock_reto_pass() { return 0; }
mock_reto_fail() { return 1; }
mock_reto_another_pass() { return 0; }

# ── Setup ──────────────────────────────────────────────────
setup_test_env() {
    # Use temp dir for metrics storage during tests
    TEST_TMP_DIR=$(mktemp -d)
    export HOME="$TEST_TMP_DIR"
    # Reset metrics state
    METRICS_INITIALIZED=0
    METRICS_STUDENT_ID=""
    METRICS_DIR=""
    METRICS_STUDENT_DIR=""
}

cleanup_test_env() {
    [ -d "$TEST_TMP_DIR" ] && rm -rf "$TEST_TMP_DIR"
}

# Ensure cleanup on exit
trap cleanup_test_env EXIT

# ── Source modules ─────────────────────────────────────────
# Source metrics.sh (required for integration tests)
source "${LAB_DIR}/shared/metrics.sh"

# Source colors.sh (needed by eval.sh for exito/error/titulo/separador/celebrar)
source "${LAB_DIR}/shared/colors.sh"

# Source eval.sh (the module under test)
source "${LAB_DIR}/shared/eval.sh"

# ══════════════════════════════════════════════════════════════
echo ""
echo "=== Integration Tests: eval.sh + metrics.sh ==="
echo ""

# ── Test 1: eval.sh works WITHOUT metrics.sh (guard-check) ──
echo "Test Group: eval.sh fallback (metrics not initialized)"

setup_test_env
# METRICS_INITIALIZED stays 0 (default from metrics.sh)
OUTPUT=$(ejecutar_evaluacion "unit-I" 3 mock_reto_pass mock_reto_fail mock_reto_fail 2>&1)
EXIT_CODE=$?

assert_exit_code "ejecutar_evaluacion returns fail count (2 failures)" 2 $EXIT_CODE
assert_contains "output shows Evaluacion title" "$OUTPUT" "Evaluacion - unit-I"
assert_contains "output shows reto 1 passed" "$OUTPUT" "Reto 1 completado"
assert_contains "output shows reto 2 failed" "$OUTPUT" "Reto 2 fallido"
assert_contains "output shows reto 3 failed" "$OUTPUT" "Reto 3 fallido"
assert_contains "output shows results line" "$OUTPUT" "pasados"

# Verify NO metrics file was created (metrics not initialized)
TEST_METRICS_FILE="${HOME}/.lab_metrics/test_integration/results.csv"
assert_eq "no metrics file created when METRICS_INITIALIZED=0" "no" "$([ -f "$TEST_METRICS_FILE" ] && echo "yes" || echo "no")"

cleanup_test_env

# ── Test 2: eval.sh hook fires WITH metrics.sh loaded ──────
echo ""
echo "Test Group: eval.sh hook with metrics loaded"

setup_test_env
# Initialize metrics with a test student ID
metrics_init "test_integration"
assert_eq "metrics initialized" 1 "$METRICS_INITIALIZED"

OUTPUT=$(ejecutar_evaluacion "unit-I" 3 mock_reto_pass mock_reto_fail mock_reto_fail 2>&1)
EXIT_CODE=$?

assert_exit_code "ejecutar_evaluacion returns fail count (2 failures)" 2 $EXIT_CODE

# Verify metrics CSV was created
METRICS_CSV="${METRICS_STUDENT_DIR}/results.csv"
assert_file_exists "results.csv created" "$METRICS_CSV"

# Verify CSV has header + 3 data rows (4 lines total)
LINE_COUNT=$(trim "$(wc -l < "$METRICS_CSV" 2>/dev/null || echo 0)")
assert_eq "CSV has header + 3 data rows" 4 "$LINE_COUNT"

# Verify CSV header
assert_file_contains "CSV has correct header" "$METRICS_CSV" "student_id,unit,reto,status,duration_ms,timestamp,test_output"

# Verify row 1: reto 1 PASS
ROW1=$(sed -n '2p' "$METRICS_CSV")
assert_contains "row 1 has student_id" "$ROW1" "test_integration"
assert_contains "row 1 has unit-I" "$ROW1" "unit-I"
assert_contains "row 1 has reto 1" "$ROW1" ",1,"
assert_contains "row 1 has PASS" "$ROW1" "PASS"

# Verify row 2: reto 2 FAIL
ROW2=$(sed -n '3p' "$METRICS_CSV")
assert_contains "row 2 has FAIL status" "$ROW2" "FAIL"
assert_contains "row 2 has reto 2" "$ROW2" ",2,"

# Verify row 3: reto 3 FAIL
ROW3=$(sed -n '4p' "$METRICS_CSV")
assert_contains "row 3 has FAIL status" "$ROW3" "FAIL"
assert_contains "row 3 has reto 3" "$ROW3" ",3,"

# Verify duration_ms is a number (not empty)
DURATION_FIELD=$(echo "$ROW1" | cut -d',' -f5)
TESTS_RUN=$((TESTS_RUN + 1))
if [[ "$DURATION_FIELD" =~ ^[0-9]+$ ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✔ duration_ms is numeric: $DURATION_FIELD"
else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✘ duration_ms is numeric"
    echo "    Got: [$DURATION_FIELD]"
fi

# Verify timestamp is ISO 8601 format
TS_FIELD=$(echo "$ROW1" | cut -d',' -f6)
TESTS_RUN=$((TESTS_RUN + 1))
if [[ "$TS_FIELD" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✔ timestamp is ISO 8601: $TS_FIELD"
else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✘ timestamp is ISO 8601"
    echo "    Got: [$TS_FIELD]"
fi

cleanup_test_env

# ── Test 3: eval.sh output unchanged with metrics loaded ───
echo ""
echo "Test Group: eval.sh output unchanged"

setup_test_env
metrics_init "test_output"

OUTPUT=$(ejecutar_evaluacion "unit-II" 2 mock_reto_pass mock_reto_pass 2>&1)

assert_contains "output shows Evaluacion title" "$OUTPUT" "Evaluacion - unit-II"
assert_contains "output shows reto 1 passed" "$OUTPUT" "Reto 1 completado"
assert_contains "output shows reto 2 passed" "$OUTPUT" "Reto 2 completado"
assert_contains "output shows 2 pasados" "$OUTPUT" "2 pasados"
assert_contains "output shows celebrar" "$OUTPUT" "Todos los retos completados"

cleanup_test_env

# ── Test 4: marcar_completado still works alongside metrics ──
echo ""
echo "Test Group: marcar_completado still works"

setup_test_env
metrics_init "test_mark"

# Re-init state paths after HOME change (these were set at source time)
STATE_DIR="${HOME}/.lab_state"
PROGRESS_FILE="${STATE_DIR}/progress"
mkdir -p "${HOME}/.lab_state"
touch "${HOME}/.lab_state/progress"

ejecutar_evaluacion "unit-III" 2 mock_reto_pass mock_reto_fail >/dev/null 2>&1

# Verify reto 1 was marked as completed
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "unit-III:reto:1" "${HOME}/.lab_state/progress" 2>/dev/null; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✔ reto 1 marked as completed in progress file"
else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✘ reto 1 not found in progress file"
    echo "    Progress file contents: $(cat "${HOME}/.lab_state/progress" 2>/dev/null || echo 'EMPTY')"
fi

# Verify reto 2 was NOT marked as completed
TESTS_RUN=$((TESTS_RUN + 1))
if ! grep -q "unit-III:reto:2" "${HOME}/.lab_state/progress" 2>/dev/null; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✔ reto 2 NOT marked as completed (correct - it failed)"
else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✘ reto 2 unexpectedly marked as completed"
fi

cleanup_test_env

# ── Test 5: all retos recorded in metrics ──────────────────
echo ""
echo "Test Group: all retos recorded"

setup_test_env
metrics_init "test_all_reto"

ejecutar_evaluacion "unit-IV" 5 mock_reto_pass mock_reto_fail mock_reto_pass mock_reto_pass mock_reto_fail >/dev/null 2>&1

METRICS_CSV="${METRICS_STUDENT_DIR}/results.csv"
LINE_COUNT=$(trim "$(wc -l < "$METRICS_CSV" 2>/dev/null || echo 0)")
assert_eq "CSV has header + 5 data rows" 6 "$LINE_COUNT"

# Verify PASS/FAIL pattern matches mock validators
PASS_COUNT=$(grep -c ",PASS," "$METRICS_CSV" 2>/dev/null || echo 0)
FAIL_COUNT=$(grep -c ",FAIL," "$METRICS_CSV" 2>/dev/null || echo 0)
assert_eq "3 PASS records" 3 "$PASS_COUNT"
assert_eq "2 FAIL records" 2 "$FAIL_COUNT"

cleanup_test_env

# ── Test 6: metrics_record called with correct arguments ───
echo ""
echo "Test Group: metrics_record argument passing"

setup_test_env
metrics_init "test_args"

# Manually test metrics_record with known values
metrics_record "unit-V" 7 "PASS" 42 "test output"
metrics_record "unit-V" 8 "FAIL" 12 ""

METRICS_CSV="${METRICS_STUDENT_DIR}/results.csv"

ROW1=$(sed -n '2p' "$METRICS_CSV")
assert_contains "row has unit-V" "$ROW1" "unit-V"
assert_contains "row has reto 7" "$ROW1" ",7,"
assert_contains "row has PASS" "$ROW1" "PASS"
assert_contains "row has 42 ms" "$ROW1" ",42,"
assert_contains "row has test output" "$ROW1" "test output"

ROW2=$(sed -n '3p' "$METRICS_CSV")
assert_contains "row has FAIL" "$ROW2" "FAIL"
assert_contains "row has reto 8" "$ROW2" ",8,"
assert_contains "row has empty output" "$ROW2" ",\"\""

cleanup_test_env

# ── Test 7: idempotent metrics_init during eval ────────────
echo ""
echo "Test Group: idempotent init during eval"

setup_test_env
metrics_init "test_idempotent"
metrics_init "test_idempotent"  # Call again - should not error

OUTPUT=$(ejecutar_evaluacion "unit-VI" 1 mock_reto_pass 2>&1)
EXIT_CODE=$?

assert_exit_code "exit 0 (no failures)" 0 $EXIT_CODE

METRICS_CSV="${METRICS_STUDENT_DIR}/results.csv"
LINE_COUNT=$(trim "$(wc -l < "$METRICS_CSV" 2>/dev/null || echo 0)")
assert_eq "CSV has header + 1 data row" 2 "$LINE_COUNT"

cleanup_test_env

# ══════════════════════════════════════════════════════════════
# Summary
echo ""
echo "=== Results ==="
echo "Total:  $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo "✔ All integration tests passed!"
    exit 0
else
    echo "✘ $TESTS_FAILED integration test(s) failed."
    exit 1
fi
