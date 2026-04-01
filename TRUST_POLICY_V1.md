# Trust Policy V1

## 1. Purpose

This document defines the trust-policy model for the relay runtime.

The runtime should not decide trust from repo files alone.

Trust also should not depend on repo-local launch scripts alone.

## 2. External Location

Recommended trust-policy path:

- `%USERPROFILE%\\.northbridge\\trust-policy.v1.json`

An optional override may be supplied through:

- `NORTHBRIDGE_TRUST_POLICY_PATH`

This trust policy is intended to pair with an external runtime manifest and guarded control script.

## 3. Core Fields

The trust policy should define:

- `version`
- `require_signature`
- `allowed_senders`
- `blocked_senders`
- `allowed_receivers`
- `command_rules`
- `hmac_secret`

## 4. Example

```json
{
  "version": "v1",
  "require_signature": true,
  "allowed_senders": [
    "Northbridge Systems"
  ],
  "blocked_senders": [],
  "allowed_receivers": [
    "Northbridge Systems",
    "Southgate Research",
    "codex",
    "claude"
  ],
  "command_rules": {
    "nc.memory": {
      "allowed_senders": [
        "Northbridge Systems"
      ]
    },
    "nc.call": {
      "allowed_senders": [
        "Northbridge Systems"
      ]
    },
    "nc.resume": {
      "allowed_senders": [
        "Northbridge Systems"
      ]
    }
  },
  "hmac_secret": "replace-this-with-a-long-random-secret"
}
```

## 5. Default Safety Rule

If trust is unclear:

- reject the command

If sender eligibility is unclear:

- reject the command

If signature policy is enabled and the signature is missing:

- reject the command

## 6. Why HMAC

HMAC is useful here because:

- it is simple
- it is fast
- it can be implemented locally
- the secret can stay outside the repo

## 7. Guarded Control Pairing

The trust policy should be used together with:

- an external control script
- an external hash manifest for critical runtime files

This prevents the repo from being both the code under execution and the sole authority deciding whether that code is trusted.

## 8. Limitation

This does not protect against a fully compromised local machine.

It does meaningfully reduce abuse by:

- malicious repository edits
- untrusted collaborators
- fake queued commands created without the trust secret
