## Exploration: Comprehensive Metrics System for Lab-Linux

### Current State

#### 1. Test Validators (`units/*/test.sh`)

**Pattern:**
- Each unit has 10 `retoN()` functions (N=1..10)
- Validators return 0 (pass) or non-zero (fail) — pure state-checkers
- Source `/shared/common.sh` for utilities (colors, progress tracking)
- Define `challenge_names` array and `retoN_info()` functions for UI
- Define `validators` array for batch execution

**Example (Unit I):**
```bash
reto1() {
    [ -d /etc ] && [ -r /etc ]
}
```

**Output format:** Exit code only (0=pass, non-zero=fail). No structured output.

#### 2. Evaluation Orchestration (`shared/eval.sh`)

**Functions:**
- `marcar_completado(unit, reto)` → writes `unit-X:reto:N` to `~/.lab_state/progress`
- `esta_completado(unit, reto)` → greps progress file
- `contar_completados(unit, total)` → counts completed retos
- `ejecutar_evaluacion(unit, total, validators[])` → runs all validators, marks completion
- `mostrar_estado_retos(unit, names[])` → displays pass/fail status

**Data format:** Plain text, one entry per line: `unit-I:reto:1`

**Limitations:**
- No timing data
- No timestamps
- No student identification
- No attempt counting
- Single-pass execution (no retry tracking)

#### 3. Metrics System (`metrics_test.sh` v2)

**Current capabilities:**
- Times each reto validator execution using `/proc/uptime` or `date +%s%N`
- Outputs CSV: `unit_num,unit_name,reto_num,reto_label,exec_time_ms,passed`
- Handles Docker-dependent units (skips if no `/var/run/docker.sock`)
- Runs validators in subshells for isolation
- Generates text summary with per-unit breakdowns

**Limitations:**
- No student identification
- No persistence (writes to `/tmp/`)
- No real-time feedback (silent execution)
- No retry/attempt tracking
- No HTML report generation
- No integration with `eval.sh` progress tracking

#### 4. Student Progress Tracking

**Current state:**
- File: `~/.lab_state/progress`
- Format: `unit-X:reto:N` (one line per completed reto)
- No timing, no timestamps, no student ID
- Persists via Docker volume mount (`lab-data:/home/estudiante/laboratorio`)

#### 5. Menu System (`entrypoint.sh` + `shared/menu.sh`)

**Flow:**
1. `entrypoint.sh` loads `common.sh` → `menu.sh`
2. `mostrar_menu_principal()` shows 11 units with progress bars
3. `mostrar_menu_retos()` shows 10 retos per unit with ✔/✘ status
4. `jugar_reto()` provides interactive challenge mode:
   - Shows instructions (`retoN_info()`)
   - Interactive command execution
   - `verificar` triggers validator
   - Tracks attempts in memory (not persisted)
   - Offers next reto on success

**Key arrays:**
- `UNIDADES[]` — unit titles
- `RETOS_POR_UNIDAD[]` — retos per unit (all 10)
- `ICONOS[]` — emoji icons

#### 6. Docker Architecture

- Base: Ubuntu 24.04 with Docker-in-Docker
- User: `estudiante` with sudo NOPASSWD
- Units copied from `/opt/lab-units/` to `~/laboratorio/units/` on first run
- Volume: `lab-data:/home/estudiante/laboratorio` for persistence
- Socket mount: `/var/run/docker.sock:/var/run/docker.sock` for Docker challenges

---

### Affected Areas

| File | Impact | Reason |
|------|--------|--------|
| `shared/eval.sh` | HIGH | Core evaluation logic needs timing integration |
| `metrics_test.sh` | HIGH | Needs student ID, persistence, real-time feedback |
| `shared/menu.sh` | MEDIUM | Needs to display timing data, call metrics on completion |
| `entrypoint.sh` | LOW | May need to initialize metrics directory |
| `shared/common.sh` | LOW | May need metrics utility functions |
| `Dockerfile` | LOW | May need to copy new metrics scripts |
| `docker-compose.yml` | LOW | May need new volume mount for metrics persistence |

---

### Approaches

#### Approach 1: Extend `eval.sh` with Timing Hooks

**Description:** Add timing instrumentation directly to `ejecutar_evaluacion()` and `marcar_completado()`.

**Pros:**
- Minimal new files
- Integrates naturally with existing flow
- Real-time feedback during interactive use

**Cons:**
- Tightly couples timing with evaluation
- Harder to run metrics independently
- May slow down interactive experience

**Effort:** Low

#### Approach 2: Standalone Metrics Module (`shared/metrics.sh`)

**Description:** Create a new `shared/metrics.sh` module that:
- Wraps validator execution with timing
- Records student ID, timestamps, attempts
- Persists to `~/.lab_state/metrics/`
- Provides report generation (CSV, text, HTML)

**Pros:**
- Clean separation of concerns
- Can be used independently or integrated
- Easy to extend with new report formats
- Doesn't slow down interactive flow

**Cons:**
- New file to maintain
- Needs integration points with `eval.sh` and `menu.sh`

**Effort:** Medium

