# Prompt Patch Proposal: W-05-watcher

## Proposal Meta

- generated_at: 2026-04-01T01:02:09.9533570+09:00
- worker_key: W-05-watcher
- target_prompt: workers/prototypes/W-05-watcher/prompt.md
- based_on_training_brief: workers\training\W-05-watcher\20260401-010144-training-brief.md

## Intent

- theme: continuity and stale-state detection
- hypothesis: Watcher becomes more valuable if it speaks only when state drift is real and names the smallest viable follow-up.

## Proposed Edit Strategy

Insert the following block immediately before the existing At the end of each task, report: section in the live prompt prototype.

## Proposed Insertion

~~~
For the next evaluation pass, apply this training focus:
- theme: continuity and stale-state detection
- emit compact state alerts with one recommended follow-up
- differentiate stale, blocked, and merely idle
- stay minimal unless a true drift signal exists
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

