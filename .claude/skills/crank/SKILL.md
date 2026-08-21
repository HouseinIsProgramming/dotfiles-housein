---
name: crank
description: Work a tracked issue end-to-end — pick from the backlog, spec it, implement, self-review, run the project's gates, mandatory independent code review + fixup, then ship a PR and a handoff comment. Config-driven per project (.crank.md); interactive and autonomous loop modes.
when_to_use: Use when the user wants to work a tracked issue (Linear or GitHub) through the full pipeline — "crank the next issue", "work ABC-123", "run the overnight loop", "/crank". Not for ad-hoc fixes with no tracked issue.
argument-hint: "[ISSUE-KEY | auto [--cycles N]] [--config path]"
user-invocable: true
---

# Crank — the issue pipeline

One issue, one cycle, always the same shape:

```
load config → pick → recon → spec → branch → implement
  → self-review (loop until clean) → gates → live verify → DoD check
  → mandatory independent review + fixup (re-gate) → ship (PR) → handoff comment → env restore
```

You run this entire pipeline yourself — recon, spec, implementation, self-review, gates, ship. The **only** subagents you spawn are the reviewer (spec challenge in Step 2, mandatory post-implementation review in Step 9) and anything the project config names explicitly.

The pipeline shape is fixed. Everything project-specific — tracker, gates, conventions, extra steps — comes from config.

## Step -1 — Load the project config

Read the first of these that exists, relative to the repo root:

1. the path given by `--config`
2. `.crank.md`
3. `.claude/crank.md`

**No config found?** Bootstrap one before doing anything else:

1. Detect what you can: tracker (`.linear/` or `linear` CLI config → Linear; otherwise `gh repo view` → GitHub Issues), package manager and scripts (`package.json`, `Makefile`, `Cargo.toml`, `pyproject.toml`), test command, typecheck command, CLAUDE.md conventions, existing branch naming (`git log --format=%D -50` or `git branch -a`).
2. Write `.crank.md` from [`templates/crank-config.md`](templates/crank-config.md), filling in what you detected and marking the rest `TODO`.
3. **[MODE]** Interactive: show the user the filled config and confirm/correct it before starting — this is a one-time setup they'll reuse. Autonomous: do not start an autonomous loop without a reviewed config; stop and ask.

The config is authoritative. Where a config field is absent, fall back to the defaults noted in each step below.

## Mode dispatch

- Args contain `auto`, `overnight`, or `loop` → **AUTONOMOUS** mode. Cycle cap comes from `--cycles N`; if absent, ask via `AskUserQuestion` ("How many issue cycles before the loop stops?" — offer 1 / 3 / 5) **before** starting. This is the last question of the run — the user is about to walk away, so never start the loop with an assumed cap. Invoking auto mode is standing permission to push feature branches and open PRs per finished issue — never merge, never push to the base branch.
- Args name an issue key → **INTERACTIVE** mode on that issue.
- No args → INTERACTIVE; run the picker and let the user choose.

The pipeline is identical in both modes. The differences are confined to the decision points marked **[MODE]**.

## Step 0 — Pick the issue

Skip if the user named one. Otherwise, using the tracker from config:

1. List open issues in the configured team/project/label scope (Todo/Backlog equivalent).
2. Read each candidate's dependency links (Linear blocking relations; GitHub issue references / task-list parents). An issue is *workable* only when everything blocking it is closed or merged to the base branch.
3. Rank workable issues by: priority, the config's `Ranking signals`, and how many other issues it unblocks.
4. **[MODE]** Interactive: present the top 3–4 with a one-line rationale via `AskUserQuestion`. Autonomous: take the top-ranked one and log the rationale in the progress file.

If a candidate's blocker is in review (PR open, unmerged), prefer a fully unblocked issue. Stack only if nothing else is workable — record the merge order, and after the parent PR merges, retarget the child (`gh pr edit --base <base>`) and verify the base actually reads the base branch.

## Step 1 — Recon

1. Read the issue and its comments, plus any linked doc.
2. Read the config's **Reference docs** list and consult the ones relevant to this issue *before* designing. These exist to stop you guessing about things the project has already decided.
3. Follow the repo's own routing if it has any — a CLAUDE.md "where to dig" table, an architecture doc, an ADR directory.
4. Check what already exists before building: extend the existing module/plugin rather than adding a parallel one.
5. Respect the config's **Blocked-on-input markers** (labels or comment tags meaning "a human owes an answer"). Never fabricate those answers — design around them or park the issue. But check the reference docs and any open-questions log first: the answer may already have landed.

