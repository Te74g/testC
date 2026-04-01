# Technical Brief Service Order Flow V1

## 1. Purpose

This document shows the example order flow for the first documentation-based revenue line.

It is the operational bridge between:

- service design
- quoting
- delivery
- revision handling

## 2. Example Use Case

Use case:

- a client wants one short technical brief on a narrow software question

Example question:

- "Should we run our unattended Windows AI workflow through Task Scheduler or a user-space launcher?"

## 3. Standard Order Flow

### Step 1: Intake

Use:

- `TECHNICAL_BRIEF_INTAKE_TEMPLATE.md`

Do:

- capture the real question
- identify intended reader
- identify scope boundaries
- check whether production access, credentials, or sensitive data are involved

Decision rule:

- if the request is still bounded and documentation-shaped, continue
- if it drifts into implementation or sensitive access, stop and escalate

### Step 2: Internal Fit Check

Do:

- choose package shape
- confirm the work belongs in this service line
- confirm no hidden implementation commitment exists

Typical first answer:

- `Package A - Fast Technical Brief`

### Step 3: Draft Quote

Use:

- `TECHNICAL_BRIEF_QUOTE_SHEET_V1.md`
- `SAMPLE_TECHNICAL_BRIEF_QUOTE_V1.md`

Do:

- write scope summary
- write deliverable description
- set turnaround
- set bounded revision language
- restate excluded items

### Step 4: Sponsor Approval Before Sending

Sponsor must approve:

- quoted package
- quoted price
- turnaround
- external wording

No external quote is sent before this approval exists.

### Step 5: Send Quote And Confirm Order

Once sponsor-approved:

- send the quote
- confirm the client question is unchanged
- confirm timeline and package

Only after that is the order treated as active.

### Step 6: Internal Worker Routing

Recommended routing:

- `Compass`: compare options and gather reasoning
- `Quill`: shape the brief into readable structure
- `Ledger`: check unsupported claims and contradictions
- `Forge`: add implementation notes only when useful and in scope
- `Lantern`: confirm handoff completeness and continuity

### Step 7: Draft Delivery

Use:

- `templates/technical_brief_delivery_template.md`

Minimum required sections:

- client question
- context
- options or evaluated structure
- recommendation
- unresolved risks
- next actions

### Step 8: Delivery Quality Gate

Use:

- `TECHNICAL_BRIEF_DELIVERY_CHECKLIST.md`

Do not deliver unless:

- the recommendation is explicit
- uncertainty is visible
- major tradeoffs are named
- out-of-scope items are not blurred
- package and deliverable still match

### Step 9: Sponsor Review Before External Delivery

For the current stage of the company, external delivery stays sponsor-gated.

Sponsor should confirm:

- output is safe to send
- package still matches the work done
- no accidental implementation promise was added

### Step 10: Delivery

Deliver:

- final brief artifact
- short handoff note
- revision boundary reminder

Record:

- final artifact path
- package used
- delivery date
- sponsor review status

### Step 11: Feedback Handling

Use:

- `TECHNICAL_BRIEF_REVISION_POLICY_V1.md`

Classify feedback as:

- `Class A`: wording / structure
- `Class B`: reasoning challenge still in scope
- `Class C`: scope drift / new work

### Step 12: Closeout

Record:

- what package was actually delivered
- whether revision was used
- what should change in the next quote or intake

## 4. First-Pilot Operating Posture

For the first real paid order:

- keep the question narrow
- prefer `Package A`
- avoid client data sensitivity
- avoid implementation commitments
- keep turnaround short
- use one bounded revision only

## 5. Failure Signals

Stop and review if:

- the client starts asking for implementation through the revision loop
- the question changes after quoting
- the deliverable stops looking like a brief and starts looking like consulting
- the request needs credentials, admin access, or production systems

## 6. Recommended Next Asset

After this order flow, the next helpful sponsor-facing asset is likely:

- a first sponsor decision sheet

or

- a mock completed order packet

The first sponsor decision sheet now exists at:

- `TECHNICAL_BRIEF_FIRST_SPONSOR_DECISION_SHEET_V1.md`

The first mock completed order packet now exists at:

- `TECHNICAL_BRIEF_MOCK_COMPLETED_ORDER_PACKET_V1.md`
