# Worker Patch Batch Decision Flow

## 1. Purpose

This document defines the sponsor-facing batch decision helper for worker prompt patch proposals.

The review board shows what is pending.
The batch decision brief shows which pending items are currently the best approval candidates.

## 2. Scope

The batch decision brief is:

- sponsor-facing
- advisory
- automatically generated
- non-binding

It does not change proposal state by itself.

## 3. Recommendation Rule

The current heuristic is intentionally conservative.

- `approve` is recommended only when:
  - the worker has a preview
  - the worker has an approval request
  - the worker has a promotion review with a promote decision
- `defer` is recommended when the artifact set is complete but promotion evidence is not yet strong enough

## 4. First-Live-Patch Rule

When more than one worker is approval-ready, the brief should identify one primary first-live-patch candidate.

That primary candidate should favor:

- promoted workers
- clearer and narrower hypotheses
- less aggressive training themes

## 5. Boundary

The batch brief may recommend.

Only an explicit sponsor decision should:

- mark a proposal approved
- mark a proposal rejected
- mark a proposal deferred
- allow live prompt patch application
