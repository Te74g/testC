# Workers

This directory stores worker definitions and generated prompt-only prototypes.

## Main Files

- `worker-catalog.v1.json`

## Generated Output

Generated worker prototypes are written to:

- `workers/prototypes/`

Each generated worker normally includes:

- `<worker-id>.profile.json`
- `<worker-id>.prompt.md`

## Current Creation Loop

The first worker-creation loop is:

1. enqueue `nc.worker.seed`
2. relay bot delivers the request into `runtime/inbox/worker`
3. `scripts/materialize-worker-prototypes.ps1` turns the request into prompt-only worker files
4. review the generated prototypes
5. promote, revise, or reject

This loop is intentionally prompt-first and low-risk.
