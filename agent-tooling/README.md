# agent-tooling

A portable [Agent Skill](https://skills.sh) that audits, sets up, and
diagnoses the CLI environment used by AI coding agents — on any OS, for any
agent (Claude Code, OpenCode, Codex, Gemini CLI).

> Install once → works everywhere. The skill is the orchestration layer;
> `TOOLS.md` is its output.

## What it does

| Mode | Say | Effect |
|------|-----|--------|
| **Audit** | "Audit my agent tooling" | Read-only report: environment, stack, missing/broken/redundant tools |
| **Setup** | "Set up this machine for AI coding agents" | Recommend → approval → install → configure → verify → emit `TOOLS.md` |
| **Doctor** | "Why is my agent environment broken?" | Diagnose PATH, versions, configs, lockfile/toolchain mismatches |

Core tools it manages: `rg`, `fd`, `fzf`, `jq`, `duckdb`, `delta`, `xh`,
`watchexec`, `just`, `semgrep`, `ast-grep`, `gh`.

Cross-platform: Homebrew / apt / dnf / pacman / apk / nix / winget / choco /
scoop are detected at runtime; distro binary differences (`fdfind`) are
handled. No package manager is assumed.

## Install

```bash
git clone <this-repo> && cd agent-tooling

# OpenCode (auto-scans ~/.agents/skills)
mkdir -p ~/.agents/skills && ln -s "$PWD" ~/.agents/skills/agent-tooling

# Claude Code
mkdir -p ~/.claude/skills && ln -s "$PWD" ~/.claude/skills/agent-tooling
```

Restart the agent. Codex/Gemini users: point `AGENTS.md`/`GEMINI.md` at
`SKILL.md` (see `references/agents.md`).

## Standalone usage (no agent required)

```bash
bash scripts/verify.sh          # STATUS<TAB>tool<TAB>version per tool; exit 1 if gaps
bash scripts/audit.sh           # read-only environment + project-stack audit
bash scripts/doctor.sh          # verify + config + toolchain mismatch diagnosis
bash scripts/install.sh --yes   # install all missing core tools (asks via --yes)
```

## Layout

```
SKILL.md              the skill (frontmatter + instructions)
scripts/lib.sh        platform detection shared by all scripts
scripts/verify.sh     deterministic tool verification
scripts/audit.sh      read-only machine + stack audit
scripts/install.sh    approval-gated installer
scripts/doctor.sh     full diagnosis
references/tools.md   per-OS package catalog + gotchas
references/agents.md  where each agent loads skills from
template.TOOLS.md     output template with managed markers
```

## Security

- Nothing installs without an explicit `--yes` / user approval.
- No `curl | bash`; manual fallbacks are documented instead.
- Config changes (e.g. git pager) are proposed as diffs first.
- Scripts are read-only except `install.sh`.

## Validation

CI runs shellcheck, bash syntax checks, SKILL.md metadata checks, and a
smoke test on every push (see `.github/workflows/validate.yml`).

## License

MIT — see [LICENSE](LICENSE).
