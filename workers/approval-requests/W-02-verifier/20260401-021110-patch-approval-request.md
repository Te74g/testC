# Worker Patch Approval Request: W-02-verifier

## Request Meta

- generated_at: 2026-04-01T02:11:10.1793300+09:00
- worker_key: W-02-verifier
- proposal_path: workers\patch-proposals\W-02-verifier\20260401-021108-prompt-patch-proposal.md
- preview_path: workers\prompt-previews\W-02-verifier\20260401-021109-prompt-preview.md
- target_prompt: workers/prototypes/W-02-verifier/prompt.md

## Requested Decision

- current_status: pending_review
- requested_action: approve_or_reject

## Change Summary

- theme: high-confidence contradiction finding
- hypothesis: Verifier becomes more useful if it separates factual failures from uncertain suspicions with rigid evidence labels.

## Why This Is Still Safe

- the proposal does not add new tools
- the proposal does not change escalation authority
- a preview exists for review before live mutation
- live application is still blocked unless the proposal is explicitly approved

## Sponsor Command Hints

- approve:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-02-verifier -Decision approve
- reject:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-02-verifier -Decision reject
- defer:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-02-verifier -Decision defer

## Notes

- decision:
- rationale:

