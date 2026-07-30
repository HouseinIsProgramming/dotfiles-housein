#!/usr/bin/env python3
import json
import re
import sys


def main():
    # Read tool call data from stdin
    input_data = json.load(sys.stdin)
    tool_name = input_data.get("tool_name")
    tool_input = input_data.get("tool_input")

    # Check credential file access
    if is_credential_file_access(tool_name, tool_input):
        print("BLOCKED: Access to credential files prohibited", file=sys.stderr)
        sys.exit(2)  # Block the operation

    # Check dangerous bash commands
    if tool_name == "Bash":
        command = tool_input.get("command", "")
        if is_dangerous_command(command):
            if re.search(r"\brm\b", command.lower()):
                print(
                    f"BLOCKED: `rm` is not allowed. Use `rip` instead.\n"
                    f"  rip <file>     — delete a file (recoverable)\n"
                    f"  rip <dir>/     — delete a directory (recoverable)\n"
                    f"  rip -u         — undo last deletion\n"
                    f"Re-run your command using `rip`.",
                    file=sys.stderr,
                )
            else:
                print(
                    f"BLOCKED: This command requires manual execution.\n"
                    f"Command: {command}\n"
                    f"STOP trying to execute this command. "
                    f"Instead, tell the user to run this command themselves.\n"
                    f"WAIT for the user's input after this point. "
                    f"Do NOT automatically execute any workarounds for this command being blocked.",
                    file=sys.stderr,
                )
            sys.exit(2)

    # Allow the operation
    sys.exit(0)


def is_credential_file_access(tool_name, tool_input):
    """Block access to credential files like .env, client_secret.json"""

    # Check file-based tools (Read, Write, Edit)
    if tool_name in ["Read", "Write", "Edit"]:
        file_path = tool_input.get("file_path", "").lower()

        # Block .env files (but allow .env.sample, .env.example)
        if re.search(r"\.env(?!\.sample|\.example)", file_path):
            return True

        # Block credential files
        credential_patterns = [
            r"client_secret\.json",
            r"\.credentials\.json",
            r"token\.pickle",
            r".*\.pem$",
            r".*\.key$",
        ]
        for pattern in credential_patterns:
            if re.search(pattern, file_path):
                return True

    # Check Bash commands trying to read credentials
    if tool_name == "Bash":
        command = tool_input.get("command", "").lower()

        # Detect cat, vim, base64, curl with .env files
        dangerous_patterns = [
            r"(cat|vim|nano|less|head|tail|base64)\s+.*\.env",
            r"source\s+.*\.env",
            r"curl.*-H.*\$\{.*\}",  # curl with env variable in header
        ]
        for pattern in dangerous_patterns:
            if re.search(pattern, command):
                return True

    return False


def is_dangerous_command(command):
    """Block destructive bash commands"""

    # Normalize command (lowercase, collapse whitespace)
    normalized = re.sub(r"\s+", " ", command.lower().strip())

    # Block all rm usage — use rip instead (but allow git rm)
    if re.search(r"\brm\b", normalized) and not re.search(r"\bgit\s+rm\b", normalized):
        return True

    # Dangerous git operations
    git_patterns = [
        r"git\s+push\s+.*--force",
        r"git\s+reset\s+--hard",
        r"git\s+config\s+--global",
    ]
    for pattern in git_patterns:
        if re.search(pattern, normalized):
            return True

    # Dangerous chmod operations
    chmod_patterns = [
        r"chmod\s+777",  # World-writable
        r"chmod\s+[ugoa]*\+s",  # Setuid/setgid
    ]
    for pattern in chmod_patterns:
        if re.search(pattern, normalized):
            return True

    # Block brew install (unauthorized packages)
    if re.search(r"\bbrew\s+install\b", normalized):
        return True

    # Block piped confirmation to rm (e.g., echo y | rm, yes | rm)
    piped_rm_patterns = [
        r"(echo|yes|printf)\s+.*\|\s*rm\b",  # echo y | rm, yes | rm
    ]
    for pattern in piped_rm_patterns:
        if re.search(pattern, normalized):
            return True

    # Block gh repo create (user should do this manually)
    if re.search(r"gh\s+repo\s+create\b", normalized):
        return True

    return False


if __name__ == "__main__":
    main()
