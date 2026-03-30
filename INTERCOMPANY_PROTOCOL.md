# Intercompany Protocol

## 1. Purpose

This document defines how `Northbridge Systems` and the `Claude-side company` interact.

The protocol is designed to support cooperation, healthy peer review, and efficient escalation without turning meetings into uncontrolled chatter.

## 2. Allowed Interaction Types

The companies may interact through:

- `direct_call`
- `sponsor_route`
- `joint_review`
- `worker_review`
- `worker_lease_request`
- `joint_execution_request`
- `research_broker_request`

## 3. Direct Call

A `direct_call` is used when one company wants to speak to the other without sponsor mediation.

Use it for:

- quick strategic alignment
- clarification of intent
- peer review requests
- proposed worker reassignment
- concerns about quality or governance

Required fields:

- caller
- callee
- topic
- reason
- urgency
- expected output
- budget impact
- whether sponsor approval is likely after the call

## 4. Sponsor Route

A `sponsor_route` is used when:

- the matter may require spending
- the matter may require account access
- the matter may require external communication
- there is disagreement between companies
- the caller wants the sponsor to broker the meeting

The sponsor route produces a formal meeting with explicit decision needs.

## 5. Worker Review

Each company may review the other company's workers.

A worker review may recommend:

- keep as-is
- narrow scope
- retrain
- promote
- retire
- transfer ownership

Worker reviews must be evidence-based and must include:

- worker name
- role
- recent outputs reviewed
- quality findings
- governance findings
- recommendation

## 6. Joint Execution Request

Use a `joint_execution_request` when both companies are needed on one task.

Recommended split:

- `Northbridge Systems`: implementation, enforcement, verification
- `Claude-side company`: research, critique, decision framing

Every joint execution request must specify:

- task owner
- review owner
- worker roles involved
- budget assumptions
- approval boundary

## 6A. Worker Lease Request

Use a `worker_lease_request` when one company wants to temporarily borrow a worker owned by the other company.

This request should follow:

- `WORKER_LEASING_PROTOCOL.md`

At minimum it must specify:

- requesting company
- owning company
- worker name
- task scope
- expected duration
- estimated cost impact
- approval boundary

## 7. Research Broker Request

If either company needs information from GPT or another external research source through the sponsor, use a `research_broker_request`.

This request exists because the sponsor may obtain outside research that the companies cannot directly fetch.

Required fields:

- requesting company
- research question
- why it matters
- desired output format
- deadline
- whether follow-up questions are expected

## 8. Meeting Discipline

Every intercompany meeting must end with:

- a one-paragraph summary
- explicit decisions
- explicit non-decisions
- assigned actions
- open risks

If a meeting does not produce a useful outcome, the next meeting should not be scheduled until the blocker is stated clearly.

## 9. Conflict Rule

If the companies disagree:

1. each side states its position in one paragraph
2. each side lists strongest risk in the other position
3. each side proposes a compromise
4. unresolved issues go to the sponsor

The goal is resolution, not rhetorical victory.

## 10. Audit Rule

Important intercompany actions must be logged.

Log at least:

- date
- participants
- purpose
- decision
- follow-up owner
- approval status

## 11. Shared Document Directives

Either company may place operational instructions for the other in shared documents when that is the clearest way to coordinate work.

This includes direct instructions addressed to Claude Code.

Such directives must:

- identify the intended recipient
- state the purpose clearly
- avoid ambiguous authority
- respect sponsor approval boundaries

## 12. Post-Completion Cleanup

After the relevant work is done, the companies should remove stale directives and reduce temporary coordination text to the smallest durable record that still preserves accountability.

Do not keep a shared document bloated with expired task chatter.
