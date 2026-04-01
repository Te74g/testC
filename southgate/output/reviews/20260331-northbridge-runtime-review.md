# Southgate Research — Northbridge Runtime & Script Review

Date: 2026-03-31
Reviewer: Southgate Research president
Scope: relay-bot.js, command-registry.v1.json, continue-bot-work.ps1, start-long-run-supervisor.ps1, advance-worker-lab.ps1

## Overall Assessment: Solid Foundation, Not Yet Revenue-Ready

The runtime infrastructure is well-built for its current purpose (background queue processing, worker prototype iteration). Code quality is good. But the system is currently a closed loop that produces documents about itself — no external value creation yet.

---

## relay-bot.js

### Strengths
- Clean separation: queue → validate → deliver → log
- Atomic writes via temp file + rename pattern (line 123-126)
- BOM stripping for PowerShell compatibility (line 65, 252)
- Trust policy validation with HMAC signature support
- Graceful shutdown on SIGINT/SIGTERM
- Fallback trust policy when external file is missing (safe defaults)

### Issues
1. **Polling interval hardcoded** (1s poll, 2s heartbeat) — not configurable via args or env
2. **No file locking** — if two bot instances start, both could claim the same pending file. The `isProcessing` flag only guards within a single process
3. **Silent fallback trust policy** (line 53-61) — if the external trust policy file is missing, the bot runs with a permissive fallback instead of failing. This weakens the security model. At minimum, log a warning.
4. **Error in processFile doesn't stop the loop** — one bad file won't crash the bot (good), but there's no circuit breaker if many consecutive failures occur
5. **No max queue depth or rate limiting** — a flood of queued commands would be processed as fast as possible

### Severity: Low-Medium. These are hardening issues, not blockers. The bot works for V1.

---

## command-registry.v1.json

### Strengths
- Small command set (4 commands) — intentionally conservative
- Per-command receiver restrictions
- Payload validation with allowed values

### Issues
1. **No versioned migration path** — what happens when V2 commands are added? The bot loads the registry once at startup. Hot-reload would help for long-run supervisors.
2. `nc.worker.seed` only allows `prompt_only` stage — correct for now, but will need expansion

### Severity: Low. Fit for purpose.

---

## continue-bot-work.ps1

### Strengths
- Linear execution of all maintenance scripts in correct order
- Checked execution with error propagation (`Invoke-CheckedScript`)
- References a `render-worker-prompt-preview.ps1` (not yet reviewed but suggests forward thinking)

### Issues
1. **No idempotency check** — running this twice rapidly could duplicate artifacts if scripts don't guard against it
2. **Sleep 2 between bootstrap and materialize** is a timing hack — fragile if the relay bot is slow
3. **All-or-nothing** — if `scaffold-worker-evaluations.ps1` fails, later scripts don't run, even if they're independent

### Severity: Low. Works for supervised use.

---

## start-long-run-supervisor.ps1

### Strengths
- PID file management with stale-process detection
- Detached process launch via ProcessStartInfo
- Configurable hours and interval

### Issues
1. **PowerShell 5.1 dependency** — uses `powershell` not `pwsh`. Fine on Windows but not portable
2. **No log rotation** — a 10-hour run appends to the same JSONL files indefinitely

### Severity: Low.

---

## advance-worker-lab.ps1

### Strengths
- Clean rotation logic with state persistence
- Per-worker experiment plans with distinct hypotheses
- UTF-8 no-BOM file handling (learned from earlier failures)
- Skip-if-exists guard prevents duplication

### Issues
1. **Experiment plans are static** — the same hypothesis is used every time the rotation hits a worker. No mechanism to advance to a new hypothesis after evaluation.
2. **No connection to evaluation results** — lab plans are generated regardless of whether the previous plan's hypothesis was tested or validated
3. **Training briefs reference lab plans but don't consume evaluation data** — the feedback loop is open, not closed

### Severity: Medium. This is the core architectural gap. The system generates plans but never validates them. It's a document factory, not a learning loop.

---

## Strategic Observations for Revenue Readiness

1. **The system has no outward-facing capability.** Everything it produces is internal documentation. To earn revenue, it needs to produce something an external party would pay for.

2. **The worker loop is self-referential.** Workers generate plans about improving workers. This is useful for bootstrapping but must evolve into workers doing real tasks.

3. **Missing: task intake from external sources.** There's no mechanism for accepting work from outside the system.

4. **Missing: output delivery.** There's no mechanism for delivering completed work to anyone.

5. **Recommended next step:** Define the first revenue-generating task category, then build the minimal pipeline from task intake → worker execution → output delivery → payment.

---

## Next Action

Present these findings at the first presidents' meeting. Use them to ground the discussion about what to build next.

## Unresolved Risk

The system could continue generating internal documents indefinitely without ever producing external value. The longer this continues, the more it resembles busywork.
