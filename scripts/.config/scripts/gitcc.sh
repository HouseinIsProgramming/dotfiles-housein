#!/usr/bin/env zsh

set -euo pipefail

# --- helpers ---------------------------------------------------------------

fzf_or_sk() {
  # Prefer sk if installed, else fzf
  if command -v sk >/dev/null 2>&1; then
    sk "$@"
  else
    fzf "$@"
  fi
}

die() {
  print -r -- "$*" >&2
  exit 1
}

# --- 1. Select commit type -------------------------------------------------

types=(
  "feat     – A new feature"
  "fix      – A bug fix"
  "chore    – Build / tooling / maintenance"
  "refactor – Code change that neither fixes a bug nor adds a feature"
  "docs     – Documentation only changes"
  "test     – Adding or fixing tests"
  "style    – Formatting / style (no code change)"
  "perf     – Performance improvements"
  "ci       – CI related changes"
)

type_line=$(
  printf '%s\n' "${types[@]}" |
    fzf_or_sk --prompt="Commit type> " \
      --height=12 --reverse --border \
      --ansi
) || die "No commit type chosen."

# type is the first word on the selected line
commit_type=${type_line%% *}
[[ -n "$commit_type" ]] || die "Could not parse commit type."

# --- 2. Discover scopes from folders --------------------------------------

# Change this root if needed
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root" || die "Cannot cd to repo root."

scope_dirs=()

# Collect first-level dirs from apps/, packages/, lib/
for base in apps packages lib; do
  if [[ -d "$base" ]]; then
    # Only first-level directories, ignore files
    while IFS= read -r dir; do
      scope_dirs+=("${base}/${dir}")
    done < <(find "$base" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
  fi
done

# Deduplicate and sort
if (( ${#scope_dirs[@]} > 0 )); then
  scopes=("${(@u)scope_dirs}")
else
  scopes=()
fi

# Add special options
scopes+=("[no scope]" "[custom scope]")

scope_selection=$(
  printf '%s\n' "${scopes[@]}" |
    fzf_or_sk --prompt="Scope> " \
      --height=15 --reverse --border \
      --ansi
) || die "No scope chosen."

scope=""
case "$scope_selection" in
  "[no scope]")
    scope=""
    ;;
  "[custom scope]")
    read "scope?Enter custom scope (e.g. api, ci, deps): "
    scope=${scope//[:()]/} # basic sanitization
    ;;
  *)
    # Strip leading path prefix if you only want the leaf name
    # Example: apps/web -> web
    #          packages/utils -> utils
    scope=$(basename "$scope_selection")
    ;;
esac

# --- 3. Ask for commit message --------------------------------------------

read "subject?Commit message (short, imperative): "

[[ -n "$subject" ]] || die "Commit message cannot be empty."

# --- 4. Format final conventional commit string ---------------------------

if [[ -n "$scope" ]]; then
  commit_msg="${commit_type}(${scope}): ${subject}"
else
  commit_msg="${commit_type}: ${subject}"
fi

print
print "Proposed commit:"
print "  $commit_msg"
print

# --- 5. Confirm and commit -------------------------------------------------

read "confirm?Use this commit message? [y/N] "

case "$confirm" in
  y|Y|yes|YES)
    print "Running: git commit -m \"$commit_msg\""
    git commit -m "$commit_msg"
    ;;
  *)
    print "Aborted."
    ;;
esac
