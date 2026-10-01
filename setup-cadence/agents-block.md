### Flow

六列看板：`fog → discovery → ready → building → verifying → done`。硬规则：

- **并行 agent ≤ 3**（真实数字在 `docs/agents/flow.md`）
- **票不能跳列。** spec（闸 S）和 tickets（闸 T）两道闸门**必须由人过**
- **一个任务 = 一个 fresh context = 一个 PR**，一票不超过 5 个文件
- 待验收最老一张超过警报阈值（默认 2 天）→ **停止启动新 agent**，只做验收
- **决策账本在 `<位置>`。仓库已有权威决策源就用它，不要新建第二份**

每一步用哪个 skill：读 `cadence`。那些 skill 各是什么：跑 `/ask-matt`。See `docs/agents/flow.md`.
