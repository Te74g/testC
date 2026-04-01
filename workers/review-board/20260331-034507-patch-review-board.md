# Pending Worker Patch Review Board

## Board Meta

- generated_at: 2026-03-31T03:45:07.6533118+09:00
- pending_review_count: 5
- worker_count_on_board: 5

## Sponsor Guidance

- review pending workers first
- use the approval request file for rationale
- only apply live patches after explicit approval

## W-01-builder

- status: pending_review
- approved_for_live_patch: no
- theme: bounded implementation speed
- proposal: workers\patch-proposals\W-01-builder\20260331-033030-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-01-builder\20260331-033636-prompt-preview.md
- approval_request: workers\approval-requests\W-01-builder\20260331-034234-patch-approval-request.md
- suggested_next_command: powershell -ExecutionPolicy Bypass -File .\\scripts\\set-worker-patch-proposal-decision.ps1 -WorkerKey W-01-builder -Decision approve|reject|defer

## W-02-verifier

- status: pending_review
- approved_for_live_patch: no
- theme: high-confidence contradiction finding
- proposal: workers\patch-proposals\W-02-verifier\20260331-033634-prompt-patch-proposal.md
- preview: not_available
- approval_request: not_available
- suggested_next_command: powershell -ExecutionPolicy Bypass -File .\\scripts\\set-worker-patch-proposal-decision.ps1 -WorkerKey W-02-verifier -Decision approve|reject|defer

## W-03-researcher

- status: pending_review
- approved_for_live_patch: no
- theme: option analysis without drift
- proposal: workers\patch-proposals\W-03-researcher\20260331-033733-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-03-researcher\20260331-033734-prompt-preview.md
- approval_request: not_available
- suggested_next_command: powershell -ExecutionPolicy Bypass -File .\\scripts\\set-worker-patch-proposal-decision.ps1 -WorkerKey W-03-researcher -Decision approve|reject|defer

## W-04-editor

- status: pending_review
- approved_for_live_patch: no
- theme: aggressive compaction without losing risk
- proposal: workers\patch-proposals\W-04-editor\20260331-033902-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-04-editor\20260331-033902-prompt-preview.md
- approval_request: not_available
- suggested_next_command: powershell -ExecutionPolicy Bypass -File .\\scripts\\set-worker-patch-proposal-decision.ps1 -WorkerKey W-04-editor -Decision approve|reject|defer

## W-05-watcher

- status: pending_review
- approved_for_live_patch: no
- theme: continuity and stale-state detection
- proposal: workers\patch-proposals\W-05-watcher\20260331-032813-prompt-patch-proposal.md
- preview: not_available
- approval_request: not_available
- suggested_next_command: powershell -ExecutionPolicy Bypass -File .\\scripts\\set-worker-patch-proposal-decision.ps1 -WorkerKey W-05-watcher -Decision approve|reject|defer

