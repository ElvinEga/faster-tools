
# Tools — AI Agent Tooling Instructions

> [!info] For AI agents
> This file tells you which CLI tools to prefer on this machine. All tools below are **installed** (verified 2026-08-21 via Homebrew). Use them instead of the legacy defaults. They are faster, produce structured output that you parse more reliably, and waste fewer context tokens.

## One-line install (fresh machines)

```bash
brew install ripgrep fd fzf duckdb git-delta xh watchexec just semgrep ast-grep gh
```

---

## Search & File Lookup

### ripgrep (`rg`) — use INSTEAD of `grep`

Fast, respects `.gitignore` automatically, recursive by default.

```bash
rg "pattern" src/              # search with context
rg -t py "def main"            # filter by file type
rg -l "TODO"                   # files-only listing
rg "pattern" -A 3 -B 3         # context lines
```

Never write `grep -r`. Never pipe `find` into `grep`.

> [!warning] Flag gotchas (grep muscle memory will bite you)
> ripgrep flags differ from grep where it matters:
>
> | You want | grep habit | rg correct |
> |----------|-----------|------------|
> | Extended regex | `-E` | nothing — rg IS regex; `-E` means `--encoding` |
> | Hide filenames | `-h` | `--no-filename` or `-I`; `-h` prints HELP |
> | Fixed strings | `-F` | same `-F` works |
> | Count matches | `-c` | same `-c` works |
>
> Verified the hard way 2026-08-21: `rg -hoE 'pattern'` dumped the entire help text into a parsing pipeline.

### fd — use INSTEAD of `find`

Shorter syntax = fewer syntax errors across dozens of invocations per session.

```bash
fd "\.test\."                  # find by regex
fd -e ts                       # by extension
fd -H config                   # include hidden
fd -e md . wiki/ | xargs wc -w # compose with pipes
```

### fzf — interactive filtering

Use when the user must pick from candidates:

```bash
fd -e ts | fzf                 # pick a file to edit
git branch | fzf               # pick a branch
```

### ast-grep — AST-aware search & rewrite (use INSTEAD of regex for code structure)

Text search re-derives structure every time; ast-grep parses the AST so patterns survive formatting and match by syntax, not bytes.

```bash
ast-grep -p 'console.log($A)' src/                             # find pattern ($A = metavariable)
ast-grep -p 'console.log($A)' -r 'logger.debug($A)' src/       # rewrite in place
ast-grep scan                                                  # run rule files from sgconfig.yml
ast-grep -l ts -p 'await fetch($U)'                            # filter by language
```

> [!warning] Command name changed
> The `sg` alias is **deprecated** as of ast-grep 0.45. Use `ast-grep` as the command.

Reach for `rg` for plain text/config; reach for `ast-grep` when the target is code structure (function calls, imports, JSX props).

---

## Data Analysis

### DuckDB — use INSTEAD of Python scripts or jq chains for tabular data

One SQL query replaces a script. Works directly on CSV, Parquet, JSON — no import step.

```bash
duckdb -c "SELECT status, count(*) FROM 'data.csv' GROUP BY 1 ORDER BY 2 DESC"
duckdb -c "SELECT * FROM read_json_auto('log.json') LIMIT 10"
duckdb -c "SELECT avg(amount) FROM '*.parquet'"   # glob multiple files
```

Reach for `jq` only for tiny single-key JSON lookups; reach for DuckDB for anything with grouping, joining, or aggregation.

---

## Git & APIs

### git-delta — structured diffs

Pipe diffs through it for line numbers and clean section boundaries:

```bash
git diff | delta               # side-by-side, navigable sections
git show HEAD | delta
```

> [!warning] Config matters
> Default delta config is tuned for humans/colors. For LLM consumption ensure `delta --side-by-side --line-numbers` behavior or plain-text navigation features are enabled in `~/.gitconfig`.

### xh — use INSTEAD of `curl` for API testing

Separates status, headers, and body cleanly:

```bash
xh GET https://api.example.com/users auth:"Bearer $TOKEN"
xh POST localhost:3000/api/items name=foo price:=19.99   # := for JSON numbers
xh --check-status GET https://api.example.com/health
```

Keep `curl` only where `xh` genuinely can't do the job (odd protocols, streaming).

### gh — GitHub CLI (use INSTEAD of raw REST calls / browser for PR work)

```bash
gh pr create --fill                       # PR from current branch
gh pr checks --watch                      # block on CI
gh pr view 123 --json state,reviews       # structured output, no scraping
gh issue list --label bug --limit 20
gh run view --log-failed                  # only failing logs, not the firehose
```

---

## Automation & Task Running

### watchexec — use INSTEAD of polling loops or asking the user to re-run

```bash
watchexec -e rs -- cargo test          # rerun tests on .rs changes
watchexec -w src -e py -- pytest       # watch specific dir
watchexec -r -e js -- npm test         # restart process on change
```

When iterating on code+tests, start watchexec once instead of re-running manually.

### just — use INSTEAD of Makefile when bootstrapping projects

Simpler syntax, no `.PHONY` noise:

```just
# justfile
test:
    pytest -x -q

lint:
    ruff check .

run env="dev":
    uvicorn app:main --env {{env}}
```

---

## Deterministic Verification

> [!important] Feedback-loop principle
> Any deterministic checker (semgrep, linters, type checkers, tests) beats LLM judgment alone. Wire them into loops; let the LLM fix what they flag.

### Post-edit loop (edit → verify → fix) — mandatory after any non-trivial edit

| Language | Run | Then |
|----------|-----|------|
| Python | `ruff check . && ruff format .` | `pytest` |
| TypeScript/JS | `tsc --noEmit` + Biome/ESLint | test runner |
| Go | `go vet ./... && go test ./...` (+ `staticcheck`) | — |
| Rust | `cargo check` then `clippy` | `cargo test` |

Fix everything checkers report before declaring done. Tests are the ultimate truth.

### semgrep — static analysis with real rules, not vibes

The difference between *"the AI thinks this looks like SQL injection"* and *"semgrep rule `python.django.security.injection.sql` flagged this line"* is the difference between opinion and evidence. Run it as part of security reviews and before claiming code is safe:

```bash
semgrep --config auto .                # sensible default ruleset
semgrep --config p/python .
semgrep --config p/owasp-top-ten src/
```

Security claims must cite semgrep findings, never eyeballing.

---

## Decision Table

| Task | Use | Not |
|------|-----|-----|
| Search file contents | `rg` | `grep -r` |
| Find files | `fd` | `find . -name` |
| Interactive pick | `fzf` | numbered menus |
| AST-aware code search/rewrite | `ast-grep` | regex over source |
| Analyze CSV/JSON/Parquet | `duckdb -c "SQL"` | Python scripts, long jq chains |
| View diffs | `git diff \| delta` | raw diff |
| Test HTTP endpoints | `xh` | `curl -v` |
| PR / issue / CI interaction | `gh` | raw REST, browser |
| Re-run on change | `watchexec` | sleep/poll loops |
| Project task runner | `just` | Makefile |
| Security/static review | `semgrep` | eyeballing |

## Environment Notes

- macOS (Apple Silicon), Homebrew at `/opt/homebrew/bin`
- All eleven tools verified installed 2026-08-21 (`ast-grep` 0.45.1 added; `sg` alias deprecated)
- Reproducibility tip from the source article: version-control this setup via Nix flakes or dev containers so agent tooling ships with the repo

## Source

Derived from [[wiki/sources/ai-coding-assistant-tooling|Claude Code told me what tools it needs]] (Stephane Derosiaux, 2026-03-06).