#### Approach 3: Event-Based Metrics Collection

**Description:** Implement an event system where `eval.sh` and `menu.sh` emit events (reto_started, reto_completed, reto_failed) that metrics.sh subscribes to.

**Pros:**
- Most flexible and extensible
- Easy to add new metrics (e.g., command history, hint usage)
- Clean architecture

**Cons:**
- Most complex to implement
- Overkill for current requirements
- Requires refactoring existing code

**Effort:** High

---

### Recommendation

**Approach 2: Standalone Metrics Module** with selective integration.

**Rationale:**
1. Clean separation — metrics logic doesn't pollute evaluation logic
2. Can be used in three modes:
   - **Interactive:** `menu.sh` calls metrics on reto completion
   - **Batch:** `metrics_test.sh` uses metrics module for timing
   - **Standalone:** `metrics.sh` can be run directly for reports
3. Persistence is straightforward — write to `~/.lab_state/metrics/`
4. Real-time feedback is optional — can be toggled via flag

---

### Proposed Architecture

```
shared/metrics.sh (NEW)
├── record_reto_event(student, unit, reto, status, duration_ms)
├── get_student_progress(student)
├── get_reto_history(student, unit, reto)
├── generate_csv_report(student?, output_path)
├── generate_text_report(student?, output_path)
├── generate_html_report(student?, output_path)
└── get_batch_summary(students[])

integration points:
├── eval.sh: call record_reto_event() after marcar_completado()
├── menu.sh: call record_reto_event() in jugar_reto() on verify
└── metrics_test.sh: use metrics.sh for timing + persistence
```

**Data storage:**
```
~/.lab_state/metrics/
├── {student_id}/
│   ├── events.jsonl          # Append-only event log
│   ├── unit-I.progress       # Per-unit completion (backward compatible)
│   └── unit-II.progress
└── reports/
    ├── {student_id}_report.csv
    ├── {student_id}_report.html
    └── batch_summary.csv
```

**Event format (JSONL):**
```json
{
  "timestamp": "2026-07-29T10:30:00Z",
  "student": "estudiante",
  "unit": "unit-I",
  "reto": 3,
  "event": "completed",
  "duration_ms": 1250,
  "attempt": 2,
  "metadata": {}
}
```

---

### Key Design Decisions Needed

1. **Student Identification**
   - Option A: Use Docker hostname/container name
   - Option B: Prompt for student ID on first login
   - Option C: Use `$USER` (always "estudiante" — not useful for multi-student)
   - **Recommendation:** Option B — prompt on first login, store in `~/.student_id`

2. **Persistence Location**
   - Option A: Inside container (`~/.lab_state/metrics/`)
   - Option B: Host filesystem via volume mount
   - **Recommendation:** Option B — add volume mount `./metrics:/home/estudiante/.lab_state/metrics`

3. **Docker-Dependent Challenges**
   - Option A: Skip with标记 (current approach)
   - Option B: Mock validators for timing
   - Option C: Run with timeout and capture Docker socket availability
   - **Recommendation:** Option C — try with 5s timeout, mark as SKIP if Docker unavailable

4. **Real-Time Feedback**
   - Option A: Always show timing during interactive mode
   - Option B: Show only on `verificar` command
   - Option C: Show only in batch/metrics mode
   - **Recommendation:** Option B — show timing when student verifies, not during commands

5. **Report Generation**
   - Option A: On-demand only (`metrics report`)
   - Option B: Automatic after each unit completion
   - Option C: Both on-demand and automatic
   - **Recommendation:** Option C — generate text summary on unit completion, full reports on-demand

6. **Backward Compatibility**
   - Option A: Replace `~/.lab_state/progress` entirely
   - Option B: Keep progress file, add metrics alongside
   - **Recommendation:** Option B — maintain compatibility, metrics is additive

---

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing eval.sh flow | Medium | High | Add metrics as optional hook, don't modify core logic |
| Docker socket unavailability | High | Low | Graceful fallback with SKIP marking |
| Performance impact on interactive mode | Low | Medium | Metrics writing is async, non-blocking |
| Data loss on container restart | Medium | High | Volume mount for metrics directory |
| Multi-student conflicts | Low | Low | Per-student directories, unique IDs |
| JSONL file corruption | Low | Medium | Append-only with file locking |
| Report generation memory usage | Low | Low | Stream processing, not full load |

---

### Ready for Proposal

**Yes** — the exploration is complete. The orchestrator should:

1. Present the three approaches to the user with trade-offs
2. Ask for preferences on:
   - Student identification method
   - Persistence location (volume mount vs container-only)
   - Real-time feedback style
3. Proceed to design phase with chosen approach

**Summary for user:**
The lab has a solid foundation with 110 challenges across 11 units. The current metrics system (`metrics_test.sh`) captures timing but lacks student identification, persistence, and integration with the interactive flow. The recommended approach is to create a standalone `shared/metrics.sh` module that integrates with existing `eval.sh` and `menu.sh` without modifying their core logic. This provides flexible reporting (CSV, text, HTML) while maintaining backward compatibility.
