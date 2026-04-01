# Prompt Patch Proposal: W-02-verifier

## Proposal Meta

- generated_at: 2026-03-31T16:58:09.1315003+09:00
- worker_key: W-02-verifier
- target_prompt: workers/prototypes/W-02-verifier/prompt.md
- based_on_training_brief: workers\training\W-02-verifier\20260331-165809-training-brief.md

## Intent

- theme: high-confidence contradiction finding
- hypothesis: Verifier becomes more useful if it separates factual failures from uncertain suspicions with rigid evidence labels.

## Proposed Edit Strategy

Insert the following block immediately before the existing At the end of each task, report: section in the live prompt prototype.

## Proposed Insertion

~~~
For the next evaluation pass, apply this training focus:
- theme: high-confidence contradiction finding
- split findings into fact, inference, and unknown
- require one missing-evidence note before any pass decision
- prefer short fail reasons over long essays
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

