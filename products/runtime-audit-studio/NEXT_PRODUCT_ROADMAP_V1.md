# Runtime Audit Studio Next Product Roadmap V1

## Purpose

This document answers one practical question:

- after `Runtime Audit Studio`, what should Northbridge build and sell next?

It exists to stop two bad patterns:

- drifting from the first sellable line into three half-finished offers
- jumping from bounded audit work straight into implementation claims

## Recommended Portfolio Position

Current commercial baseline:

- `Runtime Audit Studio`

Recommended next incubated product:

- `Worker Patch Ops Studio`

Promotion candidate after quality gates:

- `Technical Brief Studio`

Later pilot only:

- runtime continuity / automation implementation work

## Now, Next, Later

### Now

Sell now:

- `Runtime Audit Studio Package A: Snapshot Runtime Audit`

Expand only after repeated proof:

- `Package B`
- `Package C`

Reason:

- this line is evidence-first
- it is bounded
- it reads real state and logs
- it does not depend on freeform model polish

### Next

Next product to incubate:

- `Worker Patch Ops Studio`

Why this is the cleanest next move:

- the repo already has worker evaluation, patch proposal, preview, approval, and gated apply paths
- the offer can stay evidence-first instead of drifting into open-ended implementation
- it naturally follows a runtime audit because the audit can identify worker-quality issues

Feasible source assets already exist:

- `runtime/local-eval-runner.js`
- `scripts/run-local-worker-evaluation.ps1`
- `scripts/draft-worker-patch-proposal.ps1`
- `scripts/render-worker-patch-batch-decision-brief.ps1`
- `scripts/apply-approved-worker-patch.ps1`

Initial packaging assets now exist:

- `products/worker-patch-ops-studio/README.md`
- `products/worker-patch-ops-studio/OFFER_V1.md`
- `products/worker-patch-ops-studio/INTAKE_TEMPLATE_V1.md`
- `products/worker-patch-ops-studio/SPONSOR_REVIEW_PACK_V1.md`
- `products/worker-patch-ops-studio/FIRST_SPONSOR_DECISION_SHEET_V1.md`

Recommended scope:

- evaluate worker behavior
- identify failure patterns
- propose bounded prompt patches
- keep live apply sponsor-gated

Not recommended scope:

- promise autonomous optimization
- promise hands-off prompt evolution
- promise broad implementation beyond worker prompt correction

### Later

Promotion candidate after gates:

- `Technical Brief Studio`

Reason:

- it is already productized end-to-end
- but the current sample still fails external-send review
- it is closer to hallucination and tone drift than the audit path

Later pilot:

- runtime continuity / automation implementation

Reason:

- this is commercially tempting
- but it pushes Northbridge into implementation and reliability claims too early

## Promotion Gates

### Operational Gates

- recurring tick supervision remains stable
- local runtime health stays explicit and recoverable
- guarded runtime path remains the default, not a weak fallback

### Commercial Gates

- at least 3 paid external audit deliveries
- explicit client acceptance on bounded scope
- no scope confusion between audit and implementation

### Quality Gates

For `Technical Brief Studio`:

- `ready_for_external_send: yes` on repeated reviewer runs
- no unexpected non-ASCII corruption
- recommendation anchor present
- handoff owner present
- headings complete

For `Worker Patch Ops Studio`:

- full local eval evidence stays fresh across all workers
- proposed patches remain approval-gated
- patch previews stay reversible

## Claims To Avoid

- zero crash guarantees
- production-ready claims
- autonomous delivery claims
- implementation included inside audit pricing
- short internal proof presented as long-duration reliability proof

## Recommended Sequence

1. keep `Runtime Audit Studio` as the current sellable baseline
2. incubate `Worker Patch Ops Studio` as the next evidence-first product
3. promote `Technical Brief Studio` only after reviewer gates pass consistently
4. consider automation implementation only as a later sponsor-approved pilot

## Sponsor Decision Log

Decision 1:

- confirm `Runtime Audit Studio` remains the first product line

Decision 2:

- confirm `Worker Patch Ops Studio` is the next incubated product

Decision 3:

- keep `Technical Brief Studio` internal-only until the quality gates above pass

Decision 4:

- defer automation implementation as a later pilot, not the next sellable product
