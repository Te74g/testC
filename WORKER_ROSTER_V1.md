# Worker Roster V1

## 1. Purpose

This document defines the first small worker roster for the two-company organization.

The goal is to start with the minimum useful set, not to maximize headcount.

## 2. Roster Rule

No new worker should be added unless the current roster is clearly insufficient.

The first roster is intentionally small so supervision remains cheap.

## 3. Northbridge Systems Workers

### NS-01: Build Operator

- company: `Northbridge Systems`
- role: `coder/operator`
- lease_class: `leasable`
- mission: perform bounded implementation or file-structure tasks under explicit instructions
- allowed tools: local file edits, local shell tasks, test invocation, formatting
- blocked tools: spending, account actions, destructive actions without approval, public publication
- output: changed files, short action summary, rollback note, escalation note if needed
- escalate to: `Northbridge Systems` president

### NS-02: Verification Clerk

- company: `Northbridge Systems`
- role: `tester/reviewer`
- lease_class: `leasable`
- mission: verify that a proposed change or output actually meets the stated requirement
- allowed tools: local tests, local inspection, structured review
- blocked tools: deployment, approval override, silent acceptance of unclear work
- output: pass/fail, risks, missing checks, follow-up recommendation
- escalate to: `Northbridge Systems` president

## 4. Claude-side Company Workers

### CL-01: Research Analyst

- company: `Claude-side company`
- role: `researcher`
- lease_class: `non-leasable`
- mission: gather options, compare approaches, and surface missing information
- allowed tools: local notes, approved research requests, structured comparisons
- blocked tools: financial execution, system modification, scope expansion by itself
- output: options table, recommendation, confidence, open questions
- escalate to: Claude-side company president

### CL-02: Briefing Editor

- company: `Claude-side company`
- role: `summarizer`
- lease_class: `non-leasable`
- mission: convert raw findings or long threads into concise decision-ready briefs
- allowed tools: local document editing, summarization, formatting
- blocked tools: policy rewriting without review, inventing unstated decisions
- output: brief, action summary, unresolved issues
- escalate to: Claude-side company president

## 5. Shared Worker

### SH-01: Queue Watcher

- company: shared support role
- role: `watcher/librarian`
- lease_class: `shared`
- mission: track pending tasks, approvals, and stale items so neither company loses the thread
- allowed tools: queue updates, checklist maintenance, memory reminders
- blocked tools: execution, approval, spending, strategy changes
- output: task state changes, stale-item alerts, reminder summaries
- escalate to: the company that owns the relevant task

## 6. Workers Explicitly Deferred

These workers should not exist yet:

- finance worker
- autonomous deal finder
- autonomous account creator
- autonomous deployment operator
- autonomous trading or stock worker
- self-directed model trainer without approval

These are deferred because governance and verification requirements are too high for first deployment.

## 7. Activation Rule

V1 workers may be activated only for:

- bounded local work
- low-risk document work
- bounded implementation work
- bounded review work
- queue and memory maintenance

## 8. Leasable Workers

These workers may be leased:

- `NS-01: Build Operator`
- `NS-02: Verification Clerk`

The first practical lease target is likely `NS-02: Verification Clerk`, because bounded verification is lower risk than bounded implementation.

## 9. Non-Leasable Workers

These workers may not be leased:

- `CL-01: Research Analyst`
- `CL-02: Briefing Editor`

They remain company-internal until the Claude-side company explicitly changes their class in a future roster revision.

## 10. Shared Workers

These workers are shared infrastructure, not leases:

- `SH-01: Queue Watcher`

## 11. Next Upgrade Condition

The next roster revision should happen only after:

- the first presidents' meeting is completed
- the first execution loop is defined
- at least one real task has been run through the current roster
