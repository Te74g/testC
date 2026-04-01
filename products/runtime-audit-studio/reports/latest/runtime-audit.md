# Runtime Audit Pack

## Executive Summary

- audit timestamp: 2026-04-01T04:15:07.3097481+09:00
- unattended supervisor state: scheduled
- supervisor cycle count: 8
- local runtime status: ready
- local runtime recovery state: armed_not_used
- recommendation: Keep the current Task Scheduler recurring tick plus in-process PowerShell supervisor as the operating baseline.

## Snapshot

- supervisor started_at: 2026-04-01T03:05:32.7989064+09:00
- supervisor end_at: 2026-04-01T04:05:32.8028616+09:00
- supervisor last_cycle_at: 2026-04-01T04:01:36.0175866+09:00
- supervisor last_result: ok
- effective worker lanes: 5
- approved worker slots: 10
- local runtime base_url: http://localhost:11434
- local runtime default_model: qwen2.5-coder:14b
- local runtime reachable: True
- local runtime model_available: True

## Evidence

### Recent Successful Ticks

- cycle 8: 2026-04-01T04:12:06.7418128+09:00
- cycle 7: 2026-04-01T04:00:30.7902973+09:00
- cycle 6: 2026-04-01T03:47:40.1907720+09:00

### Current Health Signals

- heartbeat timestamp: 2026-04-01T04:12:06.4824129+09:00
- local evaluation run count: 159
- northbridge dream status: skipped
- scheduled dream status: not_due
- task lookup result: 
- task lookup state: 

## Risks

- no blocking runtime risk is visible in the current snapshot

## Operational Recommendation

Keep the current Task Scheduler recurring tick plus in-process PowerShell supervisor as the operating baseline.

## Next Actions

1. Keep collecting fresh supervisor tick evidence and heartbeat movement.
2. Exercise Ollama auto-recovery on a controlled failure, then re-run this audit.
3. Only after that, promote this runtime from internal baseline to client-facing operating claim.
