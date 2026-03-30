# Background Operation Spec

## 1. Purpose

This document defines how the two-company system should operate in the background without interrupting the sponsor's normal PC work.

The goal is continuity without forced foreground interaction.

## 2. Core Principle

Do not depend on an interactive chat session staying alive forever.

Background continuity should come from:

- a local queue
- durable memory
- relay commands
- a background worker or bot process
- explicit approval checkpoints

The session may start work, but a separate background layer must carry continuity.

## 3. Non-Interruptive Operation Rule

The sponsor's normal work should not be interrupted unless one of these is true:

- approval is required
- a blocker requires a human decision
- a failure needs immediate attention
- the sponsor explicitly requests a status check

Everything else should happen quietly in the background.

## 4. Recommended Architecture

Use four layers:

1. command source
2. persistent queue
3. background relay bot
4. worker execution target

### Command Source

Commands may come from:

- sponsor actions
- company presidents
- approved subordinate relay workers

### Persistent Queue

The queue stores pending work and survives session loss.

It may be implemented with:

- JSON files
- SQLite
- Redis
- a lightweight local database

### Background Relay Bot

The relay bot watches the queue and sends only approved commands.

It should be:

- local
- persistent
- restartable
- limited by command registry

### Worker Execution Target

The target is the worker system that actually performs the task or resumes the task.

## 5. Minimal Background Capabilities

The first background version only needs to do these:

- watch for new commands
- resume known tasks
- request meetings
- request memory updates
- request verification
- log outcomes

This is enough to prove continuity without increasing risk too early.

## 6. Things That Must Not Happen in Background V1

Do not allow Background V1 to:

- spend money
- purchase hardware
- buy stocks
- create outside accounts
- deploy to production
- delete important files
- export sensitive information

If background work reaches one of those boundaries, it must pause and create an approval request.

## 7. Why This Reduces Interruption

Without a background layer:

- the user has to manually restart context
- tasks stop when the session ends
- reminders are easy to lose

With a background layer:

- queue state survives
- relay state survives
- work can resume from stored instructions
- the sponsor is only interrupted when needed

## 8. Suggested Local Implementation Path

Stage 1:

- file-based queue
- file-based logs
- command registry
- one background watcher process

Stage 2:

- promote queue to SQLite
- add retry tracking
- add task states
- add failure alerts

Stage 3:

- add intercompany routing
- add approval inbox integration
- add dashboard or tray status

## 9. Example Flow

1. `Northbridge Systems` creates `nc.resume task-17`
2. the relay bot reads the command from the queue
3. the bot validates the command against the registry
4. the bot forwards the command to the approved receiver
5. the receiver resumes the work
6. the result is written to log and queue state
7. the sponsor is notified only if approval or attention is required

## 10. Foreground vs Background Split

Foreground:

- sponsor approvals
- major decisions
- high-risk actions
- optional status review

Background:

- queue polling
- resume commands
- memory refresh requests
- meeting scheduling
- verification routing
- result logging

## 11. Constraint

The current interactive Codex session should be treated as a control point, not as the only runtime.

A real background system needs a local bot or service process outside the chat loop.

The background system should also respect:

- session detox
- clean handoff
- sleep on usage cap
- no blind retry loops

## 12. Next Build Step

The next practical artifact should be:

- `COMMAND_REGISTRY_V1.md`

followed by:

- a local queue format
- a minimal relay bot
