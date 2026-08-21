---
name: cmux-sessionizer
description: Configure the cmux-sessionizer (project picker for cmux workspaces) — search paths, per-project layouts, startup commands, env vars. Use when the user asks to add/change a project layout, startup commands, or sessionizer settings. CONFIGURATION ONLY — never run the sessionizer or create/select cmux workspaces on the user's behalf.
---

# cmux-sessionizer configuration

The sessionizer is a user-facing tool: `cmux-sessionizer.sh` (on PATH) fuzzy-picks a
project dir and switches to / creates a cmux workspace for it. Agents only edit its
config. **Never execute `cmux-sessionizer.sh`, `cmux workspace create`, or
`cmux workspace select` as part of this skill** — running it steals the user's focus.
The user runs it themselves.

## Files (all in the dotfiles repo, stowed to ~/.config)

- Repo: `~/dotfiles-housein/.config/cmux-sessionizer/` — edit here so changes are git-tracked.
- `config.json` — global: `search_paths` (crawled: `path`, `min_depth` default 1, `max_depth` default 2) and `extra_paths` (listed as-is).
- `projects/<name>.json` — one file per project, matched by resolved `dir`. Project dirs always appear in the picker.
- `README.md` — full schema with examples.

## Project file schema

All keys optional except `dir`. `~` is expanded.

```json
{
  "dir": "~/Developer/Work/feddersen-monorepo",
  "name": "feddersen",
  "description": "sidebar subtitle",
  "command": "pnpm dev",
  "env": { "NODE_ENV": "development" },
  "layout": { ... }
}
```

- `name`: workspace title; also the re-invoke match key (default: basename with `.` → `_`). Must be unique across projects.
- `command`: sent to the single terminal on creation. Ignored when `layout` exists.
- `layout`: cmux split tree. Containers: `direction` (`horizontal`|`vertical`), `split` (0–1, first child's share), `children`. Leaves: `{"pane": {"surfaces": [{"type": "terminal", "command": "..."}]}}`. Browser surfaces: `{"type": "browser", "url": "..."}`. Surface `command`s are the per-project "autocommands"; each runs in its pane with cwd = project dir.

## Rules

1. Layout/command/env apply only when the workspace is **created**. If a workspace with that `name` is already open, the sessionizer switches to it unchanged — tell the user to close and reopen the workspace to see config changes.
2. After editing, validate every touched file: `jq empty <file>`. For layouts, also check each leaf has a `pane.surfaces` array and each container has `children`.
3. Don't invent startup commands — read the project's `package.json`/`justfile`/README to pick real ones, or ask the user.
4. Commit config changes in the dotfiles repo (conventional title, files by name).
