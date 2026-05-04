#!/bin/bash
# run-phases.sh — 循环调用 claude -p 执行 GSD 分解的各 phases
# 用法：~/.claude/run-phases.sh [项目路径]
#
# 依赖：
#   - 项目根目录下存在 PLAN.md 和 STATE.md（由 GSD 生成）
#   - ~/.claude/skills/execute-phase/skill.md 已创建

set -e

PROJECT_DIR="${1:-.}"
EXECUTE_PHASE_PROMPT="$HOME/.claude/skills/execute-phase/skill.md"
MAX_ITERATIONS=20
iteration=0

# Lockfile：防止同一项目并发执行
# 用项目绝对路径的 hash 作为 lockfile 名，不同项目互不影响
ABS_PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"
LOCKFILE="/tmp/run-phases-$(echo "$ABS_PROJECT_DIR" | tr '/' '-' | tr -d ' ').lock"

if [ -f "$LOCKFILE" ]; then
  EXISTING_PID=$(cat "$LOCKFILE" 2>/dev/null)
  if kill -0 "$EXISTING_PID" 2>/dev/null; then
    echo "ERROR: run-phases.sh is already running for this project (PID $EXISTING_PID)"
    echo "If this is stale, delete it: rm $LOCKFILE"
    exit 1
  else
    echo "WARNING: Stale lockfile found (PID $EXISTING_PID no longer running). Removing."
    rm -f "$LOCKFILE"
  fi
fi

echo $$ > "$LOCKFILE"
trap "rm -f '$LOCKFILE'" EXIT

echo "=== run-phases.sh started ==="
echo "Project: $ABS_PROJECT_DIR"
echo "PID: $$  Lockfile: $LOCKFILE"
echo "Max iterations: $MAX_ITERATIONS"

cd "$PROJECT_DIR"

while [ "$iteration" -lt "$MAX_ITERATIONS" ]; do
  iteration=$((iteration + 1))
  echo ""
  echo "--- Iteration $iteration ---"

  # 检查是否所有 phase 已完成
  if grep -q "ALL_PHASES_COMPLETE" STATE.md 2>/dev/null; then
    echo "All phases complete. Exiting."
    exit 0
  fi

  pending=$(grep -c "pending" STATE.md 2>/dev/null || echo "0")
  if [ "$pending" -eq 0 ]; then
    echo "No pending phases found in STATE.md. All done."
    exit 0
  fi

  echo "Pending phases: $pending"
  echo "Starting claude -p for next phase..."

  # 用 claude -p 执行下一个 phase
  output=$(claude -p "$(cat "$EXECUTE_PHASE_PROMPT")" --output-format text 2>&1)
  echo "$output"

  # 检查输出中是否有完成信号
  if echo "$output" | grep -q "ALL_PHASES_COMPLETE"; then
    echo "All phases complete. Exiting."
    exit 0
  fi

done

echo "Max iterations ($MAX_ITERATIONS) reached. Check STATE.md for remaining phases."
exit 1
