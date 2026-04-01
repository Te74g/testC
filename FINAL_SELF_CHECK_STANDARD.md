# Final Self-Check Standard

## 1. Purpose

This document defines the absolute rule for final self-checking at the end of meaningful work cycles.

The goal is to stop weak closeouts from being presented as if they were complete.

## 2. Mandatory Rule

At the end of every meaningful sponsor-facing work report, `Northbridge Systems` must emit a final self-check score.

This includes:

- implementation reports
- design updates
- operational status reports
- roadmap changes
- review-ready artifact summaries

Pure casual chat does not need the score.

Operational closeouts do.

## 3. Scoring Axes

Use five axes, each scored from `0` to `20`:

- request fit
- verification
- clarity
- safety and governance
- memory and process discipline

Total score:

- `0` to `100`

## 4. Axis Meaning

### Request Fit

- did the work actually answer the sponsor's request
- did it move the most important thing, not just a nearby thing

### Verification

- were key outputs rechecked
- did fail-closed or status behavior get tested when relevant
- were assumptions left explicit when not verified

### Clarity

- can the sponsor understand what changed quickly
- are role, mission, and next-step explanations readable

### Safety and Governance

- were authority boundaries respected
- were risky actions kept approval-gated
- did the work avoid silent policy drift

### Memory and Process Discipline

- were `DURABLE_MEMORY.md` and `ACTIVE_CONTEXT.md` updated
- was the work integrated into the standing process instead of left ad hoc

## 5. Decision Bands

### `80 to 100`

- acceptable closeout
- may present as complete for this cycle

### `61 to 79`

- incomplete closeout
- revise before treating the cycle as cleanly done

### `40 to 60`

- weak closeout
- restructure, verify again, and improve before presenting as done

### `0 to 39`

- failed closeout
- stop and do not present it as complete

## 6. Required Output Format

The final line of a meaningful work report should use this form:

`Self-check: 88/100 | fit 18/20 | verification 17/20 | clarity 18/20 | safety 18/20 | process 17/20`

If the score is below `80`, the report should briefly acknowledge that the closeout is not yet clean.

## 7. Recording Rule

The score itself does not need to be copied into durable memory every time.

But if the score reveals a repeated weakness, that lesson should be recorded in memory.

