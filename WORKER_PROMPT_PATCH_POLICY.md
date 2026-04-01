# Worker Prompt Patch Policy

## 1. Purpose

This document defines how reversible prompt patch proposals can move toward real prompt changes without collapsing the approval boundary.

## 2. Required Stages

The patch path is:

1. worker-lab iteration
2. training brief
3. prompt revision candidate
4. prompt patch proposal
5. prompt preview
6. approved live patch

The system should not jump from lab note directly to live prompt mutation.

## 3. Preview Rule

Before any live prompt is edited, the system should render a preview of the patched prompt.

This keeps the decision visible and reviewable.

## 4. Approval Rule

Live prompt mutation requires an explicit proposal approval state.

The proposal must say:

- `approved_for_live_patch: yes`

Anything else means:

- do not apply

## 5. Archive Rule

If a live prompt is updated, the old prompt should be archived first.

The archive should preserve:

- prior prompt content
- source proposal reference
- application timestamp

## 6. Safety Rule

Patch application must:

- preserve worker identity
- preserve escalation boundaries
- preserve blocked-tool boundaries
- fail closed if the target section cannot be found

## 7. Current Scope

At the current stage, preview generation is routine and low risk.

Live application remains gated and should only occur after explicit approval.

## 8. Tooling

The controlled patch flow should use:

- `scripts/render-worker-prompt-preview.ps1`
- `scripts/apply-approved-worker-patch.ps1`

Preview generation is routine.

Live application should fail closed unless the proposal explicitly says:

- `approved_for_live_patch: yes`
