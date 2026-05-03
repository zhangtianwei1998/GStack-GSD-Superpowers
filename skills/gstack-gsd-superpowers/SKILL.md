---
name: gstack-gsd-superpowers
description: Use when starting any feature design or implementation. Replaces default brainstorming with GStack multi-role, uses GSD to prevent context bloat in long sessions, auto-answers execution questions via GStack voting. Default workflow unless user says "use superpowers brainstorm".
---

# GStack + GSD + Superpowers Integrated Workflow

## Overview

Three-framework integration that solves three problems with vanilla Superpowers:
1. **Single-perspective brainstorm** → GStack multi-role (CEO/Eng/Designer/QA) replaces it
2. **Context bloat on long tasks** → GSD decomposes into phases, each runs in a fresh `claude -p` session
3. **Human interrupts during execution** → GStack multi-role votes automatically on any decision

**Core rule:** When brainstorm is triggered → use this workflow by default. Only fall back to `superpowers:brainstorming` if user explicitly says "use superpowers brainstorm" or "use sp brainstorm".

---

## Workflow

```
Phase 1: Design (interactive, once)
  GStack multi-role discussion
    → CEO: strategic value & trade-offs
    → Eng Manager: technical risk & cost
    → Designer: UX & interface decisions
    → QA: testability & quality gates
  → Design document output
  → User reviews and approves

Phase 2: Plan (interactive, once)
  /gsd  (GSD decomposes design doc)
    → PLAN.md  (phase definitions)
    → STATE.md (all phases: pending)
  Each phase must fit in one Claude context window

Phase 3: Execute (unattended loop)
  ~/.claude/run-phases.sh <project-path>
    loop until STATE.md shows all done:
      claude -p ~/.claude/skills/execute-phase/skill.md
        → Planning   (for this phase only)
        → Dispatch Agents  (parallel subagents)
        → TDD        (test-first per subagent)
        → Review + Verify
        ↕ Question? → GStack CEO/Eng/QA vote → continue
      → update STATE.md phase: done
```

---

## Prerequisites

Install all four tools before using this workflow:

```bash
# 1. GStack
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup

# 2. GSD
npm install -g get-shit-done-cc

# 3. RalphLoop (optional, run-phases.sh is the primary driver)
pipx install ralph-py-cli

# 4. This workflow's runtime files (from this repo)
cp skills/execute-phase/skill.md ~/.claude/skills/execute-phase/skill.md
cp scripts/run-phases.sh ~/.claude/run-phases.sh && chmod +x ~/.claude/run-phases.sh
```

Or use the included `setup` script:
```bash
./setup
```

---

## GStack Question Answering (Phase 3)

During `claude -p` execution, when a decision is needed:

**Auto-trigger** (no human needed):
- Choosing between two technical approaches
- Ambiguous requirements with multiple valid interpretations
- Architectural dependency conflicts

**Skip** (subagent decides autonomously):
- Code-level details (variable names, function decomposition)
- Single-file refactoring decisions

Decision format used in the execute-phase prompt:
1. List the question and options
2. CEO view: strategic impact, business value
3. Eng Manager view: technical risk, implementation cost
4. QA view: test coverage, quality impact
5. Pick winner, record rationale, continue

---

## Quick Reference

| Phase | Tool | Command |
|-------|------|---------|
| Brainstorm | GStack | Auto-triggered on any brainstorm request |
| Decompose | GSD | `/gsd` in Claude Code |
| Execute | run-phases.sh | `~/.claude/run-phases.sh <path>` |
| Phase execution | execute-phase skill | Loaded automatically by run-phases.sh |

---

## Red Flags

**Stop and correct if you see:**
- Brainstorm triggered → Superpowers brainstorming called (not GStack)
- All tasks running in one long Claude session (should be `claude -p` per phase)
- Claude asking user a question during Phase 3 (should auto-answer via GStack voting)
- GSD skipped → phases not written to STATE.md → run-phases.sh has nothing to loop

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping user approval after Phase 1 | Always wait for approve before running `/gsd` |
| Running execute before GSD generates STATE.md | `/gsd` first, verify STATE.md exists |
| GStack voting on implementation details | Only vote on architecture/ambiguity/trade-offs |
| Not exiting after one phase in execute-phase | `claude -p` must exit after marking phase done; run-phases.sh loops |
