---
name: think
description: Use when starting any non-trivial task and the goal is fuzzy. Turns a rough idea into a verifiable goal, named constraints, and exposed assumptions before any other skill (write-code, debug, design-ui, write-prose, learn) runs.
---

## When to invoke
- 用户说"我想做 X"但没说怎么判断 X 算做完
- 输入有动词但没有验收方式
- 一个需求能被合理解释成 2 种以上的东西
- 紧接着要调 write-code / debug / design-ui / write-prose / learn,但目标还说不清

## Inputs required
- 一句话粗想法或需求(允许模糊)
- 用户能想到的约束(时间、技术栈、不能动的东西、谁会用)

## Goal
产出一份"清晰目标 + 命名约束"陈述,使下游的 skill 或人能把它当 Inputs required 直接消费,不需要再问"你到底想要什么"。

## Modes

### Lightweight Mode
**触发**: 用户问的是"how to fix it"(问题已定义,只在多个修法中选一个),不是"是什么"或"该不该做"。触发短语: "怎么修" / "怎么改最快" / "哪种方式合适"。

**产出**: 2-3 句话 — 推荐做什么、改在哪里(`file:line` 如已知)、一句话为什么。先报最简单(brute-force)版本一行;除非用户要 elegance,否则默认推荐它。一行风险。等用户批准再 handoff。

**升级到主流程**: 如果发现 ≥ 3 个真正不同的修法且 tradeoff 显著,从 Lightweight 升级到主流程出完整目标 + 约束。

### Evaluation Mode
**触发**: 用户要判断某个东西"该不该存在 / 保留 / 暴露 / 移除",不是问"怎么做"。触发短语: "值不值得" / "有没有必要" / "该不该保留" / "判断一下"(后接价值/取舍而非报错)。

**产出**: 第一行直接给 verdict — **Kill** / **Keep** / **Pivot**,无前置铺垫。然后 3 条理由,基于用户的实际约束(时间 / 动机 / 业务模型 / 维护成本),不是泛泛 tradeoff。
- Pivot: 列具体方向,每行一个,可执行
- Kill / 大改: 先列影响范围(文件 / 依赖 / 迁移成本)再请求确认

不出"目标 + 约束"格式;只给一个 verdict。

**跟 Lightweight 区分**: Lightweight 答"how to fix"(方法);Evaluation 答"该不该存在"(价值)。

## Hard constraints
- 不写代码、不画实施步骤(那是其它 skill 的事);**归档到 `docs/praxis/think/` 是 skill 自带行为,不算"动文件"**
- 不接受"差不多""大概""可能"的目标 — 不可验证就重写到可验证为止
- 必须暴露至少 1 条用户没明说的假设
- 输入有 ≥2 种合理解释时,必须列出让用户选,不准自己挑
- 如果输入已经是"可验证目标 + 命名约束",直接说"不需要 think",不强行跑

## Output contract (主流程)
- 一句话**目标**(包含验收方式,例:"X 完成 = Y 通过")
- 列表式**约束**(必须做的 + 必须不做的)
- 列表式**暴露的假设**(每条以"我假设…"开头)
- 如有歧义,列**可能的解释方向**(2-4 条,让用户选)

(Lightweight Mode / Evaluation Mode 的 Output 见各 mode 描述,不走这里的格式)

## Implementation Handoff

主流程 think 产出后,下游 skill (`plan` / `write-code` / `design-ui` / `debug` 等) 应能直接消费,不需要再问"你到底想要什么"。归档文件 `docs/praxis/think/<slug>.md` 必须包含:

- **Building**: 一段话陈述这是什么(对应"目标")
- **Not building**: 显式列"不在范围"的事(防止下游 scope creep)
- **Approach**: 选定方向 + rationale(对应"约束"中的必须做项)
- **Key decisions**: 3-5 条关键决策 + 各一句话理由
- **Unknowns**: 显式列暂未决 / 待用户输入项 — 每条含"为什么没决 + 什么时候要决",**不准用 TBD / TODO 当最终决定**
- **Assumptions**: 用户没明说的假设(对应"暴露的假设")

下游消费方式:
- `plan` 读 think 文件: Building → 任务序列;Not building → 排除项;Key decisions → 任务约束
- `write-code` 读 think 文件: Building → 实现目标;Approach → 技术选型;Not building → YAGNI 边界
- `design-ui` 读 think 文件: Building → 功能目的;Approach → 审美方向锚定

handoff 不完整(有 TBD / TODO / "implement later" 当成最终决定)= think 没做完。

## Artifact
默认归档到 `docs/praxis/think/<slug>.md`,slug 由 goal 生成 kebab-case (3-5 词,如 `flask-to-fastapi-migration`)。

文件结构:
- frontmatter: `skill: think` / `slug` / `date` / `goal`
- body: Output contract 的全部内容(目标 + 约束 + 暴露的假设 + 可能的解释方向)

降级: `docs/praxis/` 不可写时,只 chat 输出,末尾标"未能归档 (原因: X)"。
防覆盖: `docs/praxis/think/<slug>.md` 已存在时,改写到 `<slug>--YYYYMMDD-HHmm.md`。

## Gotchas

| What happened | Rule |
|---|---|
| 用户输入已是清晰目标 + 约束,still 跑了 think | 触发前先扫输入是否已是 "verifiable goal + named constraints",是的话直接说 "不需要 think" |
| Lightweight Mode 给了一个 how-to-fix,没充分理由升级到主流程 | 升级门槛是 "≥ 3 个真正不同的修法且 tradeoff 显著",不是 "想给更多" |
| 用户说 "判断一下这个报错",触发了 Evaluation Mode | "判断一下" + 错误/异常上下文 = debugging → 路由到 `debug`;Evaluation Mode 只针对价值/存在性判断 |
| Implementation Handoff 含 TBD / TODO / "implement later" | handoff 不完整 = think 没做完;不准用 placeholder 当成最终决定 |
