# Worker Patch Batch Decision Brief

## Decision Meta

- generated_at: 2026-04-01T03:35:15.0200920+09:00
- pending_worker_count: 5
- recommended_approve_count: 2
- recommended_defer_count: 3
- primary_first_live_patch_candidate: W-03-researcher
- primary_first_live_patch_candidate_display: Compass (W-03-researcher)

## Sponsor Guidance

- approve only workers with both complete artifacts and stronger promotion evidence
- use defer when the patch itself looks safe but readiness evidence is still thin
- if you want one first live patch, start with Compass (W-03-researcher)

## Combined Command Draft

~~~
powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-03-researcher -Decision approve
powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-04-editor -Decision approve
powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-01-builder -Decision defer
powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-02-verifier -Decision defer
powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-05-watcher -Decision defer
~~~

## Compass (W-03-researcher)

- worker_key: W-03-researcher
- character_name: Compass
- role_name: Researcher
- recommendation: approve
- reason: complete artifact set plus promote decision
- theme: option analysis without drift
- hypothesis: Researcher can stay exploratory without wandering if every brief ends in a forced recommendation plus unresolved questions.
- promotion_signal: promoted
- proposal: workers\patch-proposals\W-03-researcher\20260401-032759-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-03-researcher\20260401-032759-prompt-preview.md
- approval_request: workers\approval-requests\W-03-researcher\20260401-032759-patch-approval-request.md
- promotion_review: workers\reviews\W-03-researcher\promotion-review.md
- decision_command: powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-03-researcher -Decision approve

## Quill (W-04-editor)

- worker_key: W-04-editor
- character_name: Quill
- role_name: Editor
- recommendation: approve
- reason: complete artifact set plus promote decision
- theme: aggressive compaction without losing risk
- hypothesis: Editor can compress harder if it is forced to preserve one explicit risk and one explicit next action in every summary.
- promotion_signal: promoted
- proposal: workers\patch-proposals\W-04-editor\20260401-032914-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-04-editor\20260401-032914-prompt-preview.md
- approval_request: workers\approval-requests\W-04-editor\20260401-032914-patch-approval-request.md
- promotion_review: workers\reviews\W-04-editor\promotion-review.md
- decision_command: powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-04-editor -Decision approve

## Forge (W-01-builder)

- worker_key: W-01-builder
- character_name: Forge
- role_name: Builder
- recommendation: defer
- reason: promotion evidence is not strong enough yet
- theme: bounded implementation speed
- hypothesis: Builder can stay fast without getting sloppy if every plan explicitly names rollback and verification checkpoints.
- promotion_signal: reviewed
- proposal: workers\patch-proposals\W-01-builder\20260401-032656-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-01-builder\20260401-032657-prompt-preview.md
- approval_request: workers\approval-requests\W-01-builder\20260401-032657-patch-approval-request.md
- promotion_review: workers\reviews\W-01-builder\promotion-review.md
- decision_command: powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-01-builder -Decision defer

## Ledger (W-02-verifier)

- worker_key: W-02-verifier
- character_name: Ledger
- role_name: Verifier
- recommendation: defer
- reason: promotion evidence is not strong enough yet
- theme: high-confidence contradiction finding
- hypothesis: Verifier becomes more useful if it separates factual failures from uncertain suspicions with rigid evidence labels.
- promotion_signal: reviewed
- proposal: workers\patch-proposals\W-02-verifier\20260401-032722-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-02-verifier\20260401-032722-prompt-preview.md
- approval_request: workers\approval-requests\W-02-verifier\20260401-032722-patch-approval-request.md
- promotion_review: workers\reviews\W-02-verifier\promotion-review.md
- decision_command: powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-02-verifier -Decision defer

## Lantern (W-05-watcher)

- worker_key: W-05-watcher
- character_name: Lantern
- role_name: Watcher
- recommendation: defer
- reason: promotion evidence is not strong enough yet
- theme: continuity and stale-state detection
- hypothesis: Watcher becomes more valuable if it speaks only when state drift is real and names the smallest viable follow-up.
- promotion_signal: reviewed
- proposal: workers\patch-proposals\W-05-watcher\20260401-032457-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-05-watcher\20260401-032457-prompt-preview.md
- approval_request: workers\approval-requests\W-05-watcher\20260401-032457-patch-approval-request.md
- promotion_review: workers\reviews\W-05-watcher\promotion-review.md
- decision_command: powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-05-watcher -Decision defer

