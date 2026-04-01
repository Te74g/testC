# First Live Patch Flow

## 1. Purpose

This document defines the first explicit live prompt patch path for the current primary candidate worker.

The purpose is not to automate approval away.

The purpose is to make the first sponsor-approved live patch easy to review, easy to execute, and easy to audit.

## 2. Current Rule

The first live patch path should be:

1. identify the current primary candidate from the latest batch decision brief
2. generate a sponsor-facing live patch pack
3. keep approval explicit
4. apply only after explicit approval is written into the proposal
5. preserve prompt history and apply log

## 3. Boundary

This path must fail closed.

It must not:

- auto-approve proposals
- skip sponsor review
- mutate a prompt while the proposal is still pending
- apply a worker that is not the current primary candidate unless explicitly redirected

## 4. Current Primary Candidate

The current primary first-live-patch candidate is expected to be:

- `Compass (W-03-researcher)`

That may change later, so the live patch pack should always resolve from the latest decision brief.

## 5. Deliverables

The first live patch path should produce:

- one live patch pack for sponsor review
- one explicit approval command
- one explicit apply command
- one archived prompt snapshot on apply
- one apply log on apply

## 6. Verification Rule

Before apply, the sponsor should be able to inspect:

- proposal
- preview
- approval request
- promotion review
- current target prompt

## 7. Apply Rule

The shortest safe apply path is:

1. approve the proposal explicitly
2. run the primary approved live patch helper
3. inspect prompt history and apply log

If approval was not written, the helper must stop.
