# cmux-sessionizer

Fuzzy-pick a project directory, switch to its cmux workspace or create one.
Script: `~/.config/scripts/cmux-sessionizer.sh` (optional dir argument skips the picker).

## config.json

```json
{
  "search_paths": [
    { "path": "~/Documents/Github", "min_depth": 1, "max_depth": 2 }
  ],
  "extra_paths": ["~/dotfiles-housein"]
}
```

- `search_paths` — crawled with `find` between `min_depth` (default 1) and `max_depth` (default 2).
- `extra_paths` — added to the picker as-is, no crawling.

## projects/<anything>.json

Per-project settings, matched by resolved `dir`. Project dirs always appear
in the picker even if outside every search path. All keys except `dir` are optional.

```json
{
  "dir": "~/Documents/Github/vendure/vendure",
  "name": "vendure",
  "description": "shown in the workspace sidebar",
  "command": "pnpm dev",
  "env": { "NODE_ENV": "development" },
  "layout": {
    "direction": "horizontal",
    "split": 0.5,
    "children": [
      { "pane": { "surfaces": [{ "type": "terminal", "command": "nvim" }] } },
      {
        "direction": "vertical",
        "split": 0.7,
        "children": [
          { "pane": { "surfaces": [{ "type": "terminal", "command": "pnpm dev" }] } },
          { "pane": { "surfaces": [{ "type": "terminal" }] } }
        ]
      }
    ]
  }
}
```

- `name` — workspace title; also how an existing workspace is found on re-invoke (default: basename, `.` → `_`).
- `command` — sent to the single terminal after creation. Ignored when `layout` is set (layout surfaces define their own commands).
- `layout` — cmux `--layout` JSON: nested `direction`/`split`/`children` nodes; leaves are `{"pane": {"surfaces": [{"type": "terminal", "command": "..."}]}}`. Browser surfaces work too: `{"type": "browser", "url": "..."}`.
- `env` — workspace environment variables (`cmux workspace env <ws>` to inspect).

Commands run per-workspace; nothing is written into the project directory.
