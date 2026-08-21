# Agent tooling workflows (see skills/agent-tooling/SKILL.md)
default:
    @just --list

# Verify all core agent tools are installed and runnable
verify:
    bash scripts/agent-tooling/verify.sh

# Read-only audit of environment + project stack
audit:
    bash scripts/agent-tooling/audit.sh

# Install missing core tools (or named ones): just install / just install duckdb
install *tools:
    bash scripts/agent-tooling/install.sh --yes {{tools}}

# Full health check: verify + audit
doctor: verify audit
