#!/usr/bin/env bun
/**
 * Claude Code Hook: Block ALL git push operations
 * Keeps commits local until user manually pushes.
 *
 * Known limitation: Variable indirection (cmd="git push"; $cmd) not caught.
 */

interface HookInput {
  tool_name: string;
  tool_input?: {
    command?: string;
    [key: string]: unknown;
  };
}

function isGitPush(command: string): boolean {
  const normalized = command.trim();
  if (!normalized) return false;

  // git stash push saves local changes - NOT a remote push, allow it
  if (/\bgit\s+stash\s+push\b/i.test(normalized)) return false;

  // Direct git push anywhere in command (handles &&, ;, |, newlines)
  if (/\bgit\s+push\b/i.test(normalized)) return true;

  // Catch evasion attempts via subshells/eval
  const evasionPatterns = [
    /\beval\s+.*git.*push/i,           // eval "git push"
    /\b(bash|sh|zsh)\s+-c\s+.*git.*push/i, // sh -c "git push"
    /\$\(.*git.*push.*\)/i,            // $(git push)
    /`.*git.*push.*`/i,                // `git push`
  ];

  if (evasionPatterns.some(p => p.test(normalized))) return true;

  // CATCH-ALL: if "git" and "push" appear anywhere, block it
  if (/git/i.test(normalized) && /push/i.test(normalized)) return true;

  return false;
}

const input = await Bun.stdin.text();

let data: HookInput;
try {
  data = JSON.parse(input);
} catch {
  // Fail closed - block on malformed input
  console.error("Hook error: invalid JSON input, blocking for safety");
  process.exit(2);
}

if (data.tool_name !== "Bash") {
  process.exit(0);
}

const command = data.tool_input?.command ?? "";

if (isGitPush(command)) {
  console.error(
    `BLOCKED: git push is not allowed.\n` +
    `Command: ${command}\n\n` +
    `All commits stay local. Push manually when ready.\n` +
    `DO NOT attempt workarounds or ask to push.`
  );
  process.exit(2);
}

process.exit(0);

export {};
