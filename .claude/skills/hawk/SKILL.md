---
name: hawk
description: Run long-running commands (builds, tests, lints) with log file output using the hawk CLI. Use this instead of running commands directly when they may take more than a few seconds. No tmux required.
---

# Hawk — Task Log Manager

Use the `hawk` CLI to run long-running commands with automatic log file capture.

## When to Use

- Test suites: `pnpm test-all`, `pnpm nx run <project>:test`
- Builds: `pnpm nx build <app>`
- Linting: `pnpm lint-all`
- Code generation: `pnpm codegen:myapp`, `pnpm codegen:vendure`
- Any command that takes more than a few seconds

## How to Use

### Start a task

Use Bash with `run_in_background: true`:

```bash
hawk start <name> -- <command>
```

Example:
```bash
hawk start test-all -- pnpm test-all
hawk start build-myapp -- pnpm nx build myapp
hawk start lint -- pnpm lint-all
```

The `<name>` should be short and descriptive. Claude gets auto-notified when the task finishes.

Always tell the user the log path so they can watch with `hawk tail <name>` from their terminal.

### Check output

```bash
hawk output <name>          # last 100 lines
hawk output <name> 50       # last 50 lines
```

### List tasks

```bash
hawk list
```

### Stop a task

```bash
hawk stop <name>
```

## Important

- Always use `run_in_background: true` when calling `hawk start` so you get notified on completion
- Pick short, descriptive names: `test-notifications`, `build-myapp`, `lint`, `codegen`
- After notification, use `hawk output <name>` to check the result
- Tell the user the log path so they can `hawk tail <name>` if they want live output

## If hawk is not installed

Tell the user to install it:

```bash
curl -fsSL https://raw.githubusercontent.com/housien/hawk-tui/main/install.sh | bash
```
