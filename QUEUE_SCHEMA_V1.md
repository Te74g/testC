# Queue Schema V1

## 1. Purpose

This document defines the file-based queue format for the first background relay bot.

## 2. Directory Layout

The relay runtime uses these directories under `runtime/`:

- `queue/pending`
- `queue/processing`
- `queue/done`
- `queue/failed`
- `inbox/memory`
- `inbox/call`
- `inbox/resume`
- `logs`
- `state`

## 3. Pending Queue File

Each queued command is stored as one JSON file in `runtime/queue/pending`.

Suggested filename:

- `YYYYMMDD-HHMMSSmmm-<id>.json`

## 4. Envelope Example

```json
{
  "id": "3d6a8f5c4f4a4f1995a96f6d86f81942",
  "command": "nc.memory",
  "sender": "Northbridge Systems",
  "receiver": "Northbridge Systems",
  "reason": "refresh active memory after worker-bootstrap step",
  "priority": "normal",
  "created_at": "2026-03-31T02:10:00+09:00",
  "approval_status": "not_required",
  "payload": {
    "memory_target": "active",
    "operation": "refresh"
  }
}
```

## 5. State Transitions

Queue files move through these states:

1. `pending`
2. `processing`
3. `done` or `failed`

The relay bot should never execute directly from `pending` without first claiming the file into `processing`.

## 6. Done Record

A processed file in `done` should include:

- original envelope
- `processed_at`
- `status`
- `delivery_path`

## 7. Failed Record

A failed file in `failed` should include:

- original envelope if parseable
- `failed_at`
- `status`
- `error`

## 8. Log File

The relay bot writes event records to:

- `runtime/logs/relay-bot.jsonl`

Each line should be valid JSON.

## 9. Status File

The relay bot writes status to:

- `runtime/state/relay-bot.status.json`

This should include:

- `pid`
- `started_at`
- `last_heartbeat`
- `processed_count`
- `failed_count`
- `queue_counts`

## 10. V1 Safety Rule

If the runtime sees an unexpected file shape or invalid JSON, it must fail the item rather than guessing.
