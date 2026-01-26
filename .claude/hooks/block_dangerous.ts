#!/usr/bin/env bun

interface ToolInput {
  tool_name: string;
  tool_input: {
    file_path?: string;
    command?: string;
  };
}

function isCredentialFileAccess(toolName: string, toolInput: ToolInput["tool_input"]): boolean {
  // Check file-based tools (Read, Write, Edit)
  if (["Read", "Write", "Edit"].includes(toolName)) {
    const filePath = (toolInput.file_path || "").toLowerCase();

    // Block .env files (but allow .env.sample, .env.example)
    if (/\.env(?!\.sample|\.example)/.test(filePath)) {
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

function isDangerousCommand(command: string): boolean {
  // Normalize command (lowercase, collapse whitespace)
  const normalized = command.toLowerCase().trim().replace(/\s+/g, " ");

  // Dangerous rm patterns
  const rmPatterns = [
    /\brm\s+-[rf]*[fr][rf]*\s+\//, // rm -rf /, rm -fr /, etc.
    /\brm\s+-[rf]*[fr][rf]*\s+\*/, // rm -rf *, rm -fr *, etc.
    /\brm\s+-[rf]*[fr][rf]*\s+~/, // rm -rf ~
    /\brm\s+-[rf]*[fr][rf]*\s+\$HOME/, // rm -rf $HOME
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
    if (isDangerousCommand(command)) {
      console.error(
        `BLOCKED: This command requires manual execution.\n` +
        `Command: ${command}\n` +
        `STOP trying to execute this command. Instead, tell the user to run this command themselves.\n` +
        `WAIT for the user's input after this point. Do NOT automatically execute any workarounds for this command being blocked.`
      );
      process.exit(2);
    }
  }

  // Allow the operation
  process.exit(0);
}

main();
