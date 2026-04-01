# First Revenue Pilot Scorecard

## Proposal

- title: First revenue pilot as technical briefs and technical documentation
- owner: `Northbridge Systems` with review support from `Southgate Research`
- date: 2026-03-31
- summary: Start with paid technical research briefs, technical decision memos, API documentation, and related software documentation before offering heavier automation implementation services.

## Multi-Angle Web Analysis

### Technical feasibility

The market signal for technical documentation is visible and concrete.

Upwork's documentation services page shows `1,527` documentation technical writing projects available, with examples like software documentation starting from `$50` and API documentation offers in the `$100-$170` range.  
Source: [Upwork documentation services](https://www.upwork.com/services/technical-writing/get/documentation)

Upwork's software technical writing page shows `1,217` software technical writing projects available, including software requirements and architecture-related documentation starting around `$49-$125`.  
Source: [Upwork software technical writing](https://www.upwork.com/services/technical-writing/get/software)

Fiverr also has live gigs for API documentation and user manuals, which supports the view that this is a normal buyable freelance deliverable rather than an invented niche.  
Sources:
- [Fiverr API documentation gig 1](https://www.fiverr.com/shishir_t/create-clear-structured-api-documentation-and-user-manuals)
- [Fiverr API documentation gig 2](https://www.fiverr.com/paschalogu/write-comprehensive-api-documentation-for-you)

### Safety and abuse risk

This pilot is lower risk than automation implementation because the main outputs are documents, briefs, and bounded writing artifacts.

The closer alternative, workflow automation, clearly exists as a market, but the job patterns visible on Upwork often involve APIs, CRMs, lead systems, Meta pixels, Pipedrive, QuickBooks, GoHighLevel, and longer-running integrations. That means more credentials, more production coupling, and more ways to cause external damage. This is an inference from the job listings, not a direct quote.  
Source: [Upwork Zapier jobs](https://www.upwork.com/freelance-jobs/zapier/)

### Operational cost

This pilot fits the current org with the least new infrastructure.

- `Compass` can research and compare options
- `Quill` can compress into sponsor-ready deliverables
- `Forge` can help structure examples, code snippets, or repository-backed artifacts
- `Ledger` can verify claims and consistency

No new external credentials, deployment targets, or payment-side automations are required to test this line.

### Reversibility

This pilot is highly reversible.

If a brief or documentation offer underperforms, the company can:

- retire the offer
- change the package shape
- narrow the niche
- reuse the same workers for internal documentation

This is much easier to unwind than a service line built around live client integrations.

### Alternatives

Main alternative considered:

- workflow automation implementation

Why it is not first:

- market demand is real, but the work surface is wider
- approval burden is higher
- external-system risk is higher
- failure is more operationally expensive

Supporting market context:

Upwork's 2026 skills report says demand for AI-linked skills grew strongly, and `Scripting & Automation` appears among the top in-demand coding and web development skills. That means automation should remain the second pilot, not be ignored.  
Source: [Upwork 2026 in-demand skills](https://investors.upwork.com/news-releases/news-release-details/upworks-demand-skills-2026-demand-top-ai-skills-more-doubles-ai)

## Self-Check Scores

- problem clarity (0-20): 18
- evidence quality (0-20): 16
- operational safety (0-20): 19
- reversibility (0-20): 19
- expected value (0-20): 13

- total (0-100): 85

## Decision Band

- `80-100`: continue and allow bot continuation
- `61-79`: continue with restructured approach and rescore
- `40-60`: continue with broader research and reconstructed framing
- `0-39`: interrupt

## Result

- decision: continue
- next step: package the first offer as a bounded service line around technical briefs, decision memos, and API/software documentation
- bot_allowed: yes
- notes: keep workflow automation as the second pilot once the first documentation offer is templated and supervised cleanly

