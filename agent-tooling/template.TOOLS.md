# TOOLS.md — Agent Tooling (generated + human)

> [!info] For AI agents
> Preferred CLI tools on this machine. Verify with the agent-tooling skill
> (`verify.sh`) rather than trusting this file blindly.

## Tool hierarchy

| Job | Use | Never / fallback |
|-----|-----|------------------|
| Content search | `rg` | never `grep -r` |
| AST-aware code search/rewrite | `ast-grep` | not regex over source |
| Find files | `fd` | fallback `find` |
| Interactive pick | `fzf` | only when human must choose |
| Tiny JSON lookup | `jq` | — |
| Tabular analysis (CSV/JSON/Parquet) | `duckdb -c "SQL"` | not Python scripts |
| HTTP/API tests | `xh` | `curl` only for streaming/odd protocols |
| Diffs | `git diff \| delta` | raw diff |
| Static/security analysis | `semgrep` | findings = ground truth |
| Re-run on change | `watchexec` | no polling loops |
| Project tasks | `just` | not new Makefiles |
| PR / issue / CI | `gh` | not raw REST calls |

## Installed Agent Tooling

<!-- BEGIN GENERATED: agent-tooling -->
<!-- Regenerate via the agent-tooling skill (verify.sh). Do not edit inside this block. -->

| Tool | Status | Version |
|------|--------|---------|

Verified by `agent-tooling/scripts/verify.sh`.
<!-- END GENERATED: agent-tooling -->

## Post-edit verification (edit → verify → fix)

- **Python**: `ruff check . && ruff format .`
- **TS/JS**: `tsc --noEmit` + Biome/ESLint
- **Go**: `go vet ./... && go test ./...`
- **Rust**: `cargo check` then `clippy`
- Security claims: back them with `semgrep --config auto .`

Tests are the ultimate truth. Fix everything checkers report before declaring done.
