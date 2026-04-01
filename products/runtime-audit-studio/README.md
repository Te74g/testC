# Runtime Audit Studio

This is the first evidence-first product path.

It does not ask the local model to invent a client brief.
It reads the current runtime state and produces a bounded audit pack from:

- `runtime/state/long-run-supervisor.status.json`
- `runtime/state/work-heartbeat/latest.json`
- `runtime/state/local-llm-runtime.state.json`
- `runtime/logs/long-run-supervisor.jsonl`

## Entry Point

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\generate-runtime-audit-pack.ps1
```

## Output

- `runtime-audit.md`
- `generation.json`

## Current Position

This is more trustworthy than the current local-model-generated technical brief path.
Use it for sponsor review and internal audit-style delivery first.

## Packaging Assets

Commercial packaging for this product line now lives here:

- `products/runtime-audit-studio/OFFER_V1.md`
- `products/runtime-audit-studio/INTAKE_TEMPLATE_V1.md`
- `products/runtime-audit-studio/QUOTE_SHEET_V1.md`
- `products/runtime-audit-studio/SAMPLE_QUOTE_V1.md`
- `products/runtime-audit-studio/SPONSOR_REVIEW_PACK_V1.md`
- `products/runtime-audit-studio/FIRST_SPONSOR_DECISION_SHEET_V1.md`
- `products/runtime-audit-studio/PUBLIC_SUMMARY_V1.md`
- `products/runtime-audit-studio/PUBLIC_SUMMARY_APPROVAL_SHEET_V1.md`
- `products/runtime-audit-studio/PROFILE_DRAFT_V1.md`
- `products/runtime-audit-studio/PROFILE_APPROVAL_SHEET_V1.md`
- `products/runtime-audit-studio/OUTREACH_COPY_V1.md`
- `products/runtime-audit-studio/FINAL_PUBLICATION_PACKET_V1.md`
- `products/runtime-audit-studio/FINAL_PUBLIC_STACK_INDEX_V1.md`
- `products/runtime-audit-studio/FIRST_RELEASE_DECISION_SHEET_V1.md`
- `products/runtime-audit-studio/PUBLIC_RELEASE_SEQUENCE_PLAN_V1.md`
