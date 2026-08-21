# HOW TO VERIFY
<!-- Use the exact title line from .crank.md (e.g. `# HOW TO DEMO`). -->

> Audience: <from config — assume they have NOT read the plan doc>
> Every step must be reproducible verbatim from the stated starting state.

**Change:** <one line — what this does>
**Serves:** <the issue / scenario step / proof-point this lands>

## Prerequisites

- Branch/state: <merged to base | branch name>
- Data: <fresh reset | specific seed state, e.g. "customer X has creditLimit 1000">
- Setup: <flags, toggles, config to flip first — or "none">

## Steps

1. <exact action: UI path with clicks, or an API call with a ready-to-run operation + variables, or a CLI command>
2. <…>

## What you'll see

- <exact expected result — real values captured during live verification, not paraphrase: ids, state names, strings, amounts>

## Talking points
<!-- Drop this section if the audience is a verifier, not a presenter. -->

- <why this matters, and to whom>

## Gotchas

- <flaky prerequisite, seeded records that behave differently, restart needed after edits — or "none">
