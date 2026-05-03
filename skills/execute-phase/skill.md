# Execute Phase Skill

你正在执行 GSD 分解后的一个独立 phase。每次调用本 skill，只执行一个 phase，执行完毕即退出。

## 1. 读取上下文

首先读取以下文件：
- `PLAN.md` — 整体计划和所有 phases 的定义
- `STATE.md` — 当前执行状态，找到第一个状态为 `pending` 的 phase

若 STATE.md 中所有 phase 均为 `done`，输出 "ALL_PHASES_COMPLETE" 并退出。

## 2. 执行当前 Phase（Superpowers 完整工作流）

按以下顺序完成当前 phase 的全部工作：

### Planning
为本 phase 制定具体执行计划：
- 列出本 phase 包含的所有子任务
- 确定各子任务的依赖关系和并行度
- 确定每个子任务的成功标准

### Dispatch Agents
调用 superpowers:dispatching-parallel-agents，将独立子任务并行派发给 subagents。

### TDD
每个 subagent 使用 superpowers:test-driven-development：先写测试，运行确认失败，写最小实现，运行确认通过，提交。

### Review + Verify
调用 superpowers:requesting-code-review 和 superpowers:verification-before-completion，验收所有 subagent 的输出。

## 3. 问题处理（无需人工介入）

执行过程中若遇到需要决策的问题（方案取舍、模糊需求、架构冲突），不要停下来等待用户：

1. 列出问题和各选项
2. 从 CEO 视角分析：战略影响和业务价值
3. 从 Eng Manager 视角分析：技术风险和实现成本
4. 从 QA 视角分析：测试覆盖和质量影响
5. 综合三个视角，选出最优方案，记录决策依据
6. 继续执行

## 4. 完成处理

phase 内所有任务通过验收后：
- 更新 STATE.md，将本 phase 状态改为 `done`
- 输出 "PHASE_N_COMPLETE: <phase名称>"
- 退出（不要自动执行下一个 phase）
