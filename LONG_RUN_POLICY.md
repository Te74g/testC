# Long Run Policy

## 1. Purpose

This document defines how to run the system for long windows such as 10 hours without relying on one fragile foreground session.

## 2. Core Model

Long runs should use a background supervisor.

The supervisor should:

- keep the relay bot available
- trigger the canonical continue command
- write heartbeat records
- stop after the requested time window

## 3. Default Entry Point

The standard start command is:

- `scripts/start-long-run-supervisor.ps1`

The supervisor executes:

- `scripts/continue-bot-work.ps1`
- `scripts/write-bot-work-heartbeat.ps1`

## 4. Current Scope

The current long-run scope is low-risk and repository-focused.

It is suitable for:

- worker prototype upkeep
- evaluation bundle upkeep
- promotion review scaffolding
- relay health checks
- heartbeat logging

It is not yet a full autonomous monetization loop.

## 5. Status and Stop

Use:

- `scripts/status-long-run-supervisor.ps1`
- `scripts/stop-long-run-supervisor.ps1`

## 6. Boundary

Long runs do not bypass:

- sponsor approval
- external escalation boundaries
- new-work quality gate rules

## 7. Infinite Work Clarification

The system should try to avoid idle time.

But long-run work should still remain:

- low-risk
- reversible
- explainable
- auditable
