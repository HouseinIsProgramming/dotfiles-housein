#!/usr/bin/env bash
set -euo pipefail

NAME="${1:?Usage: justworktree <name>}"

# Must be inside a git worktree (not the main repo)
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "error: not inside a git repository"
  exit 1
fi

MAIN_GIT_DIR="$(git rev-parse --git-common-dir)"
ACTUAL_GIT_DIR="$(git rev-parse --git-dir)"

if [[ "$MAIN_GIT_DIR" != "$ACTUAL_GIT_DIR" ]]; then
  # We're in a worktree — copy .env.local from main repo
  MAIN_REPO_ROOT="$(cd "$MAIN_GIT_DIR/.." && pwd)"
  ENV_FILE="$MAIN_REPO_ROOT/.env.local"
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "error: $ENV_FILE not found"
    exit 1
  fi
  cp "$ENV_FILE" .env.local
  echo "copied .env.local from $MAIN_REPO_ROOT"
else
  echo "running in main repo, skipping .env.local copy"
fi

# Overwrite justfile
rm -f justfile
cat > justfile <<EOF
set dotenv-filename := ".env.local"

# Vendure server (http://${NAME}.localhost:1355)
serve:
    portless ${NAME} sh -c 'VENDURE_PORT=\$PORT exec bunx nx run vendure-server:serve'

# Dashboard dev server (http://dashboard.${NAME}.localhost:1355)
dashboard:
    cd apps/vendure-server && portless dashboard.${NAME} bunx vite

# Storefront dev server (http://storefront.${NAME}.localhost:1355)
storefront:
    cd apps/storefront && portless storefront.${NAME} bunx next dev
EOF

echo "created justfile with portless name: ${NAME}"
echo ""
echo "  just serve       -> http://${NAME}.localhost:1355"
echo "  just dashboard   -> http://dashboard.${NAME}.localhost:1355"
echo "  just storefront  -> http://storefront.${NAME}.localhost:1355"
