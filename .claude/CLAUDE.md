## MCP Tools and Tools

- When starting long running tasks, such as dev servers and tests, use the `tmux` terminal multiplexer through the commands you have access `tmux-windows` skill
- To search for code patternn use the `asp-grep` tool, if it does not work fall back to your preferred tool

## Before Writing Code

- Read existing code patterns before implementing new features
- Check for existing utilities/helpers before creating new ones
- Understand the file structure before adding new files

## Code Quality

- Handle errors explicitly, never silently fail
- Add types (TypeScript) but let typescript infer types, add explicit types only when necessary

## Git Workflow

- Write clear, conventional commit messages
- Keep commits atomic (one logical change per commit)
- Never force push to main/master
- Do not make pushes to remote branches automatically, keep them local
- always make logical commits as you go

## Communication

- Be concise, skip unnecessary preamble
- When unsure, ask clarifying questions before implementing
- If a task is ambiguous, always ask for clarity, propose a plan before coding
- Tell me when you're making assumptions

## Safety

- Always verify file paths before destructive operations
- Run tests after making changes
- Don't delete files without explicit confirmation

## Complex Tasks

- Use sequential-thinking for architectural decisions
- Break large tasks into phases, confirm each before proceeding
- always make logical commits as you go

## Response Style

- No yapping - get to the point
- Show code, not just explanations of code
- when pointint out issues in code during a review, mention the file and line number
- Minimal comments, only where truly needed
- be extremely concise sacrifice grammar for the sake of concision
- when writing file paths and names, please give the path relative to the project root, in this format `/apps/my-app/src/components/MyComponent.tsx` or `/apps/my-app/src/components/MyComponent.tsx:123` when lines are relevant

## Commiting Changes

- Never force push to main/master
- only add files by name to commit, never use `git add .` or `git add *`
- when commiting, always use conventioanl commit messages, do not use emojies, do not use descriptions, only titles.
- When you are committing code, ALWAYS create logical commits and do a single, final push afterwards in case it is asked by the user
- do not ammend commits
- do not include claude watermarks in commits
