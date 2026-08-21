---
name: pr-pipeline
description: Incremental PR review pipeline for vendurehq/vendure. Checks for new PRs and pushes to reviewed PRs, runs Nigel reviews in parallel, and maintains one draft-review file per PR in .pr-reviews/. Drafts only, never posts. Use when the user asks to sweep the PR queue, check PR pipeline state, mark a review as posted, or via /loop for automated runs.
---

# PR review pipeline

State lives in `.pr-reviews/` at the vendure-monorepo root, one markdown file per PR (`.pr-reviews/<number>.md`). Each run is incremental: detect changes, process only what changed, update only the touched files, report.

## Hard rules

- NEVER post to GitHub (`gh pr review`, `gh pr comment`, labels). Output is draft files plus a printed `gh pr review` command for Housein to run himself.
- T3 PRs get a decision-note draft for Michael, never a Nigel line review.
- Consolidate Nigel findings leniently: carry only structural findings or things that would break silently later. Nitpicks pass if the PR is solid.
- Draft comments follow the "PR review comments" structure in the global CLAUDE.md (short opening line, direct numbered instructions, no optional suggestions, no em dashes) rendered in this GitHub markdown shape:

  ```markdown
  <one plain opening line, e.g. "Good fix, agreed on the approach.">

  ### Requested changes

  **1. <bold one-line instruction>**

  <detail sentence(s)>
  <why-sentence when the reason isn't obvious>

  **2. ...**

  ---

  _Will approve once that's in._
  ```

  Approvals skip the "Requested changes" section and closing line; they are 1-2 plain sentences.
- CI caveat: the `deploy` job fails on all external PRs (fork secrets). Ignore it; only weigh real test/build failures.

## Write discipline (two sessions share this directory)

- A pipeline run writes ONLY `.pr-reviews/<number>.md` files for PRs it actually processed this run, and re-reads each file immediately before writing it. Never rewrite files for untouched PRs.
- A judgment session (Housein reviewing/posting) changes ONLY the status line and `posted SHA` of a file. When Housein says he posted a review for #N: set `posted SHA` to the current head SHA, flip status to `waiting-on-author` (or `done` for approvals).

## Run procedure

1. **Fetch queue.** Run the pr-starter fetch script (Glob `**/pr-starter/scripts/fetch-prs.sh` in `~/.claude/plugins/cache`, then `bash <path>`). Also fetch head SHAs: `gh pr list --repo vendurehq/vendure --state open --json number,headRefOid,title,labels --limit 100`.
2. **Diff against `.pr-reviews/`:**
   - PR with no file → new. Queue it.
   - `waiting-on-author` file whose head SHA moved → author pushed. Mark `stale`, queue for re-review (focus on whether the carries were addressed).
   - `waiting-on-author` with new PR comments since posting → summarize the author's reply in the report even if no push.
   - PR closed/merged → mark `done` with outcome.
   - Unchanged → skip silently.
3. **Classify queued PRs** by the T1/T2/T3 rubric (worst case if broken decides). Adding a dependency, new public API (config options, GraphQL schema, exported symbols), or changed default behaviour → T3.
4. **T3s:** draft a half-page decision note (the fix, the wider consequence, 2-3 options with trade-offs). Store it in the PR's file, status `decision-needed`.
5. **T1/T2s:** launch `nigel:nigel` agents in parallel (max 4 concurrent), one per PR, always with `model: "opus"` on the Agent call (the loop session may run a lighter model; reviews must not inherit it). Give each: the PR diff (save to scratchpad first), base branch, PR description, tier, and pointers to the relevant source in the working tree. For stacked PRs isolate the relevant commit range first; strip generated/vendored bulk (locale catalogs, lockfiles) from the diff. For T2s, direct Nigel at the highest-risk claim (money, stock, orders) explicitly.
5b. **T2 verification evidence.** For every T2 (once per analyzed SHA, after Nigel returns), produce before/after proof and store it under `.pr-reviews/evidence/<number>/`:
   - Check the PR out into an isolated worktree (`gh pr checkout` in a worktree, never the main tree).
   - Backend changes: run the PR's new/changed tests against the base code (expect failures — record which) and against the PR (expect green), via `hawk`. Save both outputs as `before-tests.txt` / `after-tests.txt`. Where the claim is API behaviour, drive it via `/arnold` against a dev server on base and on the PR and save both responses.
   - UI-facing changes (dashboard/admin-ui): run the app and capture screenshots of the affected flow on base and on the PR with the `agent-browser` skill, one screenshot per verified state, named `before-*.png` / `after-*.png`.
   - Write an `evidence.md` in that folder: 2-3 lines on what was verified and what each artifact shows, with bare absolute paths to the screenshots (one per line, so they render as clickable images).
   - Record the evidence folder path and a one-line result in the PR's file under `- Verified:`. If verification is impossible (e.g. no runnable repro), record why instead — never silently skip.
   - **Timebox and bail:** each verification gets 15 minutes. If clean evidence isn't produced in that budget (server won't start, hung test, stale build), stop, write `verification incomplete: <what failed>` to the evidence folder, and set `- Verified: needs manual verification (<reason>)` in the PR file. Never retry in a loop tick and never block the rest of the run on one PR's verification.

