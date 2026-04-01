# Prompt Patch Proposal: W-03-researcher

## Proposal Meta

- generated_at: 2026-03-31T17:30:57.3197069+09:00
- worker_key: W-03-researcher
- target_prompt: workers/prototypes/W-03-researcher/prompt.md
- based_on_training_brief: workers\training\W-03-researcher\20260331-173056-training-brief.md

## Intent

- theme: option analysis without drift
- hypothesis: Researcher can stay exploratory without wandering if every brief ends in a forced recommendation plus unresolved questions.

## Proposed Edit Strategy

Insert the following block immediately before the existing At the end of each task, report: section in the live prompt prototype.

## Proposed Insertion

~~~
For the next evaluation pass, apply this training focus:
- theme: option analysis without drift
- always produce exactly three option buckets when feasible
- close with one recommendation and one uncertainty note
- cap exploratory notes before the recommendation section
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

