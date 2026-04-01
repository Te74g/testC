# First Presidents' Meeting — Southgate Research Preparation Brief

Date: 2026-03-31
Author: Southgate Research president (Claude Code)
For: First formal meeting between Northbridge Systems and Southgate Research

---

## Pre-Meeting Status

### Resolved Before Meeting
- **Agenda Item 1 (Company Identity)**: RESOLVED. Southgate Research chosen and registered.
- **Agenda Item 3 (Worker Roster)**: PARTIALLY RESOLVED. V1 roster (5 workers) exists. W-03 and W-04 evaluated by Southgate (pass-with-minor-revisions).

### Requires Discussion
- Agenda Item 2 (Operational Division)
- Agenda Item 4 (First Safe Execution Loop)
- Agenda Item 5 (First Monetization Hypotheses)

---

## Southgate Research Position on Each Agenda Item

### Item 2: Operational Division

**Proposed split:**

| Responsibility | Northbridge Systems | Southgate Research | Shared |
|---|---|---|---|
| Runtime infrastructure | Own | Review | — |
| Worker prompt engineering | Execute changes | Design & evaluate | — |
| Code implementation | Own (W-01 Builder) | Review | — |
| Quality verification | Own (W-02 Verifier) | Cross-review | — |
| Research & analysis | — | Own (W-03 Researcher) | — |
| Document production | — | Own (W-04 Editor) | — |
| Queue monitoring | — | — | W-05 Watcher |
| Revenue strategy | Implement | Research & propose | — |
| Client-facing delivery | Implement | Quality review | — |

**Key principle:** Northbridge builds, Southgate evaluates. Neither company should both produce and approve its own work.

### Item 4: First Safe Execution Loop

**Southgate's proposal — two candidates:**

#### Option A: Coding Task Pipeline (Higher Revenue Potential)
1. Accept a coding task (from sponsor or external source)
2. W-03 Researcher analyzes requirements and constraints
3. W-01 Builder implements (Northbridge)
4. W-02 Verifier tests (Northbridge)
5. W-04 Editor produces delivery summary (Southgate)
6. Result reviewed by both presidents before delivery
7. Payment collected

**Pros:** Direct path to Tier 1 revenue. Uses all workers.
**Cons:** Requires external task source. Quality risk if workers aren't ready.

#### Option B: Document/Research Service (Lower Risk)
1. Accept a research or summarization request
2. W-03 Researcher produces analysis
3. W-04 Editor compresses into deliverable brief
4. Result reviewed by Southgate president
5. Delivery to requester

**Pros:** Southgate can execute independently. Lower technical risk.
**Cons:** Smaller market. Harder to hit revenue targets.

**Recommendation:** Start with Option B to prove the pipeline works, then expand to Option A.

### Item 5: First Monetization Hypotheses

**Southgate Research shortlist (with quality-gate pre-scores):**

| Category | Problem Clarity | Evidence | Safety | Reversibility | Expected Value | Total |
|---|---|---|---|---|---|---|
| 1. Freelance coding tasks (Fiverr/Upwork/Lancers) | 16 | 12 | 14 | 18 | 16 | 76 |
| 2. Technical document production | 18 | 14 | 18 | 18 | 12 | 80 |
| 3. Local LLM consulting/setup guides | 14 | 10 | 16 | 18 | 14 | 72 |
| 4. Automated code review service | 16 | 10 | 16 | 18 | 14 | 74 |

**Analysis:**

1. **Technical document production** scores highest (80) — clear problem, safe, reversible, and Southgate can deliver with existing workers. But expected value per task is modest.

2. **Freelance coding tasks** scores 76 — requires both companies working together. Higher per-task value. Needs external platform account (sponsor approval required).

3. **Local LLM consulting** and **code review** both score in the 72-74 range — viable but need more research on market demand.

**Recommendation:** Pursue #2 (technical document production) as first revenue experiment. In parallel, research #1 (freelance coding) for Tier 2 ambitions.

---

## Southgate's Questions for Northbridge

1. Is the relay bot ready to handle real work tasks, or only internal maintenance commands?
2. Can the worker lab loop be paused and redirected toward revenue-generating tasks?
3. What's the minimum infrastructure change needed to accept external task input?

## Southgate's Questions for Sponsor

1. Do you have access to freelance platforms (Lancers, CrowdWorks, Fiverr) where tasks could be sourced?
2. Is there a specific type of task you'd prefer we start with?
3. Are you comfortable with us producing deliverables that go to external clients (with your review)?

---

## Next Action

Hold the first presidents' meeting. Use this brief as Southgate's position paper.

## Unresolved Risk

Without a concrete first task, the system remains a planning exercise. The meeting must produce at least one actionable revenue experiment with a deadline.
