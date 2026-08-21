#!/usr/bin/env bash
# lib.sh — shared platform detection. Source this; do not execute.
# Compatible with macOS bash 3.2 (no associative arrays, no ${var,,}).

# shellcheck disable=SC2034  # consumed by scripts that source this file
CORE_TOOLS="rg fd fzf jq duckdb delta xh watchexec just semgrep ast-grep gh"

have() { command -v "$1" >/dev/null 2>&1; }

# detect_os -> macos | debian | fedora | arch | alpine | nixos | linux | windows | unknown
detect_os() {
  case "$(uname -s)" in
    Darwin)
      echo macos
      ;;
    Linux)
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID:-}" in
          ubuntu | debian | linuxmint | pop | raspbian) echo debian ;;
          fedora | rhel | centos | rocky | alma | amzn | ol) echo fedora ;;
          arch | manjaro | endeavouros | cachyos) echo arch ;;
          alpine) echo alpine ;;
          nixos) echo nixos ;;
          *) echo linux ;;
        esac
      else
        echo linux
      fi
      ;;
    MINGW* | MSYS* | CYGWIN*) echo windows ;;
    *) echo unknown ;;
  esac
}

# detect_pkg -> brew | apt | dnf | pacman | apk | nix | winget | choco | scoop | none
detect_pkg() {
  if have brew; then echo brew
  elif have apt-get; then echo apt
  elif have dnf; then echo dnf
  elif have pacman; then echo pacman
  elif have apk; then echo apk
  elif have nix-env; then echo nix
  elif have winget; then echo winget
  elif have choco; then echo choco
  elif have scoop; then echo scoop
  else echo none
  fi
}

# bin_for TOOL -> actual binary name on this platform (Debian: fd-find ships fdfind)
bin_for() {
  _t="$1"
  if [ "$_t" = "fd" ] && ! have fd && have fdfind; then
    echo fdfind
  else
    echo "$_t"
  fi
}

# pkg_for TOOL OS -> package name for the detected package manager's ecosystem,
# or empty string when no native package exists (see references/tools.md).
pkg_for() {
  _t="$1"
  _os="$2"
  case "$_os" in
    macos)
      case "$_t" in
        rg) echo ripgrep ;;
        delta) echo git-delta ;;
        *) echo "$_t" ;;
      esac
      ;;
    debian)
      case "$_t" in
        rg) echo ripgrep ;;
        fd) echo fd-find ;;
        delta) echo git-delta ;;
        duckdb | semgrep | ast-grep) echo "" ;;
        *) echo "$_t" ;;
      esac
      ;;
    fedora)
      case "$_t" in
        fd) echo fd-find ;;
        delta) echo git-delta ;;
        duckdb | semgrep | ast-grep) echo "" ;;
        *) echo "$_t" ;;
      esac
      ;;
    arch)
      case "$_t" in
        delta) echo git-delta ;;
        semgrep | duckdb) echo "" ;;
        *) echo "$_t" ;;
      esac
      ;;
    alpine)
      case "$_t" in
        rg) echo ripgrep ;;
        fd) echo fd ;;
        delta | duckdb | semgrep | ast-grep) echo "" ;;
        *) echo "$_t" ;;
      esac
      ;;
    *)
      echo ""
      ;;
  esac
}
