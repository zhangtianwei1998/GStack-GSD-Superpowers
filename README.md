# GStack + GSD + Superpowers

**Three-framework integration for Claude Code** that combines:
- **[GStack](https://github.com/garrytan/gstack)** — multi-role brainstorming (CEO/Eng/Designer/QA) + auto question answering
- **[GSD](https://github.com/gsd-build/get-shit-done)** — context management via phase decomposition
- **[Superpowers](https://github.com/obra/superpowers)** — TDD execution workflow (Planning → Dispatch Agents → TDD → Review)

## The Problem

Vanilla Superpowers has three pain points on substantial tasks:

1. **Single-perspective brainstorm** — misses angles that different roles would catch
2. **Context bloat** — long executions degrade quality as context fills up
3. **Human interrupts** — execution stops whenever Claude needs a decision

## The Solution

```
Brainstorm  →  GStack multi-role design doc  →  user approves
Plan        →  GSD decomposes into phases    →  PLAN.md + STATE.md
Execute     →  run-phases.sh loops claude -p →  one fresh session per phase
                 each phase: full Superpowers workflow
                 questions: GStack auto-votes, no human needed
```

## Quick Start

```bash
# Install this workflow
git clone https://github.com/zhangtianwei1998/GStack-GSD-Superpowers
cd GStack-GSD-Superpowers
./setup

# Install prerequisites (if not already done)
git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
npm install -g get-shit-done-cc
pipx install ralph-py-cli
```

## Usage

Once installed, the workflow triggers automatically:

1. **Brainstorm** — any feature request → GStack multi-role discussion → design doc → you approve
2. **Plan** — run `/gsd` in Claude Code → PLAN.md + STATE.md generated
3. **Execute** — run `~/.claude/run-phases.sh <project-path>` → unattended, overnight

## Files

```
skills/
  gstack-gsd-superpowers/
    SKILL.md          # Main workflow skill (auto-loaded by Claude Code)
  execute-phase/
    skill.md          # Per-phase execution prompt for claude -p
scripts/
  run-phases.sh       # Unattended phase loop driver
setup                 # One-command installer
```

## How It Works

**Phase 1 (Design):** GStack's 23 expert roles discuss the feature. You get a design doc with CEO strategy, Eng risk analysis, Designer UX decisions, and QA quality gates — all in one pass. You review and approve.

**Phase 2 (Plan):** GSD reads the design doc and decomposes it into phases sized to fit within one Claude context window. State is written to `STATE.md`.

**Phase 3 (Execute):** `run-phases.sh` loops `claude -p` — each call starts a fresh Claude session, reads `STATE.md` for the next pending phase, runs the full Superpowers workflow (Planning → Dispatch Agents → TDD → Review + Verify), marks the phase done, and exits. Decisions that arise are auto-resolved by simulating GStack's CEO/Eng/QA perspectives inline.

## License

MIT