## Step 2 — Spec

Produce a plan before code. If the config names a spec skill (e.g. `dev-flow:linear-spec`), invoke it; otherwise write the plan into the issue body directly.

Either way the spec must end with:

- An issue body enriched with what recon found.
- A **Definition of Done** with exact, checkable criteria.
- A plan document (or plan comment) at Rev 1 / Rev N+1, linked from the issue.
- The issue moved to In Progress.

**Challenge step — [MODE]:**
- Interactive: run the config's challenge skill (default `nigel:poke-holes`) and let the user answer each concern.
- Autonomous: spawn the reviewer agent (default `nigel:nigel`) with the issue body + plan as context. Take each recommendation unless you have a concrete technical reason to deviate; deviations require written reasoning. Post each resolution as a decision comment tagged **"auto-resolved, unattended run"** so the user can audit and overrule later. Batch related concerns into grouped comments to keep the timeline readable.

If the issue has a tightly-coupled sibling covered by the same branch/PR, enrich both issues and say so in each.

### Project-specific spec checks

The config's **Extra spec checks** section lists assessments this project runs on every issue — e.g. "does this need a demo/presenter artefact?", "does this need a migration?", "does this need a docs page?", "does this need a feature flag?".

For each listed check: make the call, fold the outcome into the plan + DoD, and record it as a one-line decision comment. **A negative answer is a recorded decision, not a silent skip** — say you considered it and why not.

**[MODE]** Interactive: recommend, let the user confirm. Autonomous: decide yourself and log it.

## Step 3 — Branch + environment prep

1. If a dev server / watcher is running against a shared dev database, **stop it first** — booting another branch's schema can trigger destructive auto-migration. Note the task id so you can restart it in Step 12.
2. Create the branch using the config's **Branch pattern** (default `<issue-key-lower>-<slug>`), off the base branch — or off the dependency branch tip if stacking (record which).

## Step 4 — Implement

Implement the plan yourself. Work from the plan document you just wrote — don't re-fetch the tracker.

- Hold yourself to the config's **Project conventions** list and the repo's CLAUDE.md as you write. Those are hard constraints, not suggestions.
- Build whatever the Step 2 extra spec checks called for. It's part of the issue, not an afterthought.
- Self-check the gates before considering implementation done.

Note any deviations from the plan (with reasons) as you go — they feed the self-review and the DoD check.

## Step 5 — Self-review (loop)

Re-read your full diff (`git diff <base>...HEAD`) with fresh, adversarial eyes before the gates. Generic catch-list:

- **Atomicity** — multi-row writes that bypass the transaction/unit-of-work; partial-failure states.
- **Race safety** — concurrent paths doing read-modify-write where they need a lock or an atomic operation.
- **Error handling** — swallowed errors, silent fallbacks, empty catch blocks.
- **Test strength** — fuzzy assertions where an exact one is available; tests that pass on a no-op implementation.
- Debug cruft, stray comments, commented-out code.
- Hardcoded values that should be derived (paths, table/column names, ids).
- Deviations from the plan you didn't intend.

Then add the config's **Review catch-list** — the project's own recurring traps.

Fix what you find, then re-read. Loop until you'd sign off on the diff as a reviewer. This is your own pass; the independent mandatory review in Step 9 does not replace it.

**[MODE]** Interactive: surface significant findings/deviations as you go. Autonomous: log them as an issue comment ("self-review findings") and in the progress file.

## Step 6 — Gates

Run the config's **Gates**, in order, all green. Non-negotiable. If the config has none yet, discover them (package scripts, CI workflow) and write them into the config.

For any test suite, record the pass count against the previous baseline: new tests raise the baseline, nothing may drop.

Red gate → back to Step 5 with the failure analysis. Facts first, narrow systematically, root cause before fix. Long-running gates go through the config's runner (default: the `hawk` skill), not a blocking foreground call.

## Step 7 — Live verify

Where the change has a visible surface, prove it live: bring the app up on this branch per the config's **Live verify** notes, then drive the actual behaviour. Capture concrete evidence (ids, strings, states, screenshots) — it feeds the handoff comment.

Use the config's stated tooling and credentials (e.g. API via `arnold`, UI via `agent-browser`, a specific low-privilege login so permission bugs surface). Skip only when the automated coverage genuinely is the whole story, and say so explicitly.

## Step 8 — Definition of Done check

