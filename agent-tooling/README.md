# Agent Tooling

[![skills.sh](https://skills.sh/b/OWNER/REPO)](https://skills.sh/OWNER/REPO)

A reusable Agent Skill for **auditing and optimizing the CLI environment for AI coding agents**.

It helps agents discover available tools, identify missing or broken tooling, understand the project stack, and recommend a better development environment.

Works with agents such as **Codex, Claude Code, Gemini, OpenCode, Cursor, and more**.

## Install

Using the `skills` CLI:

```bash
npx skills add OWNER/REPO
```

Replace `OWNER/REPO` with this repository's GitHub path.

Prefer a symlink so updates propagate (see [references/agents.md](references/agents.md) for per-agent paths):

```bash
ln -s "$PWD" ~/.agents/skills/agent-tooling   # OpenCode auto-scans this
ln -s "$PWD" ~/.claude/skills/agent-tooling   # Claude Code
```

After installing, ask your agent:

```text
Audit my agent tooling environment.
```

Or:

```text
Set up my machine for AI coding agents.
```

No agent needed — the scripts run standalone:

```bash
bash scripts/verify.sh          # STATUS<TAB>tool<TAB>version; exit 1 if gaps
bash scripts/audit.sh           # read-only machine + project-stack audit
bash scripts/doctor.sh          # configs, PATH, toolchain mismatches
bash scripts/install.sh --yes   # approval-gated installer
```

## What it checks

* 🔎 Search & file discovery — `rg`, `fd`, `fzf`
* 🧠 AST-aware search & rewrite — `ast-grep`
* 📊 Data analysis — `duckdb`
* 🔀 Git — `git-delta`, `gh`
* 🌐 APIs — `xh`
* ⚡ Automation — `watchexec`, `just`
* 🛡️ Static analysis — `semgrep`
* 📦 Package managers and development environments

Cross-platform: Homebrew, apt, dnf, pacman, apk, nix, winget, choco, and scoop are detected at runtime — nothing is assumed. The skill **doesn't blindly install everything**. It first audits the environment and project, then recommends relevant improvements.

## Example

```text
Agent Tooling Doctor

✓ ripgrep        ✓ duckdb         ✓ just
✓ fd             ✓ git-delta      ✓ semgrep
✓ fzf            ✓ xh             ✓ ast-grep

Project
✓ Bun
✓ TypeScript
✓ Rust
✓ Tauri

Recommendations
! Configure git-delta for agent-friendly diffs
! Add a repository task runner
```

## `TOOLS.md`

The skill can create or maintain a `TOOLS.md` file describing the preferred tooling and commands for AI agents working in a repository.

This keeps **machine/tooling knowledge separate from `AGENTS.md`**, which can focus on project-specific behavior and instructions.

## Learn more

* [skills.sh](https://www.skills.sh) — Discover skills
* [Skills documentation](https://www.skills.sh/docs) — Getting started
* [Skills CLI documentation](https://www.skills.sh/docs/cli) — Install and manage skills
* [Skills GitHub repository](https://github.com/vercel-labs/skills) — CLI source

## Security

Review a skill before installing it on a machine you care about. skills.sh performs security audits, but does not guarantee the security or quality of every listed skill. Nothing installs without an explicit `--yes`; config changes are proposed before being made.

## License

MIT
