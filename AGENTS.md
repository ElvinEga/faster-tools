# AGENTS.md — Agent Rules (always loaded)

High-signal rules only. Full examples & gotchas: see [TOOLS.md](TOOLS.md).

## Tool hierarchy

| Job | Use | Never / fallback |
|-----|-----|------------------|
| Content search | `rg` | never `grep -r`; `-A/-B` for context |
| AST-aware code search/rewrite | `ast-grep` | not regex over source |
| Find files | `fd` | fallback `find` |
| Interactive pick | `fzf` | only when human must choose |
| Tiny JSON lookup | `jq` | — |
| Tabular analysis (CSV/JSON/Parquet) | `duckdb -c "SQL"` | not Python scripts / long jq chains |
| HTTP/API tests | `xh` | `curl` only for streaming/odd protocols |
| Diffs | `git diff \| delta` | raw diff |
| Static/security analysis | `semgrep` | findings = ground truth, never vibes |
| Re-run on change | `watchexec` | no polling loops, don't ask user to re-run |
| Project tasks | `just` | not new Makefiles |
| PR / issue / CI | `gh` | not raw REST calls |

## Always run after editing (edit → verify → fix)

- **Python**: `ruff check . && ruff format .`
- **TS/JS**: `tsc --noEmit` + Biome/ESLint
- **Go**: `go test ./...` + `staticcheck`
- **Rust**: `cargo check` + `clippy`
- **Security claims**: back them with `semgrep --config auto .`
- Tests are the ultimate truth. Fix everything checkers report before declaring done.

## Fallbacks

Preferred tool missing → use the legacy equivalent, note it once, move on:
`rg→grep`, `fd→find`, `xh→curl`, `delta→git diff`, `duckdb→jq/python`.
Don't force a hierarchy tool when a simpler built-in is clearly better for that one case.

## Conventions

- Compose tools (`fd … | rg …`, `git show | delta`); don't reinvent.
- Prefer structured output (`--json`, line numbers) over prose parsing.
- macOS Apple Silicon; tools live in `/opt/homebrew/bin`. All verified installed 2026-08-21.
