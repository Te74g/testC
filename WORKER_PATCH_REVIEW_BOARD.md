# Worker Patch Review Board

## 1. Purpose

This document defines the board layer for worker prompt patch approvals.

Approval requests are useful, but once multiple workers are active the sponsor needs one place to see pending decisions.

## 2. Board Role

The review board should summarize:

- the latest proposal per worker
- the current status
- the latest preview
- the latest approval request
- the next likely command

## 3. Scope

The board is:

- read-only
- summarizing
- sponsor-facing
- safe to generate automatically

The board is not an approval decision by itself.

## 4. Current Rule

The unattended loop may generate the board automatically.

Actual decision changes still require explicit action.