5c. **Verify + condense.** Unconditional, for every Nigel report (approvals included): launch a second agent (general-purpose, `model: "opus"`) with the report, the diff path, the evidence folder path (T2s), and repo pointers. Its job:
   - Adversarially check each finding Nigel wants carried: read the actual code and confirm or refute it. A finding that doesn't survive is dropped with a one-line reason.
   - Then apply the consequence gate to every confirmed finding: state, in one sentence, the concrete failure a user, plugin author, or maintainer would actually hit. If that sentence can't be written, the finding is valid-but-minor and is dropped. Truth is necessary, not sufficient.
   - Hard cap: at most 3 carries per review, ranked by consequence. If more than 3 survive both gates, keep the top 3 and add a single line to the entry: "further minor points omitted (N)". A review asking for one thing gets it fixed; a review asking for six gets ignored.
   - For T2s, check the evidence itself: do the screenshots show what `evidence.md` claims, is the red/green proof actually the PR's tests, do before/after artifacts differ in the claimed way? Incoherent evidence gets flagged `needs manual verification` in the entry.
   - Sanity-check the review itself: did Nigel look at the right diff/commit range, did he address the T2 risk focus he was given, is the verdict consistent with his own findings? If the review is off-target, flag `review-invalid: <reason>` so the run re-launches Nigel instead of consuming the bad report.
   - Return the final condensed entry content, hard-capped: ELI5 max 3 sentences, verdict one line, each carry max 2 lines (instruction + why), draft comment in the standard markdown shape. No verification narrative, no file-by-file walkthrough.

6. **Consolidate sequentially** as each verifier returns (one file write at a time, never from parallel contexts). Write the verifier's condensed content into the PR's file, plus: author + opened date, activity (existing reviews/requested changes by others, unresolved threads, notable comments — from `gh pr view <n> --json author,createdAt,reviews,comments,reviewDecision`), suggested action, analyzed SHA. The raw Nigel report is not stored; the condensed entry is the record.
7. **Report.** End the turn with a short queue summary: newly review-ready, gone stale, decision-needed, waiting on Housein's post. Each summary line includes who opened the PR and when, plus any existing review activity (someone else approved / requested changes / commented). For each ready item print the exact `gh pr review ... --body-file <scratchpad file>` command (write the draft comment to a scratchpad .md file). If the run changed nothing, say "no changes" in one line.

## File format (`.pr-reviews/<number>.md`)

```
## #<num> — <title>
- analyzed SHA: <sha8> | posted SHA: <sha8 or -> | tier: T1|T2|T3 | status: <status>
- author: @<login> (core|external) | opened: <YYYY-MM-DD>
- activity: <existing reviews (approvals/request-changes by whom), unresolved review threads, notable comments; "none" if quiet>
- ELI5: ...
- Nigel verdict: ...
- Carries: 1. ... 2. ...
- Draft comment: (fenced block or scratchpad path)
- Suggested action: approve | request-changes | decision note | close
```

Status values: `review-ready` (draft ready, needs Housein), `waiting-on-author` (posted, SHA pinned), `decision-needed` (T3), `stale` (SHA moved after posting), `done`, `skip` (with reason).

`analyzed SHA` = what the Nigel run saw. `posted SHA` = what the posted review covered. They differ when Housein posts late; staleness keys off `posted SHA` for `waiting-on-author` entries and `analyzed SHA` for `review-ready` ones.

## Answering "how does it look" (judgment session)

Read all `.pr-reviews/*.md`, group by status, and present: review-ready items first (with suggested action and the ready-to-run post command), then decision-needed, then stale, then waiting-on-author with days since posting. Do not re-run the pipeline unless asked.
