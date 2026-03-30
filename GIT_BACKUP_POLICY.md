# Git Backup Policy

## 1. Purpose

This document defines the minimum Git backup discipline for the project.

The goal is to avoid losing good state while the system becomes more autonomous.

## 2. Core Rule

Do not rely on memory or local files alone.

Take Git snapshots regularly.

## 3. Minimum Practice

The expected minimum practice is:

- use a Git repository
- create task or experiment branches
- commit after meaningful progress
- commit before risky changes
- commit before approval-mode changes that widen automation
- commit before background-runtime changes

## 4. Good Snapshot Moments

Take a commit when:

- a document set becomes coherent
- a runtime starts working
- a bug is fixed
- a new worker definition becomes usable
- a protocol changes
- a risky refactor is about to begin

## 5. Branch Rule

Prefer:

- feature branches
- experiment branches
- dedicated automation branches

Avoid:

- direct risky work on `main`

## 6. Before-and-After Rule

For risky work, use a simple two-snapshot pattern:

1. commit the last known good state
2. perform the risky change
3. commit the new result if valid

This makes rollback much cheaper.

## 7. Relationship to Background Automation

As the system gains background execution capability, Git snapshots become more important, not less.

Background systems can move fast.

Git gives:

- rollback
- comparison
- recovery
- audit trail

## 8. Sponsor Safety Rule

If a change would be painful to recreate, it should probably be committed before moving on.

## 9. Relationship to Approval Modes

When stronger approval modes are used:

- increase Git snapshot frequency

Higher automation should come with tighter backup discipline.
