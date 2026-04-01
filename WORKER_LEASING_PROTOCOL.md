# Worker Leasing Protocol

## 1. Purpose

This document defines how one company may temporarily borrow or lease a worker owned by the other company.

The goal is to share useful capability without collapsing company boundaries.

## 2. Core Principle

Worker leasing is allowed.

However:

- ownership does not transfer
- approval boundaries do not weaken
- tool boundaries do not expand
- sponsor authority does not change

The borrowing company gains temporary use, not permanent control.

Only workers marked `leasable` may be leased.

Workers marked `non-leasable` may not be leased.

Workers marked `shared` are handled as shared infrastructure, not leased personnel.

## 3. Terms

### Owning Company

The company that created or normally manages the worker.

### Borrowing Company

The company requesting temporary use of the worker.

### Leased Worker

A worker temporarily assigned to perform a bounded task for the borrowing company.

## 4. Allowed Leasing Modes

### Temporary Lease

Use for one defined task or short set of related tasks.

### Shared Pool

Use for workers intentionally designed to serve both companies.

### Emergency Assist

Use when one company is blocked and needs fast help from a known worker.

## 4A. Lease Eligibility

Before a lease is requested, confirm:

- the worker is explicitly marked `leasable`
- the worker is not marked `non-leasable`
- the worker is not a `shared` worker being misclassified as a lease

If the classification is unclear, the worker must be treated as `non-leasable` until clarified.

## 5. Leasing Rules

When a worker is leased:

- the owning company remains the authority for role, tool scope, and retirement
- the borrowing company may assign only in-scope tasks
- the worker must know which company currently owns the task
- the worker must log the borrowing context clearly

The borrowing company may not silently redefine the worker.

## 6. What Requires Sponsor Approval

Sponsor approval is required if the lease would:

- increase paid usage
- widen tool permissions
- touch sensitive data outside prior approval
- materially change risk
- create hardware or service cost

If none of the above apply, a lease may be approved at the company-president level.

## 7. Lease Request Format

Each lease request should include:

- requesting company
- owning company
- worker name
- reason for lease
- task scope
- expected duration
- priority
- estimated cost impact
- whether sponsor approval is required

## 8. Worker Conduct During Lease

The leased worker must report:

- current task owner
- task scope
- any conflict between owner rules and borrower requests
- whether escalation is needed

If the borrower asks for something out of scope, the worker must refuse and escalate.

## 9. Priority and Recall

The owning company may recall the worker if:

- the owner has a higher-priority internal need
- the borrowing company is using the worker out of scope
- the lease is creating governance problems
- the lease has expired

Recall must be logged.

## 10. Shared Memory and Logging

Leased work must be traceable.

Each lease should leave:

- a lease request record
- a lease approval record
- task logs
- a completion or recall record

The worker should not carry unnecessary stale context back after the lease ends.

## 11. Suggested First Use

The safest first lease is:

- `Northbridge Systems` lends a bounded implementation or verification worker
- the Southgate Research borrows that worker for a narrow task
- results are reviewed by both presidents

This keeps the first lease auditable and low-risk.

## 12. Relationship to Shared Workers

Leased workers are not the same as shared workers.

Shared workers are designed from the start to serve both companies.

Leased workers remain owned by one company and are only temporarily assigned.