Pull the DoD from the issue body plus any DoD-affecting decision comments. Walk every criterion and mark it met / not-met **with evidence** — a test name, a suite count, a live-verify artefact, a `file:line`. "Covered by the implementation" is not evidence.

- Any unmet criterion → back to Step 5. A deliberately cut or deferred criterion must already exist as a decision comment; if it doesn't, it's unmet, not cut.
- All met → include the evidenced checklist in the PR description and proceed.

**[MODE]** Interactive: show the user the checklist before shipping. Autonomous: post it as an issue comment ("DoD verification").

## Step 9 — Mandatory independent review + fixup (never skip)

With Steps 5–8 green, run a post-implementation review with the config's reviewer agent (default `nigel:nigel`). This is distinct from the Step 2 pre-build challenge, and it is non-negotiable on every cycle in both modes — it's the last quality gate before the PR is born.

1. Spawn the reviewer with: the worktree path, the changed-file list, and `git diff <base>` (point it at the files, don't paste the whole diff), the config's **Project conventions** as hard constraints, and the specific risks of *this* change. Ask for a numbered findings list (severity + `file:line` + risk + recommendation) and a one-line OVERALL verdict.
2. **Triage every finding** — accept or dismiss each with a concrete technical reason. No blind accepts, no hand-waved dismissals.
3. **Apply the fixups you accept**, add tests for any coverage gap surfaced, then **re-run the gates** (typecheck + affected tests at minimum; the full suite if the change is broad).
4. **Record the outcome as an issue comment** — what was fixed, what was dismissed and why. Silent decisions don't exist.
5. A **changes-required** verdict blocks the PR until the accepted changes are applied and re-gated. One review + fixup round is the bar; loop again only if a fixup is itself substantial enough to warrant re-review.

**[MODE]** Interactive: present the triaged findings and let the user choose the fix set. Autonomous: take the recommendations unless you have a concrete technical reason to deviate, apply, re-gate, log the triage.

## Step 10 — Ship

1. Atomic conventional commits, files added by name, title only. Never amend.
2. Push the branch; `gh pr create` with a description covering approach + gates + the DoD checklist. No AI watermarks. Base per config, unless stacked (then record merge order in the PR body).
3. Tracker: attach the PR, move the issue(s) to In Review.

Open as draft unless the repo's convention says otherwise.

## Step 11 — Handoff comment

If the config's **Handoff comment** is `required: yes`, post it on the issue using the configured template (default [`templates/handoff.md`](templates/handoff.md)) with the configured title line, exactly as written (e.g. `# HOW TO DEMO`, `# HOW TO VERIFY`).

Write it NOW, while the implementation is fresh. It must contain exact, reproducible steps with real data — the record you created in Step 7, the flag you toggled — not abstract descriptions. Where the project has a real surface for an action (a script, a trigger, a runbook step), reference it by id instead of re-describing it in prose.

If the cycle covered a sibling issue, one handoff comment on the main issue + a pointer comment on the sibling.

## Step 12 — Env restore + cycle close

1. Restart the dev server on whichever branch the user should return to; note whether the dev database needs a reset.
2. **[MODE]** Interactive: print a cycle summary (issue, PR, gates, evidence) and ask whether to crank the next one. Autonomous: update the progress file and start the next cycle — or stop if the cap is reached or nothing is workable, finishing with a wrap-up summary (PR table, merge order, highlights, loose ends, auto-resolved decisions to review).

## Autonomous mode: the progress file

Maintain `CRANK-PROGRESS.md` at the repo root (git-ignore it) using [`templates/progress-log.md`](templates/progress-log.md). Update it at every step transition, not just cycle ends — it is the compaction anchor. Each cycle's entry ends with a dense **Key design** paragraph capturing the decisions that survive context loss.

## Hard rules (both modes)

- Never push to the base branch. Never merge PRs. Never force-push.
- Never fabricate an answer a human owes (blocked-on-input markers).
- Every review resolution is an issue comment — silent decisions don't exist.
- The DoD is the contract. Nothing ships with an unmet criterion unless the cut is recorded as a decision comment.
- The Step 9 independent review + fixup runs before every ship. A changes-required verdict blocks the PR.
- Every configured extra spec check runs on every issue. "Not needed" is a recorded decision, not a default skip.
- Gates before ship, every time. No "the tests probably pass".
- The handoff comment, when required, is part of done.
- Config gaps are fixed, not guessed around: if you had to work out a project fact this run, write it into `.crank.md` before closing the cycle.
