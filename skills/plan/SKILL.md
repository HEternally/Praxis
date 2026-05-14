---
name: plan
description: Use after think has produced a verifiable goal and named constraints, when the next step is multi-action work. Decomposes the goal into an ordered task sequence where each task has independent acceptance. Not for fuzzy or unverifiable goals — those go to think first.
---

## When to invoke
- think 已产出"可验证目标 + 命名约束",但下一步显然不是单一动作
- 用户给出复合需求(包含 ≥3 个独立可验证产物)
- 即将调 write-code / debug,工作明显需要拆步骤

## Inputs required
- 一句话可验证目标
- 命名约束列表
- 已知的资源限制(时间、人力、技术栈)
- (可选)对应 think 文件路径: `docs/praxis/think/<slug>.md` — 如有,plan 直接消费目标 + 约束,不重复问

## Goal
产出有顺序的任务序列,每个任务有独立产物和独立验收方式,使下一步可以按任务粒度交给执行者(人或 skill)而不需要二次澄清。

## Hard constraints
- 不写代码、不动业务代码;**归档到 `docs/praxis/plan/` 是 skill 自带行为**
- 每个任务必须有独立验收方式(怎么知道这一项做完了),没有就拆得更细
- 任务数 < 3 不出 plan(直接说"不需要 plan");任务数 > 12 必须分批,只列前 ≤ 12 个 + 显式写"剩余分批"
- 不为每个任务写实现细节(那是 write-code 的事),只写"做什么 + 验收"。**即使用户明确要求实现细节(JSX 结构 / props 类型 / validation schema / import 语句),也必须拒绝并说"实现细节由 write-code 出"**
- 目标不可验证时(如"更可靠""更好用""体验更好")拒绝出 plan,推回 think 先把目标变可验证

## Output contract
- 编号任务列表(顺序敏感)
- 每个任务: 一句话**产物** + 一句话**验收**
- 任务间显式标注**依赖**: 用 "Task N 依赖 Task M" 格式,无依赖明确写"无依赖"
- 一行**风险与未知**: 必须有 ≥ 1 条,即使是 "TBD" 也写出,不省略

## Artifact
默认归档到 `docs/praxis/plan/<slug>.md`,slug 沿用 think 的 slug(如有上游 think 文件),否则由 goal 新生成。

文件结构:
- frontmatter: `skill: plan` / `slug` / `date` / `goal` / `think: <think 文件路径,如有>`
- body: Output contract 的全部内容(任务列表 + 依赖 + 风险与未知)

降级: `docs/praxis/` 不可写时,只 chat 输出,末尾标"未能归档 (原因: X)"。
防覆盖: `docs/praxis/plan/<slug>.md` 已存在时,改写到 `<slug>--YYYYMMDD-HHmm.md`。

## Gotchas

| What happened | Rule |
|---|---|
| 单一动作("改一个常量")拆成 3 步("改文件 / 跑测试 / commit") | 任务 < 3 不出 plan;改文件单步 = 不需要 plan,直接 write-code |
| 50 组件迁移一次性列了 18 个任务 | 任务数 > 12 必须分批,只列前 ≤ 12 个 + 显式说 "剩余分批" |
| 用户要 "具体 JSX 结构 / props 类型",plan 给了代码片段 | 实现细节由 write-code 出;plan 任务只写 "做什么 + 验收",不写代码 |
| 输入 "让 API 更可靠" 这种不可验证目标,still 出了 plan | 目标不可验证时拒绝出 plan,推回 think 先把目标变可验证 |
