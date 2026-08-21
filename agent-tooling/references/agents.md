# Agent Compatibility

Where this skill's `SKILL.md` must live so each agent auto-loads it.
The package is a plain folder — copy it, or symlink it, into any of these.

| Agent | Personal (all projects) | Per-project |
|-------|--------------------------|-------------|
| OpenCode | `~/.config/opencode/skills/agent-tooling/` or `~/.agents/skills/agent-tooling/` (auto-scanned) | `.opencode/skills/agent-tooling/` |
| Claude Code | `~/.claude/skills/agent-tooling/` | `.claude/skills/agent-tooling/` |
| Codex | No native skill loader — add `AGENTS.md` pointing at this folder's SKILL.md | same |
| Gemini CLI | No native skill loader — reference from `GEMINI.md` context file | same |

## Install (symlink so updates propagate)

```bash
git clone <this-repo> && cd agent-tooling

# OpenCode
mkdir -p ~/.agents/skills && ln -s "$PWD" ~/.agents/skills/agent-tooling

# Claude Code
mkdir -p ~/.claude/skills && ln -s "$PWD" ~/.claude/skills/agent-tooling
```

Restart the agent after registering; skill lists load at startup.

## Design rules that keep it portable

- `SKILL.md` frontmatter carries only standard fields (`name`, `description`)
  — no vendor-specific metadata.
- Instructions never assume a vendor's tool names or permission model.
- All machine interaction goes through `scripts/*.sh`, which are plain bash
  and degrade gracefully when a platform is unsupported.
- Outputs are plain text/TSV/markdown — parseable by any agent.
