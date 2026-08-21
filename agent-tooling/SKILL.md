---
name: agent-tooling
description: Audit, set up, and diagnose the CLI environment used by AI coding agents on any OS. Use when setting up a new machine for coding agents, checking whether tools like rg, fd, fzf, duckdb, delta, xh, watchexec, just, semgrep, ast-grep, or gh are installed, diagnosing a broken agent environment, or generating TOOLS.md for a repository.
---

# Agent Tooling

Audit and optimize the local development environment for AI coding agents
(Claude Code, OpenCode, Codex, Gemini CLI — never vendor-specific).

Goal: the **smallest useful set** of reliable tools for this machine and this
project, verified by execution. Never claim a tool is installed because a doc
says so; never assume one package manager.

## Operating modes

| Mode | Trigger phrases | Behavior |
|------|-----------------|----------|
| **Audit** | "audit my agent tooling" | Read-only. No changes. |
| **Setup** | "set up this machine for AI agents" | Recommend → get approval → install → configure → verify → emit TOOLS.md |
| **Doctor** | "why is my agent environment broken?" | Diagnose PATH, versions, configs, project toolchain mismatches |

## Principles

1. Inspect before changing; verify instead of trusting documentation.
2. Detect the platform first (see `scripts/lib.sh`): macOS→Homebrew,
   Debian/Ubuntu→apt, Fedora→dnf, Arch→pacman, Alpine→apk, NixOS→nix,
   Windows→winget/choco/scoop. Never bake `brew` in as an assumption.
3. Binary names differ per distro (Debian's `fd-find` installs `fdfind`) —
   always resolve through `bin_for()` in `scripts/lib.sh`.
4. Prefer project-local tooling over global; preserve existing conventions.
5. Deterministic checkers beat subjective judgment.
6. Never install without explicit user approval for that specific list.
7. Never claim a command succeeded unless it was actually executed.

## Workflows

Run the scripts from this skill's `scripts/` directory. All are read-only
except `install.sh`.

- `verify.sh` — exists + `--version` for every core tool. TSV output
  `STATUS<TAB>tool<TAB>version`; exit 1 if anything is missing/broken.
- `audit.sh` — read-only: OS, package managers, core tools, project stack
  detection, findings classified CRITICAL/HIGH/MEDIUM/BROKEN/REDUNDANT/PROJECT.
- `doctor.sh` — verify + audit + configuration checks (delta pager, PATH
  sanity, lockfile/toolchain mismatches). Exits nonzero on failures.
- `install.sh --yes [tool…]` — install via the detected package manager;
  unsupported combos print manual instructions from `references/tools.md`;
  re-verifies when done.

If the scripts cannot run (unsupported shell, restricted host), perform each
phase manually following the same rules and say so plainly.

## Phases

1. **Inspect** — run `audit.sh`. OS, arch, PATH, package managers, Git,
   Docker, CI config, existing AGENTS.md / TOOLS.md / justfile / Makefile.
2. **Detect stack** — from manifests & lockfiles (`package.json`, `bun.lock`,
   `Cargo.toml`, `src-tauri/`, `go.mod`, `pyproject.toml`, `uv.lock`,
   `Dockerfile`…). Only recommend tools relevant to the detected stack.
3. **Classify** — CRITICAL (agent badly degraded without it), HIGH (big win),
   MEDIUM, LOW, BROKEN (installed but failing), REDUNDANT (duplicates a
   project dependency), PROJECT-SPECIFIC.
4. **Recommend** — per item: tool, purpose, reason, priority, exact install +
   verification commands for *this* platform (consult `references/tools.md`).
   Ask before installing anything.
5. **Configure** — after approval only. Non-destructive; show what changed.
   For git-delta prefer agent-navigable output (`--side-by-side
   --line-numbers`) over purely visual config.
6. **Verify** — run `verify.sh`; then run the project's own validation
   commands where they exist.
7. **Emit docs** — generate/update `TOOLS.md` from `template.TOOLS.md`,
   writing only inside the managed markers:

   ```
   <!-- BEGIN GENERATED: agent-tooling -->
   <!-- END GENERATED: agent-tooling -->
   ```

   Preserve all human-written content outside them. Record the verification
   date and the command that produced it. Say "Preferred tools", not "All
   tools are installed", unless verification just passed.

## Security

- Never pipe remote scripts into a shell (`curl … | bash`) without asking.
- Show the full install plan and get approval per tool list.
- Never modify shell rc files silently; propose diffs first.

## Final report

Populate only with actually-executed results:

- **Environment** — OS, distro, arch, package manager
- **Installed / Missing / Broken** — from verify output
- **Recommended** — prioritized, with platform-correct commands
- **Changed** — files and configs modified
- **Verification** — commands run and their results
