# Session Continuity Protocol

## 1. Purpose

This document defines how the system should behave when:

- a session becomes cluttered or degraded
- a clean handoff is needed
- a new session should be opened
- usage limits are reached

The goal is continuity without panic, spam, or messy loss of state.

## 2. Core Rule

When session quality degrades, do not keep pushing blindly.

Instead:

1. detox the session state
2. prepare a clean handoff
3. move to a fresh session if needed

When usage limits are reached, treat that as sleep, not as a signal to keep retrying.

## 3. Detox Trigger Conditions

Start session detox when one or more of these are true:

- context is cluttered
- the task state is hard to reconstruct
- too many stale branches exist
- tool results have become noisy or confusing
- the current session is no longer a clean place to continue
- handoff quality would otherwise degrade

## 4. Detox Procedure

Before leaving a degraded session:

1. update the intent file
2. update working memory
3. condense the current task into a handoff-ready summary
4. list the next concrete step
5. list blockers and approvals
6. remove stale or misleading temporary notes where appropriate

The purpose is to leave behind a strong restart point, not a pile of residue.

## 5. Handoff Packet

A proper handoff should contain:

- current objective
- current phase
- completed work
- next step
- blockers
- relevant files
- approval state

This can live in working memory or in a task bundle.

## 6. Fresh Session Rule

If detox alone is not enough, open a new session and continue from the handoff packet.

The new session should start from:

- durable memory
- working memory
- current task bundle if present

## 7. Usage Limit Rule

If a model or tool reaches a usage cap, rate limit, or session ceiling:

- interpret that state as sleep
- stop retrying in a loop
- record the pause clearly
- prepare the next resume point

Do not keep sending repeated requests just to test whether the cap has lifted.

## 8. Sleep Behavior

When a company or model is sleeping because of usage limits:

- no retry spam
- no frantic escalation
- no pretending the worker is available

Instead:

- mark the worker or company as sleeping
- queue a future resume point
- let other available components continue if appropriate

## 9. Wake and Resume

When the sleeping component becomes available again:

- resume from the prepared handoff
- do not reconstruct the task from memory alone if a better handoff exists

## 10. Relationship to Background Runtime

The background runtime should support this protocol by:

- keeping queue state
- keeping logs
- preserving resume context
- avoiding endless retries

## 11. Minimum Standard

The system should always prefer:

- clean handoff
- explicit sleep state
- explicit resume point

over:

- repeated blind retries
- state loss
- improvised continuation
