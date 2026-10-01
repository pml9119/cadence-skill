---
name: setup-cadence
description: "在仓库里搭出 cadence 流动层：AGENTS.md 硬规则块、docs/agents/flow.md、决策账本、流动度量脚本。首次使用 cadence 前跑一次。"
disable-model-invocation: true
---

# Setup Cadence

搭出 `cadence` 假设的仓库级配置。

这是 prompt 驱动的 skill，不是确定性脚本。探查、呈现、确认，然后才写。

## 0. 前置

**`docs/agents/issue-tracker.md` 必须已存在。** 不存在 → 让用户先跑 `/setup-matt-pocock-skills`，然后**停在这里**。

理由：`/code-review` 依赖那个文件去 tracker 取 spec。cadence **不定义** tracker，它只读。

## 1. 探查

读现状，别假设：

- `docs/agents/issue-tracker.md`：用的哪个 tracker？本地 markdown，还是 GitHub / GitLab？
- `AGENTS.md` 和 `CLAUDE.md`：哪个存在？已有 `## Agent skills` 块吗？
- `docs/agents/flow.md`：已有本 skill 的产出吗？
- **决策账本**：仓库里是否**已有权威决策源**？（wayfinder 的 `map.md`、`DECISIONS.md`、`docs/adr/` 等）—— 这决定第 3 步写不写账本
- `CONTEXT.md`、`GLOSSARY.md`：存在吗？
- 是 git 仓库吗？——度量脚本依赖 git 历史才能算周期时间
- tracker 目录里现在有几张票？分属哪些状态？

## 2. 问，一个区块一个答案

**区块 A：并行上限 N。**

> 你每天能**真正验收**几个 PR？（推荐：**3**）
>
> 这个数字就是并行 agent 数的上限。它不是"能跑多少"，是"你验得过来多少"。

如果用户报的数远大于他们实际的评审时间，直接指出——这个数字填大了，整套框架的刹车就失效了。

**区块 B：验收警报阈值。**

> 待验收最老一张超过几天就该停手？（推荐：**2 天**）

**区块 C：回顾时间。**

> 每周固定哪个时段？（推荐：**周五，30 分钟**）

**区块 D：仅当不是 git 仓库。**
度量脚本要 git 历史。让用户先 `git init`，或明确同意跳过度量脚本。

## 3. 写

用本 skill 目录里的种子文件作为起点：

- [agents-block.md](./agents-block.md) → 并入 `AGENTS.md`（若 `CLAUDE.md` 已存在则用后者）的 `## Agent skills` 块。**已有该块就原地更新，不要重复追加**；不要覆盖用户对周边段落的手改
- [flow.md](./flow.md) → `docs/agents/flow.md`，把 N、阈值、回顾时间填进去
- [DECISIONS.md](./DECISIONS.md) → **仅当仓库没有权威决策源时**才写到仓库根。已有（wayfinder `map.md`、ADR 目录、别的账本）→ **不要写**，改为在 `flow.md` 里指明它在哪。两份账本必然漂移
- [flow-metrics.mjs](./flow-metrics.mjs) → 拷到**该仓库约定的工具目录**（先读 `AGENTS.md` 和现有目录结构再定，常见 `scripts/` 或 `tools/`），类 Unix 上 `chmod +x`

`selftest.ps1` 不是种子文件。它在一个临时 git 仓上验证 `flow-metrics.mjs` 的解析与统计（造票、改状态、提交，然后核对周期时间和待验收年龄）。怀疑度量数字不对时跑它。
**它刻意只用 ASCII 注释**：Windows PowerShell 5.1 会把无 BOM 的 UTF-8 文件按 ANSI/GBK 解码，中文注释的字节会吞掉下一行代码。改它时保持 ASCII。

`docs/agents/triage-labels.md` 的归属**取决于前置是否跑过**：

- **`/setup-matt-pocock-skills` 已跑过 → 不要写**，那是它的所有权
- **没跑过（本 skill 被单独使用）→ 你要补写**，否则 `/triage` 没有标签词汇可用

两种情况都只允许存在**一份**。

## 4. 收尾

告诉用户三件事：

1. **从哪开始**：迷雾大 → `/wayfinder`；一个 session 装得下 → `/grill-with-docs`
2. **度量怎么跑**：给出**实际落地路径**（`node <你选的目录>/flow-metrics.mjs`，加 `--json` 拿结构化输出）
3. **三道闸门**分别是什么，以及它们**必须由人**过

## D0 顺序

| 顺序 | 做什么 | 为什么是这个顺序 |
|---|---|---|
| 1 | `/setup-matt-pocock-skills` | `/code-review` 依赖它产出的 `issue-tracker.md` |
| 2 | `/setup-cadence` | 本 skill |
| 3 | `/setup-pre-commit` + `/git-guardrails-claude-code` | 提交闸门要在有代码之前立好 |
| 4 | `/setup-ts-deep-modules`（TS 项目） | 物理边界，同上 |
| 5 | `/wayfinder` | 真正开始 |

第 3、4 步提前做的理由：**边界要在有代码之前立好。等屎山出来了再立，成本是十倍。**
