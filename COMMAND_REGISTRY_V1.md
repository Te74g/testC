# Command Registry V1

## 1. Purpose

This document defines the first approved command set for the background relay bot.

The first version is intentionally small and low-risk.

## 2. V1 Commands

The approved V1 commands are:

- `nc.memory`
- `nc.call`
- `nc.resume`
- `nc.worker.seed`

No other command should be accepted by the V1 relay bot.

## 3. Shared Envelope

Every queued command must include:

- `id`
- `command`
- `sender`
- `receiver`
- `reason`
- `priority`
- `created_at`
- `approval_status`
- `signature`
- `payload`

## 4. `nc.memory`

Purpose:

- request a memory refresh or cleanup task

Required payload fields:

- `memory_target`
- `operation`

Allowed `memory_target` values:

- `durable`
- `active`
- `both`

Allowed `operation` values:

- `refresh`
- `cleanup`
- `review`

## 5. `nc.call`

Purpose:

- request an intercompany call or meeting

Required payload fields:

- `target_company`
- `topic`
- `desired_output`

Allowed `target_company` values:

- `Northbridge Systems`
- `Southgate Research`

## 6. `nc.resume`

Purpose:

- resume a known task or work item

Required payload fields:

- `task_id`
- `bundle_path`

`bundle_path` should point to the task bundle or other structured resume context.

## 7. Rejection Rule

The relay bot must reject a command if:

- the command name is unknown
- a required field is missing
- the payload shape is invalid
- the approval boundary is violated
- the JSON cannot be parsed

## 8. `nc.worker.seed`

Purpose:

- request creation of a prompt-only worker prototype from the approved worker catalog

Required payload fields:

- `worker_key`
- `prototype_stage`

Allowed `worker_key` values:

- `W-01-builder`
- `W-02-verifier`
- `W-03-researcher`
- `W-04-editor`
- `W-05-watcher`

Allowed `prototype_stage` values:

- `prompt_only`

## 9. V1 Scope Limit

V1 does not include:

- spending commands
- hardware commands
- account commands
- destructive commands
- production deployment commands
- sensitive export commands
