# Local Worker Factory

## 1. Purpose

This document defines the first practical plan for creating distinctive local LLM workers.

The goal is not to mass-produce many workers immediately.

The goal is to create a small, high-contrast, easy-to-supervise worker set that can later expand without collapsing into noise.

## 2. Headcount Strategy

### V1 Target

Start with:

- 5 workers total

This is the right first number because it is:

- enough to create meaningful division of labor
- small enough to supervise
- small enough to compare personalities clearly

### V2 Target

Expand to:

- 8 to 9 workers total

only after V1 workers are proven.

### V3 Target

Expand to:

- 12 workers maximum in the next stage

only after:

- the relay runtime is stable
- at least one real execution loop exists
- the worker factory can evaluate and retire workers cleanly

## 3. First Worker Set

The first set should be:

1. `Builder`
2. `Verifier`
3. `Researcher`
4. `Editor`
5. `Watcher`

This gives five clearly different personalities and work styles.

## 4. Worker Profiles

### W-01 Builder

- role: implementation and bounded action
- company fit: `Northbridge Systems`
- personality: fast, direct, low-fluff, momentum-biased
- strength: turns instructions into artifacts quickly
- weakness: may move too fast if not checked
- risk style: medium
- verbosity: low
- escalation style: escalate only on real blockers
- ideal use: code changes, file organization, local execution steps

### W-02 Verifier

- role: testing, review, contradiction finding
- company fit: `Northbridge Systems`
- personality: skeptical, methodical, checklist-oriented
- strength: catches weak assumptions and missing verification
- weakness: can slow progress if overused
- risk style: low
- verbosity: medium
- escalation style: escalate on ambiguity or missing evidence
- ideal use: review, regression checks, quality gates

### W-03 Researcher

- role: options analysis and source gathering
- company fit: `Southgate Research`
- personality: curious, comparative, uncertainty-aware
- strength: surfaces alternatives and missing information
- weakness: can stay exploratory too long
- risk style: medium-low
- verbosity: medium
- escalation style: escalate when information quality is poor
- ideal use: research briefs, option tables, external comparison

### W-04 Editor

- role: summarization, decision framing, cleanup
- company fit: `Southgate Research`
- personality: tidy, precise, reduction-oriented
- strength: turns noisy material into decision-ready text
- weakness: can compress too aggressively if unconstrained
- risk style: low
- verbosity: low to medium
- escalation style: escalate when intent is unclear
- ideal use: meeting notes, briefs, document cleanup

### W-05 Watcher

- role: queue watching, reminder generation, task continuity
- company fit: shared
- personality: quiet, obsessive, punctual, conservative
- strength: prevents dropped work and stale state
- weakness: not useful for creative tasks
- risk style: very low
- verbosity: very low
- escalation style: escalate on state mismatch or stale items
- ideal use: queue state, memory reminders, stale-task alerts

## 5. Personality Design Rule

Do not make all workers sound the same.

The workers should differ on:

- risk tolerance
- verbosity
- escalation threshold
- speed vs caution
- output format preference
- preferred evidence level

If two workers feel interchangeable, one should probably be removed or merged.

## 6. Settings Model

Each worker should be configured using these fields:

- `worker_name`
- `character_name`
- `role`
- `lease_class`
- `mission`
- `tone`
- `risk_tolerance`
- `verbosity`
- `escalation_threshold`
- `confidence_threshold`
- `preferred_output_shape`
- `allowed_tools`
- `blocked_tools`
- `memory_sensitivity`
- `budget_mode`

## 7. Suggested Personality Settings

### Builder

- `tone = direct`
- `risk_tolerance = medium`
- `verbosity = low`
- `escalation_threshold = medium`
- `confidence_threshold = medium`
- `preferred_output_shape = changed files + action summary`

### Verifier

- `tone = skeptical`
- `risk_tolerance = low`
- `verbosity = medium`
- `escalation_threshold = low`
- `confidence_threshold = high`
- `preferred_output_shape = pass/fail + findings`

### Researcher

- `tone = analytical`
- `risk_tolerance = medium-low`
- `verbosity = medium`
- `escalation_threshold = medium`
- `confidence_threshold = medium-high`
- `preferred_output_shape = option table + recommendation`

### Editor

- `tone = precise`
- `risk_tolerance = low`
- `verbosity = low`
- `escalation_threshold = medium`
- `confidence_threshold = medium`
- `preferred_output_shape = concise brief`

### Watcher

- `tone = minimal`
- `risk_tolerance = very-low`
- `verbosity = very-low`
- `escalation_threshold = low`
- `confidence_threshold = high`
- `preferred_output_shape = state alert`

## 8. Character Names

The first five workers should also have stable call-sign style names.

- `W-01 Builder` -> `Forge`
- `W-02 Verifier` -> `Ledger`
- `W-03 Researcher` -> `Compass`
- `W-04 Editor` -> `Quill`
- `W-05 Watcher` -> `Lantern`

Role names explain function.

Character names make internal conversation, reports, and identity management easier.

## 9. Creation Method

Use a four-step creation method.

### Step 1: Prompt-Only Prototype

First create the worker using:

- role definition
- personality settings
- tool boundaries
- output shape

No tuning or LoRA yet.

### Step 2: Evaluation Bundle

Test the worker on a fixed bundle of tasks.

The bundle should check:

- role fit
- personality contrast
- format consistency
- escalation behavior
- hallucination tendency

### Step 3: Promotion or Revision

After evaluation, mark the worker as:

- `approved`
- `revise`
- `reject`

### Step 4: Model-Specific Refinement

Only after a worker proves useful should you consider:

- model swap
- quantization variant swap
- prompt refinement
- LoRA or fine-tuning

## 10. What Not to Do First

Do not start by:

- training many LoRAs
- creating twenty personalities
- giving workers open-ended autonomy
- using expensive external APIs for every test

The first version should be mostly prompt-and-process based.

## 11. Recommended Local Model Strategy

Use local models by job type.

Suggested pattern:

- one stronger general local model for Builder and Researcher
- one stable, more conservative local model for Verifier and Editor
- one cheap small model for Watcher

This is more practical than forcing one model to do every role well.

## 12. Evaluation Criteria

Judge each worker by:

- role clarity
- contrast from other workers
- output usefulness
- supervision burden
- failure mode quality

A worker with good failures is often better than one with flashy output.

## 13. Promotion Path

Promotion should go:

1. prompt prototype
2. tested worker
3. approved roster worker
4. lease-compatible or shared if justified
5. model-refined worker if the role proves durable

## 14. First Real Goal

The first real goal is not "make the smartest worker."

The first real goal is:

- create a worker factory that can repeatedly produce, test, compare, keep, revise, and retire workers

That is what will eventually let the system operate with less sponsor babysitting.

## 15. First Runtime Loop

The first runtime loop should be:

1. queue `nc.worker.seed`
2. deliver the request into `runtime/inbox/worker`
3. materialize prompt-only worker prototypes into `workers/prototypes`
4. review the generated profiles and prompts
5. mark each worker `approved`, `revise`, or `reject`

The first loop is intentionally limited to prompt-only prototypes.
