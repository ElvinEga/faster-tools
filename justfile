# Agent tooling workflows (see agent-tooling/SKILL.md)
default:
    @just --list

# Verify all core agent tools are installed and runnable
verify:
    bash agent-tooling/scripts/verify.sh

# Read-only audit of environment + project stack
audit:
    bash agent-tooling/scripts/audit.sh

# Diagnose environment, configs, and toolchain mismatches
doctor:
    bash agent-tooling/scripts/doctor.sh

# Install missing core tools (or named ones): just install / just install duckdb
install *tools:
    bash agent-tooling/scripts/install.sh --yes {{tools}}
