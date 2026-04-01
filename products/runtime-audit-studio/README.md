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

## Roadmap Position In Company Portfolio

Current role:

- first sellable product line
- evidence-first commercial baseline

Next commercial logic:

- keep `Runtime Audit Studio` as the first bounded offer
- incubate the next product without widening claims too early
- only promote more freeform or implementation-adjacent products when their gates are met

Roadmap reference:

- `products/runtime-audit-studio/NEXT_PRODUCT_ROADMAP_V1.md`

## Operational Evidence Dependencies

This product only stays honest if it keeps reading real operational evidence.

Its strongest inputs remain:

- `runtime/state/long-run-supervisor.status.json`
- `runtime/state/work-heartbeat/latest.json`
- `runtime/state/local-llm-runtime.state.json`
- `runtime/logs/long-run-supervisor.jsonl`

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
- `products/runtime-audit-studio/MARKETPLACE_LISTING_DRAFT_V1.md`
- `products/runtime-audit-studio/MARKETPLACE_LISTING_APPROVAL_SHEET_V1.md`
- `products/runtime-audit-studio/PLATFORM_LISTING_VARIANTS_V1.md`
- `products/runtime-audit-studio/FINAL_PUBLICATION_PACKET_V1.md`
- `products/runtime-audit-studio/FINAL_PUBLIC_STACK_INDEX_V1.md`
- `products/runtime-audit-studio/FINAL_COMMERCIAL_PACKET_V1.md`
- `products/runtime-audit-studio/FIRST_COMMERCIAL_ACTION_SHEET_V1.md`
- `products/runtime-audit-studio/FIRST_RELEASE_DECISION_SHEET_V1.md`
- `products/runtime-audit-studio/PUBLIC_RELEASE_SEQUENCE_PLAN_V1.md`
- `products/runtime-audit-studio/NEXT_PRODUCT_ROADMAP_V1.md`
