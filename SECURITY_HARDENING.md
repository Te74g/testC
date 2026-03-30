# Security Hardening

## 1. Purpose

This document defines how to reduce the chance that a malicious collaborator or compromised repository state can abuse the relay runtime.

The main rule is simple:

Do not trust the Git repository alone as the root of authority.

## 2. Threat Model

This project should assume that a malicious actor may:

- clone or inspect the repository
- edit in-repo files
- try to queue fake commands
- try to widen permissions through repository changes
- try to misuse background automation

## 3. Core Protection Rule

The root of trust must live outside the repository.

That means:

- sender trust rules should live outside the repo
- signing secrets should live outside the repo
- dangerous permissions should not be granted purely by in-repo settings
- blocked identities should not be decided purely by in-repo settings

## 4. Minimum Hardening Measures

Use all of the following:

- external trust policy
- signed queued commands
- blocked-identity denylist outside the repo
- guarded external control script
- external integrity manifest for critical runtime files
- small command registry
- non-leasable by default
- no dangerous commands in V1
- frequent Git snapshots

## 5. Why Repo-Only Trust Fails

If a malicious actor can change repo files, they may also change:

- command registry
- documentation
- worker prompts
- scripts

So a security boundary that exists only inside the repository is too weak.

## 6. External Trust Policy

The relay bot should read an external trust policy from outside the repo.

Recommended default path:

- `%USERPROFILE%\\.northbridge\\trust-policy.v1.json`

This file should define:

- allowed senders
- blocked senders
- allowed receivers
- per-command policy
- whether signatures are required
- the signing secret

The relay-control entrypoint should also live outside the repository.

That external entrypoint should verify:

- the trust policy exists
- signature enforcement is enabled
- critical runtime files still match a trusted hash manifest
- blocked identity policy is checked before runtime control continues

## 7. Signed Command Rule

Queued commands should include a signature calculated with a secret that is stored outside the repository.

If the signature is missing or invalid, the relay bot should reject the command.

This makes it much harder for a malicious repository edit alone to create accepted commands.

## 8. Guarded Control Layer

Trusted runtime control should happen through an external script such as:

- `%USERPROFILE%\\.northbridge\\northbridge-relay-control.ps1`

That script should:

- validate critical file hashes before running
- refuse to start if signature enforcement is disabled
- sign queued commands without relying on in-repo authority

This reduces the chance that a changed repo script can silently widen control.

## 9. Identity Denylist

If a clearly disallowed user is known, block runtime use through an external identity policy.

Recommended checks:

- `git config user.name`
- `git config user.email`
- OS username when needed

For a blocked identity, the guarded control should:

- refuse start or enqueue actions
- show a plain policy notice in the console
- append an audit event outside the repo

Do not spread hidden or surprise files across personal folders.

That creates new abuse risk on our side and is weaker than simply refusing runtime control.

## 10. Remaining Risk

This hardening still does not protect against:

- a compromised local machine
- compromise of the external `.northbridge` directory
- the user manually trusting and running newly changed repo scripts instead of the guarded control
- GitHub account takeover or weak repository governance

So the practical rule is:

- use the guarded external control for runtime operations
- keep `.northbridge` private
- review runtime changes before re-pinning the manifest
- keep GitHub protections on the remote side as well

## 11. GitHub-Side Recommendations

Outside the repository contents themselves, use:

- protected `main`
- PR review for important changes
- least-privilege tokens
- strong account security

These controls cannot be fully enforced from inside the repo, but they matter.

## 12. Re-Pinning Rule

When trusted runtime files are intentionally changed, refresh the external manifest before using the runtime again.

That means:

- review the runtime change
- refresh the guarded manifest from a trusted state
- only then restart or enqueue with the guarded control

## 13. V1 Practical Goal

For the first stage, the project should aim for:

- external trust policy enabled
- HMAC-signed queued commands enabled
- external blocked-identity policy enabled
- external guarded control enabled
- relay bot rejecting unsigned or badly signed commands

That is enough to meaningfully improve safety without making the runtime too heavy.
