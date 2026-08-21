# Crank config

Per-project settings for the `crank` skill. Copy to `.crank.md` (or `.claude/crank.md`) at the
repo root and fill in. Delete sections that don't apply; mark unknowns `TODO` and fix them as
you learn them.

## Tracker

- provider: `linear` | `github`
- team: <Linear team name — omit for GitHub>
- project: <Linear project / GitHub milestone or label scope>
- issue key: <e.g. `VEN` — the prefix in issue identifiers>
- labels to include: <e.g. `ready`, or "any">
- labels to exclude: <e.g. `needs-discussion`>

## Ranking signals

How to pick the next issue, most important first:

- <e.g. priority field>
- <e.g. unblocks the most other issues>
- <e.g. labelled `release-blocker`>

## Blocked-on-input markers

Labels or comment tags meaning a human owes an answer. Never fabricate these.

- <e.g. label `needs-customer-input`>
- <e.g. the open-questions doc at docs/open-questions.md>

## Branching

- base: `main`
- branch pattern: `<user>/<issue-key-lower>-<slug>`
- PR: draft until ready | ready immediately

## Gates

In order. All must be green before ship. Long-running ones go through the runner.

1. `<typecheck command>`
2. `<unit test command>`
3. `<e2e / integration command>` — <any prerequisite, e.g. Postgres on :5432>

- runner: `hawk` (skill) | plain bash
- baseline test count: <n> — update when new tests land

## Live verify

- start command: `<e.g. cd server && bun run dev>`
- URL: <e.g. http://myapp.localhost>
- login: <role/user to verify as — prefer a low-privilege one so permission bugs surface>
- API tooling: <e.g. the `arnold` skill>
- UI tooling: <e.g. the `agent-browser` skill>
- reset data: `<e.g. bun run populate:reset>` — when the seed changed

## Review

- reviewer agent: `nigel:nigel`
- interactive challenge skill: `nigel:poke-holes`
- spec skill: `<e.g. dev-flow:linear-spec — or omit to write the plan inline>`

## Project conventions

Hard constraints passed to the reviewer and enforced during implementation. Keep it to the
non-obvious ones; the reviewer already knows general good practice.

- <e.g. custom fields are embedded columns, never jsonb — no `customFields->>'x'` queries>
- <e.g. e2e assertions must be exact (`toBe`/`toEqual`), never fuzzy>
- <e.g. comments are a last resort, one line, non-obvious intent only>
- <e.g. let TypeScript infer; explicit types only for public API>

## Review catch-list

This project's recurring traps, added to the generic self-review list.

- <e.g. `rawConnection.query` bypasses the ctx transaction — use `withTransaction`>
- <e.g. concurrent paths need advisory locks with sorted keys>

## Extra spec checks

Assessments that run on every issue during Step 2. A negative answer is a recorded decision,
not a silent skip.

- **<name>** — <the question, and what building it looks like: which files, which registry>
  - when to build: <criteria>
  - when guide-only / not needed: <criteria>

## Reference docs

Consult before designing. These stop you guessing about decided things.

- `<path>` — <what it's authoritative for>

## Handoff comment

- required: yes | no
- title: `# HOW TO VERIFY` <!-- exact, all caps; e.g. `# HOW TO DEMO` -->
- audience: <who reads it and what they haven't read>
- template: `templates/handoff.md`

## Notes

- <anything else a fresh context needs: env quirks, ports, shared DB caveats>
