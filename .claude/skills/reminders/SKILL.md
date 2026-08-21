---
name: reminders
description: Manage Apple Reminders via remindctl CLI. Use when user wants to view, add, edit, complete, or delete reminders, manage reminder lists, or filter tasks by date/status/priority. Triggers on "reminders", "remind me", "tasks", "todo".
argument-hint: <what you want to do, e.g. "show undated tasks" or "add Buy milk to Personal due tomorrow">
allowed-tools: Bash(remindctl *)
model: haiku
---

# Reminders

Manage Apple Reminders using `remindctl`. Default list: **Reminders**.

## Your task

If `$ARGUMENTS` is empty, show all incomplete reminders from the default list:
```bash
remindctl list Reminders --no-color | grep -F '[ ]'
```

Otherwise, handle the user's request: $ARGUMENTS

## Command reference

### Show/filter reminders
```bash
remindctl show [filter] [--list <name>] [--no-color]
```
Filters: `today` (default) | `tomorrow` | `week` | `overdue` | `upcoming` | `completed` | `all` | `YYYY-MM-DD`

### Smart filters (use --json + jq)
```bash
# Undated incomplete tasks (user says "undated", "no date", "backlog")
remindctl list <name> --json | jq '[.[] | select(.dueDate == null and .isCompleted == false)]'

# High priority only
remindctl list <name> --json | jq '[.[] | select(.priority == "high" and .isCompleted == false)]'

# Search by keyword
remindctl list <name> --json | jq '[.[] | select(.title | test("keyword"; "i"))]'
```

### List management
```bash
remindctl list                            # show all lists
remindctl list <name>                     # show reminders in list
remindctl list <name> --create            # create new list
remindctl list <name> --rename <new>      # rename
remindctl list <name> --delete --force    # delete
```

### Add a reminder
```bash
remindctl add "<title>" --list <name> [--due <date>] [--notes "<text>"] [--priority none|low|medium|high]
```
Date formats: `today`, `tomorrow`, `YYYY-MM-DD`, `YYYY-MM-DD HH:mm`, ISO 8601.

### Edit a reminder
```bash
remindctl edit <id> [--title "<new>"] [--due <date>] [--list <name>] [--notes "<text>"] [--priority <level>] [--clear-due] [--complete] [--incomplete]
```

### Complete reminders
```bash
remindctl complete <id> [<id2> ...]
```

### Delete reminders
```bash
remindctl delete <id> [<id2> ...] --force
```

## Rules

1. Default list is **Reminders**. Known lists: Reminders, Work, Personal
2. Always use `--no-color` for clean terminal output
3. For destructive ops (delete), confirm with user first unless they said "force"
4. Use `--json` + `jq` for smart filters; use default output for simple display
5. When user says "undated"/"no date"/"backlog" -> filter `dueDate == null`
6. After `show`/`list`, reference items by displayed index
7. Always use `--force` on delete to avoid interactive prompts (after confirming with user)
8. Present results in a clean, readable format — don't dump raw JSON
