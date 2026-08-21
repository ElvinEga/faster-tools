---
name: agent-tooling
description: Audit, install, verify, and maintain the CLI tooling used by AI coding agents, and generate TOOLS.md/AGENTS.md status sections. Use when setting up a new machine, checking whether tools like rg, fd, duckdb, delta, xh, watchexec, just, semgrep, or ast-grep are installed, diagnosing missing or broken CLI capabilities, updating TOOLS.md, or running an agent environment doctor.
---

# Agent Tooling

Make the local environment efficient and deterministic for coding agents
(Claude Code, OpenCode, Codex, Gemini CLI — never vendor-specific).

Goal: the **smallest useful set** of reliable tools, verified on the real
machine. Never claim a tool is installed because a doc says so.

## Principles

1. Inspect before changing; verify instead of trusting documentation.
2. Prefer project-local tooling over global; preserve existing conventions.
3. Deterministic checkers beat subjective judgment.
4. Never install without explicit authorization.
5. Never claim a command succeeded unless it was actually executed.

## Workflows

Run scripts from the repo that owns them (default: this skill's base dir,
`scripts/agent-tooling/`). All scripts are read-only except `install.sh`.

| Workflow | How | What |
|----------|-----|------|
| `verify` | `bash scripts/agent-tooling/verify.sh` | `command -v` + `--version` for every core tool; tab-separated `STATUS\ttool\tversion`; exit 1 if any missing |
| `audit` | `bash scripts/agent-tooling/audit.sh` | Read-only: OS/arch/package managers + project stack detection + classification (CRITICAL/HIGH/MEDIUM/BROKEN/REDUNDANT/PROJECT) |
| `install` | `bash scripts/agent-tooling/install.sh --yes [tool…]` | Homebrew install of named tools, or all missing core tools; re-verifies after |
| `doctor` | verify + audit together | Combined health report with prioritized recommendations |

If the scripts are absent from the current repo, fall back to doing each phase
manually with the same rules (never fabricate their output).

## Phases

1. **Inspect** — run `audit.sh`. Detect OS, arch, PATH, package managers
   (brew/bun/cargo/go/uv), Git, Docker, CI config, existing AGENTS.md /
   TOOLS.md / justfile / Makefile.
2. **Detect stack** — from lockfiles & manifests (`package.json`, `bun.lock`,
   `Cargo.toml`, `src-tauri/`, `go.mod`, `pyproject.toml`, `uv.lock`,
   `Dockerfile`…). Only recommend tools relevant to the detected stack.
3. **Classify** — CRITICAL (agent can't work well without it), HIGH (big
   effectiveness win), MEDIUM, LOW, BROKEN (installed but failing),
   REDUNDANT (duplicates a project dependency), PROJECT-SPECIFIC.
4. **Recommend** — for each: tool, purpose, reason, priority, exact install +
   verification commands. Ask before installing.
5. **Configure** — after authorization only. Non-destructive; show what
   changed. For git-delta prefer agent-navigable output
   (`--side-by-side --line-numbers`) over purely visual config.
6. **Verify** — run `verify.sh`. Check binary exists, version prints, PATH
   resolves. Run the project's own validation commands where they exist.
7. **Update docs** — see below.

## Updating TOOLS.md

- Preserve all human-written content. Write **only** inside managed regions:

  ```
  <!-- BEGIN GENERATED: agent-tooling -->
  ...
  <!-- END GENERATED: agent-tooling -->
  ```

- Keep commands accurate; remove stale claims ("all tools installed" only if
  `verify.sh` just passed). Record the verification date.
- Prefer "Preferred tools" over "All tools are installed" unless verified.
- If TOOLS.md doesn't exist, create it with the hierarchy table plus a
  generated status table. Mirror to README.md if it is a copy of TOOLS.md.

## Final report

Return these sections, populated only with actually-executed results:

- **Environment** — OS, arch, package manager
- **Installed / Missing / Broken** — from verify output
- **Recommended** — prioritized, with install+verify commands
- **Changed** — files and configs modified
- **Verification** — commands run and their results
