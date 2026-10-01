# Cadence · 参考

[`SKILL.md`](SKILL.md) 推下来的参考。**只在对应分支需要时读**：换仓库搭环境时读「反屎山」和「前置」，并行度一上去读「四个副作用」，要找某个 skill 读「挂载点」。

---

## 挂载点

每一列主用哪个 skill。**skill 的定义归 `/ask-matt`，这里只给位置** —— 想知道某个 skill 是什么，让用户跑 `/ask-matt`。

| 位置 | skill |
|---|---|
| 接项目（0 之前） | **接项目盘点**（见 SKILL.md「第 0 步」；产物落盘见 `docs/agents/direction.md`） |
| 0 迷雾 | `/grilling`（直用） |
| 1 发现 | `/wayfinder`（迷雾大）、`/grill-with-docs`（装得下）、`/prototype`（需要可跑的答案）、`/research`（需要外部事实） |
| 1 → 2 | `/to-spec`（**闸 S**）→ `/to-tickets`（**闸 T**） |
| 入口门禁 | `/triage` —— 只对外部原始需求；`/to-tickets` 的产出已经是 agent-ready，直接进「待开工」 |
| 3 进行中 | `/implement`，内部驱动 `/tdd` |
| 4 待验收 | `/code-review`（**闸 V**） |
| 旁路 | `/diagnosing-bugs`（坏了就插队） |
| 回顾 | `/improve-codebase-architecture`（第 3 问） |
| 全程词汇层 | `/domain-modeling`、`/codebase-design` |
| 阶段边界 | `/handoff`、`/clear`、`/compact`、subagent —— 并行时是高频调度决策，读 `PHASE-BOUNDARIES.md` |
| 并行冲突 | `/resolving-merge-conflicts` |
| 只有人能做的步骤 | `/wizard` |
| 沟通纠正 | `/wait-what` |

> 本表最后一次核对日期：____（三个月后一眼判断它过没过期）

---

## 反屎山：四层，从硬到软

| 层 | 手段 | 强制力 |
|---|---|---|
| 物理边界 | TS 用 `/setup-ts-deep-modules`（只能从入口文件进）；其他生态用等价物（Python 的 import-linter、Rust 的 crate 边界） | 机器强制 |
| 提交闸门 | `/setup-pre-commit` + `/code-review` | 机器强制 |
| 粒度纪律 | 一票 ≤ 5 文件；一票 = 一个 fresh context；一票 = 一个 PR | 靠纪律 |
| 周期清理 | 回顾第 3 问 + `/improve-codebase-architecture` | 靠节奏 |

**边界要在有代码之前立好。等屎山出来了再立，成本是十倍。**

---

## 并行 agent 的四个副作用

每个都必须管，否则并行度一上去就失控。

1. **票号撞号** —— 顺序 ID 的 tracker 在并行分支上会生成同一个号。跑 `backlog doctor`（查重复票号和环依赖），或让 agent 只在同一分支串行建票、只在「进行中」并行
2. **合并冲突** —— `/resolving-merge-conflicts` 从"偶尔用"升级为基础设施。它按**意图**逐块解决，且从不 `--abort`
3. **决策分歧** —— 每个 agent 都是 fresh context，读同一张票。所以**票必须自足**（`/to-tickets` 的 tracer bullet 规则正是为此），且**决策账本必须先于并行存在**
4. **多个会话同改一个仓库** —— 改仓库前先 `git status`；跑基线改用工作树或副本，`git stash` 会扫走并发会话的成果

---

## 保持活性

- 票是唯一真相源，看板是**视图**。**列的语义由票定义，工具跟着它走**
- **决策账本只增不删。** 本仓库账本 = `.scratch/wayfinder-vibe-distill/map.md` §`Decisions so far`；`docs/agents/flow.md` 和 `docs/agents/direction.md` 只放指针，**只此一份**
- **账本是防止下一个 agent（或三个月后的你）推翻已定决策的唯一机制** —— 它一旦变成两份，这个机制就失效了
- 踩到的每个坑 → 写回本 skill 或 `docs/agents/flow.md`

---

## 前置

`/setup-matt-pocock-skills` 产出的 `docs/agents/issue-tracker.md` 必须已存在 —— `/code-review` 依赖它去 tracker 取 spec。然后跑 `/setup-cadence` 搭出本层的仓库配置。

**怎么验证这套东西还转得动**：一个周期后回头量三个数 —— 待验收最老年龄、返工次数、待批准最老等了几天。凡是量不出来的段落，就该拆掉。
