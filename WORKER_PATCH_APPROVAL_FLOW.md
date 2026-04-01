# Worker Patch Approval Flow

## 1. Purpose

This document defines how worker prompt patch proposals move into sponsor review without weakening the approval boundary.

## 2. Flow

The intended flow is:

1. patch proposal exists
2. prompt preview exists
3. patch approval request is drafted
4. sponsor or authorized president marks the proposal decision
5. live patch application is attempted only after explicit approval

## 3. Approval Request Rule

An approval request should summarize:

- the worker
- the proposal theme
- the target prompt
- the preview path
- the reason the change is safe
- the decision still needed

## 4. Decision Rule

The decision should be written back into the proposal itself.

Allowed states are:

- `approved`
- `rejected`
- `deferred`

Only `approved` should flip:

- `approved_for_live_patch: yes`

## 5. Boundaries

Approval requests may be generated automatically.

Approval decisions should remain explicit and auditable.

## 6. Current Scope

At the current stage:

- request generation is routine
- proposal marking is explicit
- live application is still gated
