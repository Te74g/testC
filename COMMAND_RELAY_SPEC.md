# Command Relay Spec

## 1. Purpose

This document defines the future command-relay layer for `Northbridge Systems` and the `Claude-side company`.

The goal is to let the companies resume work, redirect work, or call each other through subordinate workers or bots without granting unrestricted self-authority.

## 2. Core Principle

Self-instruction is allowed only as bounded command relay.

This means:

- a worker or bot may send a predefined command
- the command must target an approved receiver
- the command must have a known effect
- the command must be logged
- the command must respect sponsor authority

Not allowed:

- open-ended self-authorizing instructions
- arbitrary financial commands
- arbitrary destructive commands
- hidden or unlogged control messages

## 3. Relay Model

The relay model has four parts:

1. command registry
2. relay worker or bot
3. receiver
4. audit log

### Command Registry

The registry defines allowed commands and their arguments.

### Relay Worker or Bot

The relay agent sends the command in the approved format.

### Receiver

The receiver is the company president, worker, queue, or meeting system that handles the command.

### Audit Log

Every relay action must leave a trace.

## 4. First Intended Use Cases

Initial intended use cases:

- resume a paused work thread
- request a meeting
- route a task to a known worker
- ask for memory refresh
- ask for verification
- escalate a blocker

These are preferred because they improve continuity without immediately increasing danger.

## 5. Deferred Use Cases

These should not be part of the first command set:

- spending
- stock purchase
- external account creation
- destructive file actions
- production deployment
- sensitive data export

These require higher approval layers.

## 6. Example Command Families

### `nc.resume`

Purpose:

- resume a known task or thread

Arguments:

- task id
- reason
- priority

### `nc.call`

Purpose:

- request an intercompany call or meeting

Arguments:

- target company
- topic
- urgency
- desired output

### `nc.verify`

Purpose:

- send work to verification

Arguments:

- target artifact
- criteria

### `nc.memory`

Purpose:

- request a memory update or cleanup pass

Arguments:

- durable or active
- reason

### `nc.escalate`

Purpose:

- elevate a blocker to a company president or sponsor

Arguments:

- blocker summary
- owner
- requested decision

## 7. Example of the User's Idea

A command like:

- `nc.resume codex <task>`

can be implemented as:

- a relay bot resends a structured resume command
- the command points to a known task id or work item
- the receiving side restarts the approved workflow

The important design point is that the bot should send a structured command, not arbitrary free text.

## 8. Command Envelope

Every relay command should include:

- command name
- sender
- receiver
- task id or target id
- reason
- timestamp
- priority
- approval status if relevant

## 9. Approval Boundary

Relay commands do not bypass approval rules.

If a command would trigger spending, irreversible change, or external action, the receiver must convert it into an approval request instead of executing it directly.

## 10. Safety Rule

If the relay worker does not recognize the command exactly, it must reject it rather than guessing.

The system should prefer:

- explicit command registry
- small argument sets
- visible logs
- replayable history

## 11. Suggested Implementation Order

1. create a command registry file
2. define 3 to 5 safe commands
3. create a relay bot that can only send those commands
4. log every relay event
5. test resume, call, verify, and memory commands
6. expand only after successful safe runs

## 12. Relationship to the Larger Project

The command-relay layer is part of the long-term autonomy model.

It should be introduced after worker bootstrap and before high-risk monetization automation.
