# Prompt Patch Proposal: W-01-builder

## Proposal Meta

- generated_at: 2026-04-01T02:47:21.0779845+09:00
- worker_key: W-01-builder
- target_prompt: workers/prototypes/W-01-builder/prompt.md
- based_on_training_brief: workers\training\W-01-builder\20260401-024630-training-brief.md

## Intent

- theme: bounded implementation speed
- hypothesis: Builder can stay fast without getting sloppy if every plan explicitly names rollback and verification checkpoints.

## Proposed Edit Strategy

Insert the following block immediately before the existing At the end of each task, report: section in the live prompt prototype.

## Proposed Insertion

~~~
For the next evaluation pass, apply this training focus:
- theme: bounded implementation speed
- require a one-line rollback note in every response
- force an explicit verification step before claiming completion
- keep output terse while naming the changed artifact set
Keep the original authority boundary unchanged.
~~~

## Why This Stays Safe

- it does not expand tool access
- it does not change escalation authority
- it is reversible
- it is narrow enough to test in the next evaluation pass

## Decision

- status: pending_review
- approved_for_live_patch: no
- notes:

