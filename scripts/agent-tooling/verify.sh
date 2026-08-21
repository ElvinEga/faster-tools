#!/usr/bin/env bash
# verify.sh — deterministic check that every core agent tool exists and runs.
# Output: one tab-separated line per tool: STATUS<TAB>tool<TAB>version
# Exit 0 = all present, 1 = at least one missing/broken.
set -u

tools=(rg fd fzf jq duckdb delta xh watchexec just semgrep ast-grep gh)
missing=0

for t in "${tools[@]}"; do
  if ! command -v "$t" >/dev/null 2>&1; then
    printf 'MISSING\t%s\t-\n' "$t"
    missing=$((missing + 1))
    continue
  fi
  v="$("$t" --version 2>/dev/null | head -n1)"
  if [ -z "$v" ]; then
    printf 'BROKEN\t%s\tno --version output\n' "$t"
    missing=$((missing + 1))
  else
    printf 'OK\t%s\t%s\n' "$t" "$v"
  fi
done

if [ "$missing" -gt 0 ]; then
  printf 'RESULT\tFAIL\t%d of %d tools missing or broken\n' "$missing" "${#tools[@]}"
  exit 1
fi
printf 'RESULT\tPASS\tall %d core tools verified\n' "${#tools[@]}"
