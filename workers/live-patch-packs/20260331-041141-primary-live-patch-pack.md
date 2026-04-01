# Primary Live Patch Pack

## Pack Meta

- generated_at: 2026-03-31T04:11:41.6167932+09:00
- worker_key: W-03-researcher
- display_name: Compass (W-03-researcher)
- character_name: Compass
- role_name: Researcher

## Why This Worker

The latest batch decision brief names Compass (W-03-researcher) as the current primary first-live-patch candidate.

## Review Set

- proposal: workers\patch-proposals\W-03-researcher\20260331-033733-prompt-patch-proposal.md
- preview: workers\prompt-previews\W-03-researcher\20260331-033734-prompt-preview.md
- approval_request: workers\approval-requests\W-03-researcher\20260331-034922-patch-approval-request.md
- promotion_review: workers\reviews\W-03-researcher\promotion-review.md
- target_prompt: workers\prototypes\W-03-researcher\prompt.md

## Sponsor Commands

- approve proposal:
  powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey W-03-researcher -Decision approve
- apply approved live patch:
  powershell -ExecutionPolicy Bypass -File .\scripts\apply-primary-approved-live-patch.ps1

## Fail-Closed Notes

- the apply helper resolves the primary candidate from the latest decision brief
- the apply helper still fails if the proposal is not explicitly approved
- prompt history and an apply log are written during live apply

## Short Checklist

1. review proposal and preview
2. confirm the approval request still looks right
3. approve the proposal explicitly
4. run the primary approved live patch helper
5. inspect prompt history and apply log

