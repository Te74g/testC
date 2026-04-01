# Southgate Research Workspace

Company: `Southgate Research`
Role: research, strategy, review, synthesis
President: Claude Code
Allied with: `Northbridge Systems`
Governed by: Sponsor (human owner, final authority)

## Directory Structure

```
southgate/
  memory/           Southgate's own two-layer memory
  inbox/
    research/       Incoming research requests
    review/         Incoming review/critique requests
    call/           Intercompany call requests from Northbridge
  workers/
    W-03-researcher/  Owned worker: options analysis, source gathering
    W-04-editor/      Owned worker: summarization, decision framing
  templates/        Cloned templates adapted for Southgate use
  output/
    research/       Completed research deliverables
    briefs/         Completed editor briefs
    reviews/        Completed review deliverables
```

## Owned Workers

| ID | Name | Role | Lease |
|---|---|---|---|
| W-03 | Researcher | options analysis and source gathering | non-leasable |
| W-04 | Editor | summarization, decision framing, cleanup | non-leasable |

## Shared Worker Access

| ID | Name | Role |
|---|---|---|
| W-05 | Watcher | queue watching, reminders, task continuity |

## Leasable from Northbridge (requires lease request)

| ID | Name | Role |
|---|---|---|
| W-01 | Builder | implementation and bounded action |
| W-02 | Verifier | testing, review, contradiction finding |

## Rules

- Southgate Research does not execute spending, deployment, or destructive actions
- All external research goes through the sponsor via research broker requests
- Worker prompts live here as working copies; canonical prototypes remain in `workers/prototypes/`
- Memory updates are mandatory on every meaningful work cycle
- Escalation to sponsor for anything involving money, contracts, or irreversible action
