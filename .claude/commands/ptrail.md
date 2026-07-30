# Paper Trail — Post session context to PR

You are writing a "paper trail" comment for the current PR. This is NOT a diff summary or git log paste — it's a first-person account of what happened this session, focused on decisions and context.

## Steps

1. **Gather context from the session:**
   - Review the conversation history: decisions made, problems encountered, approaches tried and abandoned
   - Run `git log --oneline main..HEAD` to see commits on this branch
   - Run `git diff --stat main..HEAD` to see what files changed
   - Check the current task list using TaskGet/TaskList to see completed and remaining tasks

2. **If the user provided extra context, incorporate it:**
   $ARGUMENTS

3. **Write a structured comment in this format:**

```
## 📝 Session Trail

### What was done
- [Bullet points of what was accomplished]

### Key decisions
- [Decision]: [Why we went this way instead of alternatives]

### Surprises / harder than expected
- [Anything that was unexpected or took longer]

### Shortcuts & tech debt
- [Any tradeoffs made, things deferred, or debt introduced]
- [Write "None" if clean]

### Additional context
- [Any extra context from $ARGUMENTS, or "None"]

### 📋 Task Checkpoint
- [x] [Completed task 1]
- [x] [Completed task 2]
- [ ] [Remaining task 3]
- [ ] [Remaining task 4]
```

4. **Post to the PR:**
   - Run `gh pr view --json number --jq .number` to check if a PR exists for the current branch
   - If a PR exists: post the comment using `gh pr comment <number> --body "<comment>"`
   - If no PR exists: print the summary to the user and say "No open PR found for this branch — here's the summary instead."

## Guidelines
- Write in first person ("I decided...", "We hit a problem with...", "I chose X over Y because...")
- Be honest about tradeoffs and shortcuts
- Don't just list commits — explain the *why* behind changes
- Keep it concise but capture anything a future reader would need to understand the session's context
- The Task Checkpoint section is critical — it's how the next session knows what's left to do
- Use the HEREDOC pattern when passing the body to `gh pr comment` to preserve formatting
