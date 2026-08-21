#!/usr/bin/env bash
# verify.sh — deterministic check that every core agent tool exists and runs.
# Output: one tab-separated line per tool: STATUS<TAB>tool<TAB>version
# Exit 0 = all present, 1 = at least one missing/broken.
set -u

# shellcheck disable=SC1091  # path resolved via dirname at runtime
. "$(dirname "$0")/lib.sh"

missing=0
for t in $CORE_TOOLS; do
  bin="$(bin_for "$t")"
  if ! have "$bin"; then
    printf 'MISSING\t%s\t-\n' "$t"
    missing=$((missing + 1))
    continue
  fi
  v="$("$bin" --version 2>/dev/null | head -n1)"
  if [ -z "$v" ]; then
    printf 'BROKEN\t%s\tno --version output\n' "$t"
    missing=$((missing + 1))
  else
    printf 'OK\t%s\t%s\n' "$t" "$v"
  fi
done

# shellcheck disable=SC2086
total=$(printf '%s\n' $CORE_TOOLS | wc -l | tr -d ' ')
if [ "$missing" -gt 0 ]; then
  printf 'RESULT\tFAIL\t%d of %s tools missing or broken\n' "$missing" "$total"
  exit 1
fi
printf 'RESULT\tPASS\tall %s core tools verified\n' "$total"
