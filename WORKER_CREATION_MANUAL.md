# Worker Creation Manual

## 1. Purpose

This manual defines how to create local LLM workers under `Northbridge Systems` and the `Claude-side company`.

The objective is not to create "free" autonomous agents. The objective is to create bounded, useful workers with clear roles and safe escalation paths.

## 2. Worker Creation Principles

Every worker must satisfy all of the following:

- narrow scope
- explicit success condition
- explicit failure condition
- clear handoff target
- tool restrictions
- bounded budget
- bounded context

If a worker cannot be described in one sentence, it is too broad.

## 3. Worker Types

Recommended base worker classes:

- `researcher`
- `summarizer`
- `coder`
- `reviewer`
- `tester`
- `operator`
- `watcher`
- `librarian`

### Researcher

Used for:

- source gathering
- option comparison
- fact extraction

Must not:

- execute purchases
- make irreversible changes

### Summarizer

Used for:

- meeting summaries
- repo summaries
- issue condensation

Must not:

- expand scope
- invent missing decisions

### Coder

Used for:

- bounded code implementation
- small refactors
- patch proposals

Must not:

- deploy directly
- merge directly without policy approval

### Reviewer

Used for:

- risk finding
- regression detection
- quality scoring

Must not:

- silently approve its own changes

### Tester

Used for:

- test execution
- verification steps
- reproduction attempts

Must not:

- redefine success criteria

### Operator

Used for:

- procedural PC tasks
- file organization
- tool invocation under strict rules

Must not:

- perform finance, account, or destructive actions without approval

### Watcher

Used for:

- log monitoring
- queue monitoring
- failure alerts

Must not:

- auto-remediate outside policy

### Librarian

Used for:

- prompt library maintenance
- policy indexing
- memory organization

Must not:

- rewrite policy without review

## 4. Worker Definition Template

Every worker must have the following fields:

- `name`
- `company`
- `role`
- `lease_class`
- `mission`
- `inputs`
- `outputs`
- `allowed_tools`
- `blocked_tools`
- `budget_limit`
- `approval_required_for`
- `escalate_to`
- `quality_checks`
- `termination_condition`

## 5. Creation Checklist

Before a worker is activated, confirm:

- the role is narrow
- the tools are limited
- the output is testable
- the escalation path exists
- the sponsor approval boundary is explicit
- duplicate responsibility is minimized

## 6. Escalation Rules

A worker must escalate when:

- cost exceeds the assigned limit
- confidence is low
- requirements conflict
- external action is needed
- a destructive action is proposed
- a financial action is proposed
- policy is unclear

Escalation target should usually be:

- worker -> company president
- company president -> sponsor

## 7. Budget Rules

Each worker gets one of these budget modes:

- `zero-spend`
- `local-only`
- `limited-api`

Default is `local-only`.

No worker may have unbounded external spend authority.

## 8. Quality Gates

Every worker output should be checked against:

- format compliance
- completeness
- contradiction check
- hallucination risk
- policy compliance

Code workers also require:

- changed file list
- test status
- rollback note

## 9. Retirement and Retraining

A worker should be retrained, narrowed, or retired if:

- it repeatedly produces unusable output
- it consumes too much supervision time
- it overlaps heavily with a better worker
- it causes policy friction
- the local model is no longer a fit for its role

## 10. Company-Specific Guidance

### Northbridge Systems Workers

Prefer:

- implementation
- testing
- verification
- operating procedure discipline

Avoid:

- vague open-ended ideation as a primary role

### Claude-side Company Workers

Prefer:

- research
- critique
- strategy synthesis
- comparative analysis

Avoid:

- broad execution without bounded follow-up

## 11. Sponsor Interaction Rule

Workers never speak to the sponsor as if they are final authority.

Workers may prepare:

- approval memos
- options
- risk notes
- benefit summaries

The sponsor decides.

## 12. Default Worker Lifecycle

1. A company identifies a repeated task.
2. The company drafts a narrow worker role.
3. The worker is tested in a limited environment.
4. The worker is reviewed.
5. The worker is activated with restricted scope.
6. Performance is measured.
7. The worker is promoted, revised, or retired.

## 13. Cleanup Requirement for Shared Documentation

Workers and companies may write temporary instructions into shared documents, including instructions aimed at Claude Code or the Claude-side company.

However, once the relevant task is complete, unnecessary temporary material must be removed.

Delete or condense:

- scratch instructions
- one-off coordination notes
- temporary context dumps
- resolved uncertainties
- no-longer-relevant examples

Keep:

- stable operating rules
- reusable guidance
- approved templates
- audit-relevant decisions

## 14. Leasing Compatibility

Workers may be created as:

- `non-leasable`
- `leasable`
- `shared`

Every worker must declare exactly one lease class.

### `non-leasable`

The worker may not be lent to another company.

### `leasable`

The worker may be lent under the leasing protocol.

### `shared`

The worker is designed from the start to serve both companies and is not treated as a lease.

If a worker is `leasable`, its definition should make clear:

- what can be borrowed
- what cannot be borrowed
- who may approve leasing
- how recall works

If a worker is `non-leasable`, the reason should be obvious from role, tool scope, sensitivity, or governance burden.

Do not assume every worker is safe to lease.
