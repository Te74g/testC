# Memory System

## 1. Purpose

This repository uses a two-layer memory system so `Northbridge Systems` does not lose the core intent of the project when context is compressed.

The memory system has two layers:

- `DURABLE_MEMORY.md`: the mandatory intent file for long-lived intent, stable decisions, operating identity, and success/failure reference
- `ACTIVE_CONTEXT.md`: the mandatory working memory for current work, temporary plans, active questions, and near-term execution state

This split exists because not all information deserves permanent retention.

## 2. Durable Memory

`DURABLE_MEMORY.md` is the repository's intent file.

It is for information that should survive across long gaps, new sessions, and context compression.

Put only stable material there:

- why this organization exists
- who the parties are
- confirmed structural decisions
- enduring operating principles
- approved long-term rules
- success patterns worth reusing
- failure patterns worth avoiding

Do not fill durable memory with temporary notes.

## 3. Active Context

`ACTIVE_CONTEXT.md` is the repository's working memory.

It is for information that matters now, but may become stale.

Put active material there:

- current objectives
- recently completed work
- next likely steps
- current blockers
- temporary assumptions
- open questions

This file should be pruned often.

## 4. Promotion Rule

If a fact stops being temporary and becomes a durable decision, move or summarize it into `DURABLE_MEMORY.md`.

Do not copy large chunks. Condense the lesson.

## 5. Cleanup Rule

When an item in `ACTIVE_CONTEXT.md` is no longer useful:

- delete it
- or condense it into one short outcome line
- or promote the durable part into `DURABLE_MEMORY.md`

The active file should stay easy to scan.

## 6. Size Discipline

The intent file may grow slowly over time.

Working memory must stay compact.

If active context becomes crowded:

1. remove expired material
2. condense completed items
3. promote stable conclusions
4. leave only what helps the next execution step

## 7. Ownership

`Northbridge Systems` maintains the memory system structure.

The `Claude-side company` may read, propose edits, and use the same memory rules.

The sponsor remains the final authority on any decision that affects budget, power, or irreversible action.

## 8. Mandatory Update Practice

The intent file must be updated on 100% of meaningful work cycles.

This is mandatory because it is the long-term reference for:

- intent
- confirmed decisions
- reusable successes
- notable failures
- changes in operating direction

Working memory must also be updated by default on every work cycle.

If working memory is not changed, the reason must be explicit and rare.

The default rule is:

1. update `DURABLE_MEMORY.md`
2. update `ACTIVE_CONTEXT.md`
3. then continue or close the task

## 9. Intent File Outcome Logging

`DURABLE_MEMORY.md` should be usable as a reference for success and failure patterns.

Meaningful outcomes should be captured in compact durable form such as:

- what was attempted
- what succeeded
- what failed
- what was learned
- what rule changed because of it

## 10. Working Memory Update Standard

Each update to `ACTIVE_CONTEXT.md` should keep it useful for the next step.

It should usually refresh:

- current objective
- what changed recently
- next steps
- blockers
- active constraints

## 11. Absolute Rule

These memory files are not optional convenience notes.

They are mandatory operating documents.

If there is any doubt about whether they should be updated, the answer is yes.
