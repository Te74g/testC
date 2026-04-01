# Scheduled Job Runtime

## Purpose

This repository now has a small repo-local scheduled-job layer inspired by the exposed `.codex/src` cron-task design.

The goal is not full cron parity.

The goal is:

- bounded recurring maintenance
- visible state
- repo-local control
- no hidden authority

## Current Job

The first scheduled job is:

- `northbridge_dream`

It is defined in `runtime/config/scheduled-jobs.v1.json` and currently executes `scripts/run-northbridge-dream.ps1`.

## State

Scheduler state lives in:

- `runtime/state/scheduled-jobs.state.json`

That file records:

- last scheduler run
- per-job status
- last completion time
- recent output

## Integration

The normal unattended loop now calls the scheduled-job layer from `scripts/continue-bot-work.ps1`.

This means scheduled maintenance is part of the normal repo-local runtime rather than a separate manual ritual.
