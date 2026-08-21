# Crank run — <date>

Autonomous crank loop. Max **<N> issue cycles**, then stop.
Git policy: push branches + open PRs per finished issue; never the base branch, never merge.
Config: <path to .crank.md>

## Status: <CYCLE N — ISSUE-KEY <title> (<current step>)>

<!-- Newest cycle at the top. Update on EVERY step transition — this file is the compaction anchor. -->

## Cycle N — ISSUE-KEY <title> — picked <time>
- [ ] Picked: <rationale incl. dependency position> → branch <name> off <base>; dev server <stopped (task id) | not running>
- [ ] Recon + issue enriched; review challenge: <X concerns, summary>; <recommendations taken / deviations with reasons>; decision comments posted
- [ ] Extra spec checks: <check → outcome, one per line>
- [ ] Plan Rev <N>: <url>
- [ ] Implemented → self-review findings: <list> → fixes applied
- [ ] Gates: <gate 1 result>, <gate 2 result: X/Y, baseline prev>
- [ ] Live verify: <evidence — ids, strings, screenshot paths | skipped because X>
- [ ] DoD check: <X/X criteria met w/ evidence; cuts → decision comments> (comment posted)
- [ ] Step 9 review: <verdict; accepted N / dismissed M> → fixups applied, re-gated
- [ ] <K> commits, pushed, PR #<n> <url> (base <…>), ISSUE-KEY → In Review
- [ ] Handoff comment posted
- [ ] Env restored: dev server on <branch> (task <id>); data reset needed? <y/n>

Key design (compaction anchor): <dense paragraph — entities/columns, methods + semantics, locks/tx strategy, constants, test case list, anything a fresh context needs to not re-derive>

## Decisions log
- <cross-cycle decisions: cycle cap, stacking policy, anything user-approved>

## Config gaps found this run
- <project facts you had to work out → write them into .crank.md before closing>

## Notes / gotchas for future-me (survives compaction)
- <env state, task ids, recurring traps discovered this run>

# WRAP-UP SUMMARY  <!-- written once, at loop end -->

**<X> issues shipped, <Y> PRs open:**

| PR | Issue | Branch | Base | Gates |
|---|---|---|---|---|

**Merge order:** <…>

**Highlights:** <…>

**Notable finds along the way:** <…>

**Loose ends for you:** <auto-resolved decisions to review first, anything parked>
