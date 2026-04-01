# Worker Patch Approval Request: W-05-watcher

## Request Meta

- generated_at: 2026-03-31T16:43:20.3051759+09:00
- worker_key: W-05-watcher
- proposal_path: workers\patch-proposals\W-05-watcher\20260331-164320-prompt-patch-proposal.md
- preview_path: workers\prompt-previews\W-05-watcher\20260331-164320-prompt-preview.md
- target_prompt: workers/prototypes/W-05-watcher/prompt.md

## Requested Decision

- current_status: pending_review
- requested_action: approve_or_reject

## Change Summary

- theme: continuity and stale-state detection
- hypothesis: Watcher becomes more valuable if it speaks only when state drift is real and names the smallest viable follow-up.

## Why This Is Still Safe

- the proposal does not add new tools
- the proposal does not change escalation authority
- a preview exists for review before live mutation
- live application is still blocked unless the proposal is explicitly approved

## Sponsor Command Hints

- approve:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-05-watcher -Decision approve
- reject:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-05-watcher -Decision reject
- defer:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-05-watcher -Decision defer

## Notes

- decision:
- rationale:

