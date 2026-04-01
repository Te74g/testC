# Southgate Research Memory System

## Purpose

`Southgate Research` maintains its own two-layer memory system, mirroring the structure established by `Northbridge Systems` but scoped to Southgate's research, strategy, and review responsibilities.

## Layers

- `DURABLE_MEMORY.md`: stable intent, confirmed decisions, operating identity, success/failure patterns
- `ACTIVE_CONTEXT.md`: current objectives, recent work, next steps, blockers, temporary assumptions

## Rules

All rules from the shared `memory/MEMORY_SYSTEM.md` apply:

1. Durable memory is for information that survives across sessions and context compression
2. Active context is for current state that may become stale
3. Promotion rule: stable conclusions move from active to durable
4. Cleanup rule: expired items are deleted, condensed, or promoted
5. Size discipline: active context must stay compact and scannable
6. Mandatory update: both files updated on every meaningful work cycle

## Relationship to Shared Memory

The shared `memory/` at the repo root contains the organization-wide intent file maintained by Northbridge Systems. Southgate Research may read and propose edits to shared memory but maintains its own workspace memory here for company-specific context.

## Ownership

`Southgate Research` owns this memory directory. The sponsor remains final authority on any decision affecting budget, power, or irreversible action.
