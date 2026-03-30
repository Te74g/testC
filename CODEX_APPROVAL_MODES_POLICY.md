# Codex Approval Modes Policy

## 1. Purpose

This document defines the operating policy for Codex CLI approval modes in this project.

The goal is to reduce unnecessary approval friction while keeping normal development safe.

## 2. Project Brief

- project: `Codex CLI approval modes` introduction
- goal: reduce approval interruptions while keeping safe day-to-day automation
- non-goal: immediately normalizing unrestricted mode
- constraint: Windows should be treated cautiously; WSL-first operation is safer

## 3. Default Position

Adopt Codex approval modes.

However, the default day-to-day mode should be:

- `--full-auto`

not:

- `-a never` as the everyday baseline

The reason is simple:

- `--full-auto` is a safer default for routine development
- stronger modes should be unlocked only for clearly scoped tasks
- unrestricted mode should stay out of normal local usage

## 4. Recommended Operating Tiers

### Tier 1: Everyday Development

Default:

```bash
codex --full-auto
```

Use for:

- local edits
- routine implementation
- local test and fix loops
- normal repository work

### Tier 2: Scoped Automation With Fewer Approvals

Use only for known tasks that truly need it:

```bash
codex -a never -s workspace-write \
  -c 'sandbox_workspace_write.network_access=true'
```

Use for:

- dependency updates
- approved network tasks
- migration runs
- selected API-integrated work

Do not make this the universal default.

### Tier 3: Unrestricted Mode

Dangerous mode:

```bash
codex --dangerously-bypass-approvals-and-sandbox
```

This should be treated as:

- CI-only
- container-only
- isolation-only

Do not normalize it for a local daily workstation.

## 5. Practical Sequence

Use this rollout order:

1. standardize `--full-auto`
2. selectively unlock `-a never` with `workspace-write` and network only where justified
3. keep unrestricted mode isolated to CI or strongly sandboxed environments

This gives lower friction without collapsing the safety model.

## 6. Session-Level vs Persistent Configuration

There are two different actions:

- change the current session
- change the default configuration for future sessions

### Current Session

Use:

- `/permissions`

This is the right tool for live session adjustment.

### Future Sessions

Use configuration files such as:

- `~/.codex/config.toml`
- `.codex/config.toml`

Configuration changes affect future runs more reliably than trying to reinterpret already-applied launch flags.

For this repository, a project-scoped `.codex/config.toml` should carry the safe everyday default.

Named profiles for stronger modes should live in `~/.codex/config.toml`.

## 7. Suggested Persistent Default

For safer daily use, prefer a conservative profile first.

Safer baseline example:

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = false
```

More aggressive but still structured example:

```toml
approval_policy = "never"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = true
```

The second profile should be applied only after the team is confident in the workflow.

For this project, the repo-local default should match the safer daily baseline:

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = false
```

Optional stronger user profiles should be kept outside the repo so they remain an explicit operator choice.

## 8. Operating Rules

The minimum rules are:

- always work in a Git-managed repository
- prefer a dedicated branch over direct work on `main`
- use `--full-auto` as the default
- unlock `-a never` only for clearly scoped cases
- keep unrestricted mode off local daily use

## 9. Windows Rule

Windows should be treated cautiously for this workflow.

Preferred approach:

- use WSL for primary Codex CLI operation when possible

This reduces friction and makes the runtime behavior more predictable.

## 10. Relationship to This Project

For this project specifically:

- the relay bot and background runtime should be developed under normal safe defaults
- stronger approval modes should be introduced only when the workflow truly needs them
- operational convenience must not outrun governance

## 11. References

The policy in this document is based on the approval-mode guidance and links provided by the sponsor during project setup.
