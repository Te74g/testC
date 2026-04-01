# Worker Patch Ops Studio

This is the next evidence-first product candidate after `Runtime Audit Studio`.

It is not a promise of autonomous self-improving agents.
It is a bounded service line for:

- worker evaluation
- failure-pattern diagnosis
- reversible prompt patch proposals
- sponsor-gated live patch application

## Why This Product Exists

`Runtime Audit Studio` explains whether the operating system is healthy.

`Worker Patch Ops Studio` exists for the next question:

- if the runtime is healthy enough, which worker should be corrected, why, and how should the patch be reviewed?

## Current Source Assets

This product candidate is grounded in assets that already exist:

- `runtime/local-eval-runner.js`
- `scripts/run-local-worker-evaluation.ps1`
- `scripts/draft-worker-patch-proposal.ps1`
- `scripts/draft-worker-patch-approval-request.ps1`
- `scripts/render-worker-patch-batch-decision-brief.ps1`
- `scripts/apply-approved-worker-patch.ps1`
- `WORKER_PROMPT_PATCH_POLICY.md`
- `WORKER_PATCH_APPROVAL_FLOW.md`
- `WORKER_PATCH_BATCH_DECISION_FLOW.md`
- `WORKER_PATCH_REVIEW_BOARD.md`

## Current Position

This is not yet the first sellable baseline.

Current role:

- next incubated product
- evidence-first improvement line
- still sponsor-gated for live patch application

## Packaging Assets

- `products/worker-patch-ops-studio/OFFER_V1.md`
- `products/worker-patch-ops-studio/INTAKE_TEMPLATE_V1.md`
- `products/worker-patch-ops-studio/SPONSOR_REVIEW_PACK_V1.md`
- `products/worker-patch-ops-studio/FIRST_SPONSOR_DECISION_SHEET_V1.md`
- `products/worker-patch-ops-studio/PUBLIC_SUMMARY_V1.md`
- `products/worker-patch-ops-studio/PUBLIC_SUMMARY_APPROVAL_SHEET_V1.md`
- `products/worker-patch-ops-studio/PROFILE_DRAFT_V1.md`
- `products/worker-patch-ops-studio/PROFILE_APPROVAL_SHEET_V1.md`

## Boundaries

Safe scope:

- evaluate worker outputs
- diagnose prompt-level failure patterns
- prepare reversible patch proposals
- prepare approval-ready previews

Not safe to imply:

- autonomous self-rewriting
- production-grade implementation guarantees
- removal of sponsor approval
- broad runtime implementation bundled into patch work
