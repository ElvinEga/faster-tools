#!/usr/bin/env bash
# install.sh — install missing core agent tools via Homebrew.
# Requires explicit authorization: pass --yes as the first argument.
# Usage: install.sh --yes [tool ...]   (no tools = all missing core tools)
set -euo pipefail

if [ "${1:-}" != "--yes" ]; then
  echo "Refusing to install without explicit authorization." >&2
  echo "Usage: $0 --yes [tool ...]" >&2
  exit 2
fi
shift

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found; cannot install." >&2
  exit 1
fi

declare -A formula=(
  [rg]=ripgrep [fd]=fd [fzf]=fzf [jq]=jq [duckdb]=duckdb
  [delta]=git-delta [xh]=xh [watchexec]=watchexec [just]=just
  [semgrep]=semgrep [ast-grep]=ast-grep [gh]=gh
)
core=(rg fd fzf jq duckdb delta xh watchexec just semgrep ast-grep gh)

if [ "$#" -eq 0 ]; then
  for t in "${core[@]}"; do
    command -v "$t" >/dev/null 2>&1 || set -- "$@" "$t"
  done
fi

if [ "$#" -eq 0 ]; then
  echo "Nothing to install: all core tools present."
else
  for t in "$@"; do
    f="${formula[$t]:-}"
    if [ -z "$f" ]; then
      echo "SKIP: unknown tool '$t' (not in core list)" >&2
      continue
    fi
    echo "Installing $f (provides $t)…"
    brew install "$f"
  done
fi

echo "## Post-install verification"
exec bash "$(dirname "$0")/verify.sh"
