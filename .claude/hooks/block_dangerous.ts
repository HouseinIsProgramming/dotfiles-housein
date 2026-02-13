#!/usr/bin/env bun

import { resolve, normalize } from "path";

interface ToolInput {
  tool_name: string;
  tool_input: {
    file_path?: string;
    command?: string;
  };
  cwd?: string;
}

function isCredentialFileAccess(
  toolName: string,
  toolInput: ToolInput["tool_input"],
): boolean {
  // Check file-based tools (Read, Write, Edit)
  if (["Read", "Write", "Edit"].includes(toolName)) {
    const filePath = (toolInput.file_path || "").toLowerCase();

    // Block .env files (but allow .env.sample, .env.example)
    if (/\.env(?!\.sample|\.example|rc)/.test(filePath)) {
      return true;
    }

    // Block credential files
    const credentialPatterns = [
      /client_secret\.json/,
      /\.credentials\.json/,
      /token\.pickle/,
      /.*\.pem$/,
      /.*\.key$/,
    ];
    for (const pattern of credentialPatterns) {
      if (pattern.test(filePath)) {
        return true;
      }
    }
  }

  // Check Bash commands trying to read credentials
  if (toolName === "Bash") {
    const command = (toolInput.command || "").toLowerCase();

    // Detect cat, vim, base64, curl with .env files
    const dangerousPatterns = [
      /(cat|vim|nano|less|head|tail|base64)\s+.*\.env/,
      /source\s+.*\.env/,
      /curl.*-H.*\$\{.*\}/, // curl with env variable in header
    ];
    for (const pattern of dangerousPatterns) {
      if (pattern.test(command)) {
        return true;
      }
    }
  }

  return false;
}

