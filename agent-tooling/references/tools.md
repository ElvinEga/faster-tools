# Tool Catalog

Core tools, what they're for, and how to install them per platform.
`install.sh` uses this mapping; empty cells mean "no native package — use the
manual method listed".

| Tool | Purpose | macOS (brew) | Debian/Ubuntu (apt) | Fedora (dnf) | Arch (pacman) | Manual fallback |
|------|---------|--------------|---------------------|--------------|---------------|-----------------|
| rg | content search | `ripgrep` | `ripgrep` | `ripgrep` | `ripgrep` | cargo: `cargo install ripgrep` |
| fd | file discovery | `fd` | `fd-find` → binary is `fdfind` | `fd-find` | `fd` | cargo: `cargo install fd-find` |
| fzf | interactive pick | `fzf` | `fzf` | `fzf` | `fzf` | git clone + `./install` |
| jq | tiny JSON lookups | `jq` | `jq` | `jq` | `jq` | static binary from GitHub releases |
| duckdb | tabular analysis (CSV/JSON/Parquet) | `duckdb` | — | — | AUR | CLI from duckdb.org releases |
| delta | git diffs for agents | `git-delta` | `git-delta` | `git-delta` | `git-delta` | cargo: `cargo install git-delta` |
| xh | HTTP/API testing | `xh` | `xh` | `xh` | `xh` | cargo: `cargo install xh` |
| watchexec | re-run on change | `watchexec` | `watchexec` | `watchexec` | `watchexec` | cargo: `cargo install watchexec` |
| just | project task runner | `just` | `just` | `just` | `just` | cargo: `cargo install just` |
| semgrep | static/security analysis | `semgrep` | — | — | AUR | `pipx install semgrep` |
| ast-grep | AST-aware search/rewrite | `ast-grep` | — | — | `ast-grep` | `npm i -g @ast-grep/cli` or `cargo install ast-grep` |
| gh | GitHub PR/issue/CI | `gh` | `gh` | `gh` | `gh` | deb/rpm from cli.github.com |

## Platform gotchas

- **Debian/Ubuntu**: `fd-find` installs `fdfind`. Scripts resolve this via
  `bin_for()`; optionally `sudo ln -s $(which fdfind) /usr/local/bin/fd`.
- **Debian/Ubuntu**: `gh`, `duckdb` need the vendor repo or a release binary;
  `semgrep` via `pipx`; `ast-grep` via npm/cargo.
- **Windows**: prefer `scoop install ripgrep fd fzf jq duckdb git-delta xh
  watchexec just ast-grep`; semgrep needs WSL or pip.
- **NixOS**: use `nix-env -iA nixpkgs.<name>`; names match the macOS column.

## Post-install configuration worth proposing

```bash
# agent-navigable diffs (ask before changing user config)
git config --global core.pager "delta --side-by-side --line-numbers"
```
