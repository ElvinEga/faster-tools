#!/usr/bin/env bash
# doctor.sh — diagnose the agent environment: verify + audit + config checks.
# Read-only. Exit 0 = healthy, 1 = problems found (details printed).
set -u

# shellcheck disable=SC1091  # path resolved via dirname at runtime
. "$(dirname "$0")/lib.sh"

OS="$(detect_os)"
PKG="$(detect_pkg)"
problems=0
warn() { printf 'WARN\t%s\n' "$1"; problems=$((problems + 1)); }
fail() { printf 'FAIL\t%s\n' "$1"; problems=$((problems + 1)); }
ok() { printf 'OK\t%s\n' "$1"; }

echo "## Doctor — environment"
ok "os: $(uname -s) $(uname -m) ($OS), pkg: $PKG"

echo "## Doctor — core tools"
for t in $CORE_TOOLS; do
  bin="$(bin_for "$t")"
  if ! have "$bin"; then
    case "$t" in
      rg | fd | gh) fail "$t missing (CRITICAL)" ;;
      *) warn "$t missing" ;;
    esac
    continue
  fi
  if [ -z "$("$bin" --version 2>/dev/null | head -n1)" ]; then
    fail "$t installed but --version fails"
  else
    ok "$t"
  fi
done

echo "## Doctor — configuration"
case "$OS" in
  macos)
    case "$(uname -m)" in
      arm64)
        case ":$PATH:" in
          *":/opt/homebrew/bin:"*) ok "PATH includes /opt/homebrew/bin" ;;
          *) warn "PATH missing /opt/homebrew/bin (Apple Silicon Homebrew prefix)" ;;
        esac
        ;;
    esac
    ;;
esac

if have delta; then
  pager="$(git config --get core.pager || true)"
  case "$pager" in
    *delta*) ok "git core.pager uses delta" ;;
    "") warn "git core.pager unset — diffs unformatted; propose: git config --global core.pager 'delta'" ;;
    *) warn "git core.pager is '$pager', not delta" ;;
  esac
fi

if have git && ! have gh; then
  warn "git present but gh missing — PR/issue/CI work degrades"
fi

echo "## Doctor — project toolchain mismatches"
[ -e bun.lock ] && ! have bun && warn "bun.lock present but bun not on PATH"
[ -e pnpm-lock.yaml ] && ! have pnpm && warn "pnpm-lock.yaml present but pnpm not on PATH"
[ -e uv.lock ] && ! have uv && warn "uv.lock present but uv not on PATH"
[ -e Cargo.toml ] && ! have cargo && fail "Cargo.toml present but cargo not on PATH"
[ -e go.mod ] && ! have go && fail "go.mod present but go not on PATH"
[ -e justfile ] && ! have just && warn "justfile present but just not on PATH"

echo "## Result"
if [ "$problems" -eq 0 ]; then
  echo "HEALTHY: no problems found"
  exit 0
fi
printf 'UNHEALTHY: %d problem(s) found\n' "$problems"
exit 1
