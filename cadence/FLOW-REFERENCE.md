# Cadence · 并行与代码 · 统一参考

[`SKILL.md`](SKILL.md) 推下来的参考之一。**只在对应分支需要时读**：要找某个 skill 读「挂载点」，一个 context 要收尾了读「阶段边界」，仓库还没有代码读「反屎山」，并行度一上去读「副作用」。（**搭环境的前置在 [`MAINTAINING.md`](MAINTAINING.md)**，不在这里。）

---

## 挂载点

每一列主用哪个 skill。**skill 的定义归 `/ask-matt`，这里只给位置** —— 想知道某个 skill 是什么，让用户跑 `/ask-matt`。

| 位置 | skill |
|---|---|
| **0 之前** | **没有 skill** —— 这一步由 cadence 自己跑：**盘点**（规格见 SKILL.md「盘点」）。产出**全量功能清单**：入口总表 ＋ 分块明细。**它是入口闸门，没盘完不许往下走** |
| **1 收 · 一份文档** | **没有 skill** —— 读 [`DOC-INTAKE.md`](DOC-INTAKE.md)：半成品稿**结构往往是好的，乱的是可信度**；沿用文档自带的记号，**别另发明一套** |
| **1 收 · 聊天记录** | `/wizard` —— 导出是**只有人能做的步骤**（开客户端、选范围、点导出），脚本固化下来别每次口头交代。筛的规则读 [`CHAT-INTAKE.md`](CHAT-INTAKE.md) |
| **1 收 · 图片语音** | `/to-questionnaire` —— 只有人能看图 / 听语音 |
| **1 判 · 面谈** | `/grilling`（采访原语）· 有仓库要留痕用 `/grill-with-docs` |
| **1 判 · 大片迷雾** | `/wayfinder` —— 出决策票，**产决策不产交付** |
| **1 判 · 纯事实题** | `/research` —— 后台 agent 查一手来源 |
| **1 判 · 答案在别人手里** | `/to-questionnaire` |
| **1 译 · 术语打架** | `/domain-modeling` —— `GLOSSARY.md` 的守卫 |
| **1 译 · 讲不清的** | `/prototype` —— 一个问题**跑起来才知道答案**时 |
| **问需求方怎么开口** | **没有 skill** —— 读 [`PROBING.md`](PROBING.md)：禁用题型 · 四个改问法 · 术语禁用表 · **三个停手信号** |
| 0 迷雾 | `/grilling`（直用） |
| 1 发现 | `/wayfinder`（迷雾大）、`/grill-with-docs`（装得下）、`/prototype`（需要可跑的答案）、`/research`（需要外部事实） |
| 1 → 2 · **闸 S** | `/to-spec`。**需求方看不懂 spec 时，闸 S 换成 `/prototype` 让他点头** —— 原型就是他的 spec |
| 1 → 2 · **闸 T** | `/to-tickets` |
| 入口门禁 | `/triage` —— 只对外部原始需求（别人提的 bug、外部请求）；**收原话收进来的话和 `/to-tickets` 的产出都不是外部原始需求，不要再 triage** |
| 3 进行中 | `/implement`，内部驱动 `/tdd`；整份 spec 一次编排用 `/implement-spec` |
| 4 待验收 | `/code-review`（**闸 V**） |
| 提 PR | `/pr` |
| 旁路 | `/diagnosing-bugs`（坏了就插队） |
| 回顾 | `/improve-codebase-architecture`（第 3 问） |
| 一次 build 之后 | `/retro` —— 改的是**环境**（指针、检查、标准），不是代码 |
| 全程词汇层 | `/domain-modeling`、`/codebase-design` |
| 阶段边界 | 见下面「阶段边界」 |
| 合并冲突 | **没有 skill** —— 按意图逐块解，**从不 `--abort`**（见下面「副作用」第 2 条） |
| 只有人能做的步骤 | `/wizard` |
| 沟通纠正 | `/wait-what` —— **不懂软件的需求方最常用的一条** |
| 写 skill / `AGENTS.md` | `/writing-for-agents` |

> 本表最后一次核对日期：____（三个月后一眼判断它过没过期）

---
## 阶段边界

**一个任务 = 一个 fresh context = 一个 PR。** 换不换上下文，是并行时最高频的调度决策。

| 什么时候 | 用哪个 |
|---|---|
| 一票做完了，要接下一票 | 新开 context —— **别在同一个 context 里接第二票**（票的自足性就是为此） |
| 票做到一半必须停（插队 / 阻塞 / 被冻结） | `/handoff` 写下交接；票留在「进行中」或退回「待开工」，别让它悬着 |
| 一个 context 里堆了多张票的讨论 | `/compact` 压掉；**压不下去就说明这一票太大**，回闸 T 拆 |
| **收原话是另一个阶段** | **收 → 译 之间换 context** —— 原料里全是闲聊和口语，会对译的推理产生噪声 |
| 要换一个 agent 立刻接手 | `/claude-handoff` |
| 只能人做的步骤（登录、开权限、点控制台） | `/wizard` 出交互脚本，人跑完再继续 |

---
## 反屎山：四层，从硬到软

| 层 | 手段 | 强制力 |
|---|---|---|
| 物理边界 | TS 用 `/setup-ts-deep-modules`（只能从入口文件进）；其他生态用等价物（Python 的 import-linter、Rust 的 crate 边界） | 机器强制 |
| 提交闸门 | `/setup-pre-commit` + `/code-review` | 机器强制 |
| 粒度纪律 | 一票 ≤ 5 文件；一票 = 一个 fresh context；一票 = 一个 PR | 靠纪律 |
| 周期清理 | 回顾第 3 问 + `/improve-codebase-architecture` | 靠节奏 |

**边界要在有代码之前立好。等屎山出来了再立，成本是十倍。**

**收原话还没跑完时仓库里没有代码** —— 那时要立的是这四层里最便宜的两层：`/setup-pre-commit` 和 `/git-guardrails-claude-code`。**等 0 行代码的仓库长到 5 千行再立，就得停下来专门做一次。**

---
## 并行 agent 的四个副作用

每个都必须管，否则并行度一上去就失控。

1. **票号撞号** —— 顺序 ID 的 tracker 在并行分支上会生成同一个号。跑 tracker 自带的体检命令（查重复票号和环依赖），或让 agent 只在同一分支串行建票、只在「进行中」并行
2. **合并冲突** —— 多分支并行时，冲突从"偶尔"变成常态。冲突落到你手上时按**意图**逐块解（两边各自想干什么），**从不 `--abort`** —— 放弃这次合并等于把两边 agent 的成果一起丢掉
3. **决策分歧** —— 每个 agent 都是 fresh context，读同一张票。所以**票必须自足**（`/to-tickets` 的 tracer bullet 规则正是为此），且**决策账本必须先于并行存在**。**需求方不懂软件时这条更凶**：同一个业务词，两个 agent 各自理解出一个意思 —— **这靠 `GLOSSARY.md` 挡，不靠 code review**
4. **多个会话同改一个仓库** —— 改仓库前先 `git status`；跑基线改用工作树或副本，`git stash` 会扫走并发会话的成果

---
