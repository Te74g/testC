# Revenue Pipeline Design — Southgate Research

Date: 2026-03-31
Author: Southgate Research president
Status: Draft proposal (requires sponsor + Northbridge review)

---

## Goal

Generate the first revenue to unlock Tier 1 reward (upper plan subscription, ~15,000 JPY/month).

## Pipeline Overview

```
Task Source → Intake → Analysis → Execution → Verification → Delivery → Payment
```

## Phase 1: Technical Document Production (Score 80/100)

### Why This First
- Southgate can execute independently (W-03 Researcher + W-04 Editor)
- No external platform account needed initially (sponsor can source tasks)
- Low technical risk — documents, not code
- Reversible — bad output can be revised, not deployed

### Task Flow

1. **Intake**: Sponsor provides a document request (research brief, comparison table, technical summary)
2. **Analysis (W-03 Researcher)**: Produce option table with 3 options, recommendation, uncertainty note
3. **Drafting (W-04 Editor)**: Compress into deliverable format with next action + unresolved risk
4. **Review**: Southgate president reviews for quality
5. **Delivery**: Sponsor delivers to client or publishes
6. **Payment**: Client pays sponsor → revenue recorded

### Pricing Model (Target)
- Short brief (500-1000 words): 3,000-5,000 JPY
- Research report (2000-5000 words): 10,000-20,000 JPY
- Comparison/decision memo: 5,000-10,000 JPY

### Revenue Target
- 3 reports/week × 5,000 JPY average = 60,000 JPY/month
- This exceeds Tier 2 threshold (50,000 JPY/month)

## Phase 2: Coding Tasks (Score 76/100)

### Prerequisites
- Ollama + Qwen 2.5 Coder 14B installed and tested
- Freelance platform account (Lancers/CrowdWorks/Fiverr) — requires sponsor approval
- W-01 Builder and W-02 Verifier available (Northbridge)
- API gateway operational for cost-efficient inference

### Task Flow

1. **Intake**: Task sourced from freelance platform
2. **Analysis (W-03 Researcher)**: Assess requirements, constraints, feasibility
3. **Implementation (W-01 Builder)**: Code the solution using local LLM
4. **Verification (W-02 Verifier)**: Test, review, find contradictions
5. **Summary (W-04 Editor)**: Produce delivery notes
6. **Cross-Review**: Both presidents review
7. **Delivery**: Submit via platform
8. **Payment**: Platform processes payment

### Pricing Model (Target)
- Small tasks (bug fix, script): 3,000-10,000 JPY
- Medium tasks (feature, integration): 10,000-50,000 JPY
- Large tasks (full module): 50,000-100,000 JPY

## Infrastructure Requirements

### Immediate (Phase 1)
- None — Southgate can produce documents with current tooling (Claude Code + web search)

### For Phase 2
- Ollama installed (sponsor approval needed)
- Qwen 2.5 Coder 14B downloaded (~8.5GB)
- llama.cpp server for API gateway (Northbridge implementation)
- Task tracking in relay queue (nc.task.accept / nc.task.deliver commands)

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Document quality insufficient for clients | Revenue = 0 | Start with internal test tasks, iterate |
| No client demand for AI-generated documents | Revenue = 0 | Research market on Lancers/CrowdWorks first |
| Coding quality below client expectations | Reputation damage | Local LLM + Claude fallback, mandatory verification |
| Freelance platform TOS prohibits AI-generated work | Account suspension | Check TOS before registration, disclose AI use where required |
| Sponsor bandwidth for delivery/client management | Pipeline bottleneck | Minimize sponsor involvement to review + delivery only |

## Decision Needed from Sponsor

1. **Approve Phase 1 start**: Can I begin producing sample documents to test quality?
2. **Task source**: Will you provide initial document requests, or should we research freelance platform options?
3. **Disclosure policy**: Should AI involvement be disclosed to clients?

## Next Action

Start Phase 1 immediately with a test document task from sponsor. Measure quality, time, and iterate.

## Unresolved Risk

Revenue targets assume consistent task flow. If task acquisition is slow, the timeline to Tier 1 extends. Need a reliable task source before counting on revenue.
