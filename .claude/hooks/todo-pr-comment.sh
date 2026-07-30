#!/bin/bash
# PostToolUse hook for TodoWrite/TaskUpdate — posts a one-liner to the open PR
# when a todo/task is marked as completed.
# Receives JSON on stdin: { tool_name, tool_input, tool_output }

set -euo pipefail

INPUT=$(cat)

# Extract completed items from the input using python3 (no deps needed)
COMPLETED=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tool_name = data.get('tool_name', '')
tool_input = data.get('tool_input', {})

if tool_name == 'TodoWrite':
    todos = tool_input.get('todos', [])
    for t in todos:
        if t.get('status') == 'completed':
            content = t.get('content', '').strip()
            if content:
                print(content)

elif tool_name == 'TaskUpdate':
    if tool_input.get('status') == 'completed':
        desc = tool_input.get('description', '').strip()
        if desc:
            print(desc)
" 2>/dev/null) || exit 0

# Nothing completed? Exit silently
[ -z "$COMPLETED" ] && exit 0

# Check if a PR exists for the current branch (silently skip if not)
PR_NUMBER=$(gh pr view --json number --jq .number 2>/dev/null) || exit 0
[ -z "$PR_NUMBER" ] && exit 0

# Post a comment for each completed item
while IFS= read -r line; do
    gh pr comment "$PR_NUMBER" --body "✅ $line" 2>/dev/null || true
done <<< "$COMPLETED"
