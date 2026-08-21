---
name: pr-results
description: Triage the PR review pipeline results in .pr-reviews/ (vendure-monorepo). Shows a categorized one-liner overview, then walks through actionable items one by one for Housein's verdict, prints the post command after each approval, and flips statuses after posting. Use when the user asks "how does the PR queue look", wants to triage pipeline results, or says he posted a review.
---

# PR results triage

Companion to `/pr-pipeline` (which produces the drafts). This skill consumes them. It never runs Nigel, never sweeps GitHub beyond cheap freshness checks, and never posts.

## Step 1: Overview

Read every `.pr-reviews/*.md` at the vendure-monorepo root. Render the overview in this shape (compact, no wall of text):

```markdown
## PR queue — <date>

**Needs you (N)**

| PR | Tier | Author | Standing |
|---|---|---|---|
| [#num](url) short title | T1/T2/T3 | @author, <date> | one-line standing |

**Decision needed (N)** — T3 notes for Michael

- [#num](url) short title — @author, <date> — note drafted / pending

**Waiting on author (N)** — <shared context if any, e.g. "all grolmus, teammate X commented">

- #a (2d) · #b (1d) · #c (0d)

**Closed out**: N approved (#x, #y) · N skipped (#z reason)

Next: <single suggested next step>. Say which.
```

Only the "Needs you" section gets a table; everything else is one-liners; counts in group headers; append teammate review activity (approvals, requested changes, notable comments) to the relevant line. Group order:

1. **review-ready** — draft waiting for Housein's verdict
2. **decision-needed** — T3s with a decision note (for Housein/Michael)
3. **stale** — posted review outdated by a push, re-review pending
4. **waiting-on-author** — posted, include days since posting
5. **done / skip** — one compact line for the whole group, counts only

Before showing review-ready items, spot-check freshness: compare each one's `analyzed SHA` against the live head (`gh pr list --repo vendurehq/vendure --state open --json number,headRefOid --limit 100`). If moved, relabel it stale in the overview instead of offering an outdated draft.

## Step 2: Walk-through

Go through **review-ready** items one at a time (highest score / oldest first). Per item, explain first: who opened it and when, existing review activity (other reviewers' verdicts, unresolved threads), the ELI5, the carries as one-liners, and the suggested action. Then the draft: if it's short (roughly 10 lines or fewer), include it verbatim; if longer, don't dump it — say "the draft is N lines, want to see it?" and show it only when asked. Same rule for any long Nigel detail or decision note: explanation first, full text on request.

Every item ends with an explicit recommendation as its last line, bolded:

`**Suggested: <one concrete action>**` — e.g. "post the request-changes draft as-is", "re-run browser verification on the new head, then post", "wait for e2e (mysql) to finish before posting". Pick one, don't list alternatives; Housein will push back if he disagrees. For T2s, also surface the verification evidence from `.pr-reviews/evidence/<number>/`: summarize `evidence.md` and end that message with the screenshot paths as bare absolute paths, one per line, so they render as clickable images. If a T2 has no evidence folder, say so explicitly and offer to run the verification now (same procedure as /pr-pipeline step 5b).

Then ask for the verdict conversationally, in plain chat. Never use AskUserQuestion in this skill; Housein wants to discuss and understand, not pick from a menu. Answer questions, dig into the diff or evidence on request, and only act when he states a verdict (post as drafted, post with edits, skip).

- **post as drafted**: write the draft to a scratchpad .md file and print the exact `gh pr review <n> --repo vendurehq/vendure --approve|--request-changes --body-file <path>` command. Housein runs it himself (the tool call is permission-denied by design). After he confirms it ran: update the PR's file — set `posted SHA` to the current head SHA, status to `waiting-on-author` (request-changes) or `done` (approve).
- **edit**: apply his edits, show once, then proceed as above.
- **skip**: leave the file untouched, move on.
- **discuss**: answer, then re-ask.

After review-ready items, offer the **decision-needed** ones the same way; the action there is sending the note to Michael (or Housein deciding himself under a standing policy), then status flips to `waiting-on-author` or `skip` per outcome.

## Rules

- Only ever change status lines and `posted SHA` in `.pr-reviews/` files (write discipline shared with /pr-pipeline).
- Never invent or modify review content beyond Housein's explicit edits; substantive re-analysis belongs to /pr-pipeline.
- Posted comments follow the global CLAUDE.md "PR review comments" rules; keep edits within them (no em dashes).
- If `.pr-reviews/` is missing or empty, say so and point to /pr-pipeline instead of improvising.
