# cadence · 节奏

> **Scrumban 式的项目调度层。** 它同时扮演**产品经理**（做什么、先做哪个）和**项目经理**（几个在做、卡在哪、什么时候算完）。

它架在 matt pocock 的工程 skills 之上：那些 skills 说每一步**怎么做**（采访、spec、票、实现、评审），cadence 说**做什么、什么时候做、同时做几个**。

**它挡的失败是「没人读过的代码山」。** 它假设一个人同时管方向又管进度 —— 这里的"团队"就是你和 N 个 agent。

当前版本：**v6**（版本历史即 git 提交历史）。

---

## 它借了什么，去了什么

**从 Scrumban 借来三件**：**看板**（六列，票不跳列）· **在制品上限**（N）· **拉动**（「待开工」少于阈值才从「发现」拉票）。

**去掉**：时间盒、承诺、故事点、速度。

**加上**：三类 cadence 事件 —— 每日看一个数、每周回顾、触发式补充。

---

## 全链路

```
方向层 ── 决定做什么
   接项目盘点（第 0 步） → 需求：模糊进迷雾 · 改动走变更（在制品不动）
                              │
                         优先级（D1） → 里程碑（D2）
                              │
          ═══ 交界 ═══ 交出一张排好序的候选清单
                              │
流动层 ── 决定怎么流动
   0 迷雾 → 1 发现 ─闸 S→闸 T→ 2 待开工 → 3 进行中 → 4 待验收 ─闸 V→ 5 已完成
                                         在制品 ≤ N           （你裁决）
```

**两层职责分开**，各自落盘：

| 层 | 回答 | 落盘在 |
|---|---|---|
| **方向层** | 先做哪个 · 到哪算到 · 怎么讲给人听 | `docs/agents/direction.md` |
| **流动层** | 同时跑多少 · 卡在哪 · 谁验收 · 什么时候复盘 | `docs/agents/flow.md` |

**三道闸门必须由人过**：闸 S、闸 T（从「发现」放行）、闸 V（验收）。

---

## 本仓库装了什么

这是**两个配套 skill**：

| 目录 | skill | 作用 |
|---|---|---|
| `cadence/` | `cadence` | 调度层本体：方向层（第 0 步盘点、需求管理、D1 优先级、D2 里程碑、D3 汇报、D4 审批）+ 流动层（在制品上限、六列看板、三道闸门、全局依赖表、节奏、度量） |
| `setup-cadence/` | `setup-cadence` | 安装器：在具体仓库里搭出 cadence 假设的仓库级配置。**首次使用 cadence 前跑一次** |

`setup-cadence` 标了 `disable-model-invocation: true` —— 它是给人主动调用的，不会被模型自行触发。

`cadence/FLOW-REFERENCE.md` 是按分支推出的参考文件：挂载点、阶段边界、反屎山四层、并行 agent 的四个副作用、保持活性、前置。

---

## 安装

把两个目录放进你的 skills 目录，**目录名保持 `cadence` 与 `setup-cadence`**（skill 名由目录里的 `SKILL.md` frontmatter 决定）：

```bash
git clone https://github.com/pml9119/cadence-skill.git
cp -r cadence-skill/cadence cadence-skill/setup-cadence ~/.agents/skills/
```

Claude Code 的 skills 目录是 `~/.claude/skills/`；用哪个取决于你的 agent 运行时。Windows 上对应 `C:\Users\<你>\.agents\skills\`。

---

## 首次使用顺序（D0）

| 顺序 | 做什么 | 为什么是这个顺序 |
|---|---|---|
| 1 | `/setup-matt-pocock-skills` | `/code-review` 依赖它产出的 `docs/agents/issue-tracker.md` |
| 2 | `/setup-cadence` | 本仓库的安装器 |
| 3 | `/setup-pre-commit` + `/git-guardrails-claude-code` | 提交闸门要在有代码之前立好 |
| 4 | `/setup-ts-deep-modules`（TS 项目） | 物理边界，同上 |
| 5 | `/wayfinder` | 真正开始 |

`/setup-cadence` 的前置是 `docs/agents/issue-tracker.md` **必须已存在** —— cadence **不定义** tracker，它只读。

第 3、4 步提前做的理由：**边界要在有代码之前立好。等屎山出来了再立，成本是十倍。**

---

## 度量怎么跑

`setup-cadence/flow-metrics.mjs` 会被拷到你仓库约定的工具目录（常见 `scripts/` 或 `tools/`），它靠 git 历史算周期时间和待验收年龄：

```bash
node scripts/flow-metrics.mjs
node scripts/flow-metrics.mjs --json   # 结构化输出
```

`setup-cadence/selftest.ps1` 不是种子文件：它在一个临时 git 仓上验证 `flow-metrics.mjs` 的解析与统计。怀疑度量数字不对时跑它。

> **改 `selftest.ps1` 时保持 ASCII 注释**：Windows PowerShell 5.1 会把无 BOM 的 UTF-8 文件按 ANSI/GBK 解码，中文注释的字节会吞掉下一行代码。

---

## 一条纪律

**同一条规矩只写一遍。** 重述会让两处各自漂移。要知道某个工程 skill 是什么，让你的 agent 跑 `/ask-matt`。