function isPipedConfirmationToRm(command: string): boolean {
  const normalized = command.toLowerCase();

  // Block piping confirmation into rm (bypasses rm -i alias)
  const patterns = [
    /\b(echo|yes|printf)\s+.*\|\s*rm\b/, // echo y | rm, yes | rm
    /\b(echo|yes|printf)\s+.*\|\s*xargs\s+rm/, // echo y | xargs rm
    /\brm\b.*<\s*<.*EOF/i, // rm with heredoc
    /\brm\b.*<<<\s*["']?y/i, // rm <<< "y"
  ];

  return patterns.some((p) => p.test(normalized));
}

function isRmOutsideProject(
  command: string,
  cwd: string,
): { outside: boolean; target?: string } {
  // Match rm commands with -r or -f flags
  const rmMatch = command.match(/\brm\s+((?:-[rRfFiIvV]+\s+)*)(.*)/);
  if (!rmMatch) return { outside: false };

  const flags = rmMatch[1] || "";
  const hasRecursiveOrForce = /(-r|-R|-f|-rf|-fr|-Rf|-fR)/i.test(flags);
  if (!hasRecursiveOrForce) return { outside: false };

  // Extract targets (split by space, filter out flags)
  const targetsStr = rmMatch[2].trim();
  if (!targetsStr) return { outside: false };

  // Simple split - doesn't handle quoted paths perfectly but covers most cases
  const targets = targetsStr.split(/\s+/).filter((t) => !t.startsWith("-"));

  const homeDir = process.env.HOME || process.env.USERPROFILE || "";

  for (const target of targets) {
    let resolvedPath: string;

    // Expand ~ to home directory
    const expandedTarget = target.replace(/^~/, homeDir);

    // Resolve to absolute path
    if (expandedTarget.startsWith("/")) {
      resolvedPath = normalize(expandedTarget);
    } else {
      resolvedPath = resolve(cwd, expandedTarget);
    }

    // Normalize both paths for comparison
    const normalizedCwd = normalize(cwd);
    const normalizedTarget = normalize(resolvedPath);

    // Check if target is outside project directory
    if (
      !normalizedTarget.startsWith(normalizedCwd + "/") &&
      normalizedTarget !== normalizedCwd
    ) {
      return { outside: true, target: normalizedTarget };
    }
  }

  return { outside: false };
}

function isDangerousCommand(command: string): boolean {
  // Normalize command (lowercase, collapse whitespace)
  const normalized = command.toLowerCase().trim().replace(/\s+/g, " ");

  // Dangerous rm patterns - always block these regardless of cwd
  const rmPatterns = [
    /\brm\s+-[rf]*[fr][rf]*\s+\/\s*$/, // rm -rf / (root only)
    /\brm\s+-[rf]*[fr][rf]*\s+\/\*/, // rm -rf /*
    /\brm\s+-[rf]*[fr][rf]*\s+~\s*$/, // rm -rf ~ (home only)
    /\brm\s+-[rf]*[fr][rf]*\s+~\/\*/, // rm -rf ~/*
    /\brm\s+-[rf]*[fr][rf]*\s+\$HOME\s*$/, // rm -rf $HOME
  ];
  for (const pattern of rmPatterns) {
    if (pattern.test(normalized)) {
      return true;
    }
  }

  // Dangerous git operations
  const gitPatterns = [
    /git\s+push\s+.*--force/,
    /git\s+reset\s+--hard/,
    /git\s+config\s+--global/,
  ];
  for (const pattern of gitPatterns) {
    if (pattern.test(normalized)) {
      return true;
    }
  }

  // Dangerous chmod operations
  const chmodPatterns = [
    /chmod\s+777/, // World-writable
    /chmod\s+[ugoa]*\+s/, // Setuid/setgid
  ];
  for (const pattern of chmodPatterns) {
    if (pattern.test(normalized)) {
      return true;
    }
  }

  // Block brew install (unauthorized packages)
  if (/\bbrew\s+install\b/.test(normalized)) {
    return true;
  }

  // Block piped confirmation to rm (e.g., echo y | rm, yes | rm)
  const pipedRmPatterns = [
    /(echo|yes|printf)\s+.*\|\s*rm\b/, // echo y | rm, yes | rm
  ];
  for (const pattern of pipedRmPatterns) {
    if (pattern.test(normalized)) {
      return true;
    }
  }

  // Block git push operations (user should do these manually)
  const gitPushPatterns = [
    /git\s+push\b/, // any git push
  ];
  for (const pattern of gitPushPatterns) {
    if (pattern.test(normalized)) {
      return true;
    }
  }

  // Block gh repo create (user should do this manually)
  if (/gh\s+repo\s+create\b/.test(normalized)) {
    return true;
  }

  return false;
}

async function main() {
  // Read tool call data from stdin
  const input = await Bun.stdin.text();
  const inputData: ToolInput = JSON.parse(input);
  const toolName = inputData.tool_name;
  const toolInput = inputData.tool_input;

  // Check credential file access
  if (isCredentialFileAccess(toolName, toolInput)) {
    console.error("BLOCKED: Access to credential files prohibited");
    process.exit(2);
  }

  // Check dangerous bash commands
  if (toolName === "Bash") {
    const command = toolInput.command || "";
    const cwd = inputData.cwd || process.cwd();

    // Check for piped confirmation to rm (bypasses rm -i alias)
    if (isPipedConfirmationToRm(command)) {
      console.error(
        `BLOCKED: Piping confirmation to rm bypasses interactive mode.\n` +
          `Command: ${command}\n` +
          `Your rm is aliased to rm -i for safety. Run manually if needed.`,
      );
      process.exit(2);
    }

    // Check for rm commands targeting files outside project
    const rmCheck = isRmOutsideProject(command, cwd);
    if (rmCheck.outside) {
      console.error(
        `BLOCKED: rm with -r/-f flags targeting path outside project directory.\n` +
          `Command: ${command}\n` +
          `Target: ${rmCheck.target}\n` +
          `Project: ${cwd}\n` +
          `Run this command manually if you really need to delete files outside the project.`,
      );
      process.exit(2);
    }

    if (isDangerousCommand(command)) {
      console.error(
        `BLOCKED: This command requires manual execution.\n` +
          `Command: ${command}\n` +
          `STOP trying to execute this command. Instead, tell the user to run this command themselves.\n` +
          `WAIT for the user's input after this point. Do NOT automatically execute any workarounds for this command being blocked.`,
      );
      process.exit(2);
    }
  }

  // Allow the operation
  process.exit(0);
}

main();
