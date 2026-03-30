# Codex Project Config

This directory contains the project-scoped Codex configuration for this repository.

## Default Behavior

The project default is the same shape as `--full-auto`:

- `approval_policy = "on-request"`
- `sandbox_mode = "workspace-write"`
- `sandbox_workspace_write.network_access = false`

This keeps normal local work low-friction without making networked unattended execution the default.

## Important Note

Codex only loads project-scoped `.codex/config.toml` for trusted projects.

If this repository is marked untrusted, Codex ignores this file and falls back to user-level settings.

Use `/debug-config` inside Codex to confirm which layer is active.

## Stronger Modes

For stronger or more specialized modes, see:

- `CODEX_APPROVAL_MODES_POLICY.md`
- `.codex/config.user-profiles.example.toml`
