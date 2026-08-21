#!/usr/bin/env bash
# audit.sh — read-only inspection of the machine and the current project stack.
# Makes no changes. Sections: Environment, Package managers, Core tools,
# Project stack, Agent docs, Findings.
set -u

have() { command -v "$1" >/dev/null 2>&1; }
has_file() { [ -e "$1" ]; }

echo "## Environment"
printf 'os\t%s %s\n' "$(uname -s)" "$(uname -m)"
printf 'shell\t%s\n' "${SHELL:-unknown}"
if have brew; then printf 'brew\t%s\n' "$(brew --version | head -n1)"; else echo 'brew\tMISSING'; fi

echo "## Package managers"
for pm in node bun deno npm pnpm yarn cargo rustc go python3 uv pip docker git gh; do
  if have "$pm"; then
    v="$("$pm" --version 2>/dev/null | head -n1)"
    printf '%s\t%s\n' "$pm" "${v:-present}"
  fi
done

echo "## Core tools"
core=(rg fd fzf jq duckdb delta xh watchexec just semgrep ast-grep gh)
missing=()
for t in "${core[@]}"; do
  if have "$t"; then
    printf 'OK\t%s\n' "$t"
  else
    printf 'MISSING\t%s\n' "$t"
    missing+=("$t")
  fi
done

echo "## Project stack"
declare -a stacks=()
check() { # check <marker> <label>
  if has_file "$1"; then
    printf 'DETECTED\t%s\t(%s)\n' "$2" "$1"
    stacks+=("$2")
  fi
}
check package.json "Node/TS"
check bun.lock "Bun"
check pnpm-lock.yaml "pnpm"
check yarn.lock "Yarn"
check package-lock.json "npm"
check Cargo.toml "Rust"
check src-tauri "Tauri"
check go.mod "Go"
check pyproject.toml "Python (pyproject)"
check requirements.txt "Python (pip)"
check uv.lock "uv"
check Dockerfile "Docker"
check docker-compose.yml "Docker Compose"
check compose.yaml "Docker Compose"
check Makefile "Make"
check justfile "just"
check .github/workflows "GitHub Actions"

echo "## Agent docs"
for f in AGENTS.md CLAUDE.md TOOLS.md README.md; do
  if has_file "$f"; then printf 'PRESENT\t%s\n' "$f"; else printf 'ABSENT\t%s\n' "$f"; fi
done

echo "## Findings"
for t in "${missing[@]:-}"; do
  [ -z "$t" ] && continue
  case "$t" in
    rg|fd|gh) echo "CRITICAL: $t missing — core agent operation degraded" ;;
    *)        echo "HIGH: $t missing — see TOOLS.md hierarchy" ;;
  esac
done
for s in "${stacks[@]:-}"; do
  case "$s" in
    "Rust")      have cargo || echo "PROJECT: Rust detected but cargo not on PATH" ;;
    "Node/TS")   have node || echo "PROJECT: Node/TS detected but node not on PATH" ;;
    "Bun")       have bun || echo "PROJECT: bun.lock detected but bun not on PATH" ;;
    "Go")        have go || echo "PROJECT: Go detected but go not on PATH" ;;
    "Python (pyproject)"|"Python (pip)"|"uv")
                 have python3 || echo "PROJECT: Python project detected but python3 not on PATH" ;;
  esac
done
has_file Makefile && ! has_file justfile && echo "MEDIUM: Makefile present; consider a justfile for new tasks"
! has_file AGENTS.md && echo "HIGH: no AGENTS.md — agents re-learn conventions every session"

echo "## Result"
printf 'stacks\t%s\n' "${stacks[*]:-none}"
printf 'missing-core\t%s\n' "${#missing[@]}"
