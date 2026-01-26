---
name: tmux-windows
description: Run long-running commands and commands with large outputs in tmux windows instead of blocking the terminal. Use this skill when running dev servers, test suites, build processes, log tailing, or any command that produces continuous output or runs indefinitely.
---

# tmux Windows Skill

Run commands in separate tmux windows for better visibility and non-blocking execution.

## When to Use This Skill

Use tmux windows instead of background processes (`&`) or the standard bash tool when:

- **Long-running processes**: Dev servers, watch modes, file watchers
- **Commands with large output**: Test suites, builds, linting entire codebases
- **Processes you need to monitor**: Log tailing, streaming data
- **Interactive processes**: REPLs, debuggers (with send-keys)

## Prerequisites

You must already be running inside a tmux session. Check with:
```bash
[ -n "$TMUX" ] && echo "In tmux" || echo "Not in tmux"
```

If not in tmux, fall back to running commands normally.

## Core Commands

### Create a new window and run a command
```bash
# Named window with a command
tmux new-window -n <window-name> '<command>'

# Examples:
tmux new-window -n server 'npm run dev'
tmux new-window -n tests 'npm test --watch'
tmux new-window -n logs 'tail -f logs/app.log'
tmux new-window -n build 'npm run build --watch'
```

### Get output from a window
```bash
# Last 100 lines (good default)
tmux capture-pane -t <window-name> -p -S -100

# Last 500 lines (for more context)
tmux capture-pane -t <window-name> -p -S -500

# Entire scrollback buffer
tmux capture-pane -t <window-name> -p -S -
```

### List active windows
```bash
tmux list-windows -F '#{window_index}: #{window_name} (#{pane_current_command})'
```

### Send commands to a running window
```bash
# Send text + Enter to execute
tmux send-keys -t <window-name> 'your command here' Enter

# Send control keys
tmux send-keys -t <window-name> C-c      # Ctrl+C (interrupt)
tmux send-keys -t <window-name> C-d      # Ctrl+D (EOF)
tmux send-keys -t <window-name> C-z      # Ctrl+Z (suspend)
```

### Kill a window
```bash
tmux kill-window -t <window-name>
```

## Naming Conventions

Use descriptive, short names for windows:
- `server` - Main dev server
- `tests` - Test runner
- `logs` - Log output
- `build` - Build process
- `db` - Database console
- `<feature>-server` - Feature-specific servers

## Workflow Pattern

1. **Start**: Create a window for the long-running command
2. **Work**: Continue other tasks in your main window
3. **Check**: Periodically capture output to monitor progress
4. **React**: If errors appear, address them
5. **Cleanup**: Kill windows when done

## Example: Running Tests

```bash
# Start tests in background window
tmux new-window -n tests 'npm test'

# ... continue working ...

# Check if tests finished and get results
tmux capture-pane -t tests -p -S -50
```

## Example: Dev Server with Log Monitoring

```bash
# Start server
tmux new-window -n server 'npm run dev'

# Start log watcher
tmux new-window -n logs 'tail -f logs/debug.log'

# Check server output
tmux capture-pane -t server -p -S -30

# Check logs
tmux capture-pane -t logs -p -S -100
```

## Error Handling

If a window doesn't exist:
```
can't find window: <name>
```

Check available windows with `tmux list-windows` first.

## Important Notes

- Window names must be unique within a session
- Commands run in the window's shell context (inherits env vars)
- Use `-S -<lines>` to limit output capture (prevents huge outputs)
- The `-p` flag prints to stdout instead of a buffer
- Always check if you're in tmux before using these commands
