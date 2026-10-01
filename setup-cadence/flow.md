# Flow

本仓库的 cadence 配置。

**过程本身**在 `cadence` skill 里；这里只放**本仓库的具体值**。改这里不用改 skill。

## Tracker

<!-- 由 /setup-cadence 填写：用哪个 tracker、票放在哪个目录、建/查/改票的命令。
     若 docs/agents/issue-tracker.md 已写清，这里只写差异。 -->

## 并行上限

N = 3

## 验收警报

「待验收」最老一张超过 **2 天** → 停止启动新 agent，只做验收。

## 状态值

| 列 | 状态值 |
|---|---|
| 迷雾 | `fog` |
| 发现 | `discovery` |
| 待开工 | `ready` |
| 进行中 | `building` |
| 待验收 | `verifying` |
| 已完成 | `done` |

看板是**视图**，票是唯一真相源。不要为了迁就某个工具去改这六列的语义。

票面 `Status:` 同时承载 **triage role**（`needs-triage` / `ready-for-human` …），见 `docs/agents/triage-labels.md`。度量脚本按最近的一列归类它。

## 三道闸门

闸 S（`/to-spec` 后）· 闸 T（`/to-tickets` 后）· 闸 V（`/implement` 提交后），**三道都由人过**。

通过标准见 `cadence` skill，这里不重述。本仓库的差异：<填这里，没有就写「无」>

## 节奏

- **补充**：`ready` 少于 3 张时，才从 `discovery` 拉新票（触发式，非迭代）
- **每日**：只看一个数——「待验收」最老一张的年龄
- **回顾**：每周五，30 分钟。四问见 `cadence` skill（第 1 问必须回答「里程碑 vs 实际」）

## 决策账本

**位置：`<填这里>`** —— 例如 `.scratch/<effort>/map.md` 的 Decisions 段、仓库根 `DECISIONS.md`、或 `docs/adr/`。

填仓库**已有**的权威决策源。没有才新建 `DECISIONS.md`。

## 度量

```bash
node <工具目录>/flow-metrics.mjs
node <工具目录>/flow-metrics.mjs --json
node <工具目录>/flow-metrics.mjs --days 60
```

数据直接从 `git log` 里票文件的 `status:` 变更算出，不需要额外遥测。
