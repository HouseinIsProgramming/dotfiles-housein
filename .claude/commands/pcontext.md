# Pull Context — Load ticket + PR context into session

You are loading all available context about the current branch's work into this session.

## Steps

### 1. Detect branch and ticket ID
- Run `git branch --show-current` to get the current branch name
- Extract a Linear ticket ID if present (pattern: uppercase letters + dash + digits, e.g. `ENG-123`, `CORE-456`)
  - Common branch formats: `feat/ENG-123-description`, `fix/ENG-123`, `ENG-123-something`

### 2. Pull PR context
- Run `gh pr view --json title,body,comments,url,state` to get the PR details
- If no PR exists, note that and skip PR-related context
- If PR exists, extract:
  - PR title and description
  - All comments (these are prior session trails and progress updates)
  - The most recent `📋 Task Checkpoint` section — this has the latest task state

### 3. Pull Linear ticket context (if ticket ID found)
- Try the Linear MCP tool first: use `mcp__plugin_linear_linear__get_issue` with the ticket ID
- If MCP is not available, use curl:
  ```
  curl -s -X POST https://api.linear.app/graphql \
    -H "Authorization: $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"query": "{ issue(id: \"TICKET_ID\") { title description state { name } comments { nodes { body createdAt user { name } } } } }"}'
  ```
- Extract: ticket title, description, current status, and comments

### 4. Synthesize context
Present a clear summary with these sections:

```
## 🔍 Context Loaded

### What this is about
[Synthesized from ticket description + PR description]

### Current status
[From Linear status + latest PR comments]

### What's been done
[From PR comments / session trails, in chronological order]

### What still needs to be done
[Remaining work from the latest Task Checkpoint, or inferred from ticket/PR]
```

### 5. Create tasks for outstanding work
- If a Task Checkpoint was found in PR comments: create tasks from the unchecked `[ ]` items
- If no checkpoint exists but Linear ticket has context: create tasks from the ticket requirements
- If neither exists (session 0 with no ticket): ask the user "What are you working on?" and create tasks from their answer
- Use TaskCreate for each task
- Be specific — each task should be an actionable unit of work, not a vague goal

## Guidelines
- Prioritize the most recent Task Checkpoint — it reflects the latest known state
- Don't create duplicate tasks if similar ones already exist
- If truly nothing exists (no PR, no ticket, no checkpoint), just ask the user what they're doing
