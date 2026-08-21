#!/usr/bin/env bash
# install.sh — install approved core agent tools via the detected package manager.
# Requires explicit authorization: pass --yes as the first argument.
# Usage: install.sh --yes [tool ...]   (no tools = all missing core tools)
set -u

# shellcheck disable=SC1091  # path resolved via dirname at runtime
. "$(dirname "$0")/lib.sh"

if [ "${1:-}" != "--yes" ]; then
  echo "Refusing to install without explicit authorization." >&2
  echo "Usage: $0 --yes [tool ...]" >&2
  exit 2
fi
shift

OS="$(detect_os)"
PKG="$(detect_pkg)"

if [ "$PKG" = "none" ]; then
  echo "No supported package manager found on $OS." >&2
  echo "See references/tools.md for manual installation instructions." >&2
  exit 1
fi

pkg_cmd() {
  case "$PKG" in
    brew) echo "brew install" ;;
    apt) echo "sudo apt-get install -y" ;;
    dnf) echo "sudo dnf install -y" ;;
    pacman) echo "sudo pacman -S --noconfirm" ;;
    apk) echo "sudo apk add" ;;
    nix) echo "nix-env -iA" ;;
    winget | choco | scoop) echo "$PKG install" ;;
    *) return 1 ;;
  esac
}

# shellcheck disable=SC2312
INSTALL_CMD="$(pkg_cmd)" || { echo "Unsupported package manager: $PKG" >&2; exit 1; }

if [ "$#" -eq 0 ]; then
  for t in $CORE_TOOLS; do
    bin="$(bin_for "$t")"
    have "$bin" || set -- "$@" "$t"
  done
fi

if [ "$#" -eq 0 ]; then
  echo "Nothing to install: all core tools present."
else
  for t in "$@"; do
    case " $CORE_TOOLS " in
      *" $t "*) ;;
      *) echo "SKIP: unknown tool '$t' (not in core list)" >&2 ; continue ;;
    esac
    p="$(pkg_for "$t" "$OS")"
    if [ -z "$p" ]; then
      echo "MANUAL: '$t' has no native $PKG package on $OS — see references/tools.md"
      continue
    fi
    echo "Installing: $INSTALL_CMD $p"
    # shellcheck disable=SC2086
    $INSTALL_CMD "$p" || echo "FAILED: $p (continue with remaining tools)" >&2
  done
fi

echo "## Post-install verification"
exec bash "$(dirname "$0")/verify.sh"
