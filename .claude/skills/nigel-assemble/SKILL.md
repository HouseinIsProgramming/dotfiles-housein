---
name: nigel-assemble
description: Multi-agent code review. Runs N independent Nigel reviewers in parallel on a PR, branch, or diff, clusters overlapping findings, adversarially verifies each claim against the actual code, and reports one consolidated summary ranked by cross-agent agreement. Use when the user says "nigel-assemble", asks to review something with multiple Nigels or multiple agents, or wants a consolidated, verified multi-reviewer verdict on a PR or diff.
---

# Nigel, assemble

Independent reviewers who converge on the same finding are usually right. One reviewer alone is a hypothesis. This skill exploits that: same prompt, N agents, no shared context, then agreement counting and verification before anything reaches the user.

## Arguments

`/nigel-assemble <target> [--agents N]`

- `target`: PR number or URL, branch name, or empty (= working tree diff against the default branch).
- `--agents N`: reviewer count, default 3.

## Workflow

### 1. Gather the review packet

Build one identical context packet that every reviewer receives:

- PR: `gh pr view <n> --json title,body,url` and `gh pr diff <n>`. Include the PR description and any linked issue text; reviewers must judge intent, not just the diff.
- Branch/working tree: `git diff <default-branch>...` plus recent commit messages.
- If the diff exceeds ~2000 lines, note it and proceed; do not silently truncate.

Check out the PR branch locally (`gh pr checkout`) if it isn't already, so verification in step 4 reads real code.

### 2. Fan out N Nigels

Spawn all N agents with subagent_type `nigel:nigel` **in a single message** so they run in parallel. Give every agent the *identical* prompt: the packet from step 1, plus:

> Review this independently. Return your findings as a list, each with: one-line claim, file:line, severity (critical / should-fix / nit), and a one-sentence justification. Return raw findings only, no prose summary.

Do not vary the prompts and do not share one agent's output with another. Identical prompts are what make agreement meaningful; varied prompts would make disagreement meaningless.

In the same message, also spawn the off-lens reviewers (they cover what Nigel doesn't):

- `pr-review-toolkit:silent-failure-hunter` — always.
- `pr-review-toolkit:pr-test-analyzer` — only if the diff touches test files.

Off-lens findings do **not** participate in agreement scoring (they have no peers to agree with). They join the pipeline at step 4 as 1-vote clusters tagged with their lens, and get verified like everything else.

### 3. Cluster and score

Merge findings that describe the same underlying issue (same root cause, even if worded differently or anchored to nearby lines). For each cluster record the vote count:

- **N/N or majority**: high signal. These go to verification first and lead the report.
- **1/N**: treat skeptically but still verify; a lone finding can be the one sharp catch.

Agreement is signal, not proof. All N share training biases (e.g. over-flagging defensive code), so unanimous findings still get verified.

### 4. Verify every cluster

For each cluster, read the actual code and try to **refute** the claim: does the failure scenario actually happen with real inputs? Is the "missing check" handled elsewhere? Is it pre-existing code the PR merely touches?

Verdict per cluster:

- **Confirmed**: reproduced the reasoning against real code, and fixing it is in scope for this PR.
- **Refuted**: claim is factually wrong; record the one-line reason.
- **Real but out of scope**: true, but pre-existing or unrelated to this PR's intent.
- **Style-only**: true but purely taste; no behavior change.

If there are more than ~6 clusters, fan verification out to parallel Explore agents (one per cluster, prompted to refute) instead of verifying serially.

### 5. Report

One consolidated summary, nothing per-agent. Order: confirmed by severity, then out-of-scope, then a short dismissed list. For each finding:

```
**[3/3, confirmed] Claim in one line** — `file.ts:123`
Why it matters / what breaks. Suggested fix in one line.
```

Off-lens findings use their lens as the tag: `**[silent-failure, confirmed]**`.

The report lives in the conversation only. Do not write review files or post anywhere unless explicitly instructed.

Close with a verdict line: merge-ready, needs the listed fixes, or needs rework. Dismissed claims get one line each with the refutation reason, so the user can spot-check.

**Never post to GitHub.** The output is a draft for the user; posting is a separate, explicit request (then follow the PR-review-comment style from CLAUDE.md).
