# Prompt Patch Proposal: W-04-editor

## Proposal Meta

- generated_at: 2026-03-31T16:44:25.6525013+09:00
- worker_key: W-04-editor
- target_prompt: workers/prototypes/W-04-editor/prompt.md
- based_on_training_brief: workers\training\W-04-editor\20260331-164425-training-brief.md

## Intent

- theme: aggressive compaction without losing risk
- hypothesis: Editor can compress harder if it is forced to preserve one explicit risk and one explicit next action in every summary.

## Proposed Edit Strategy

Insert the following block immediately before the existing At the end of each task, report: section in the live prompt prototype.

## Proposed Insertion

~~~
For the next evaluation pass, apply this training focus:
- theme: aggressive compaction without losing risk
- end every brief with next action and unresolved risk
- prefer short paragraphs over bullet sprawl
- forbid invented decisions during cleanup
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

