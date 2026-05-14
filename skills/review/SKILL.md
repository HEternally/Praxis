---
name: review
description: Use when judging whether an existing artifact (code, design, doc, plan, prose) achieves its stated goal and respects its named constraints. Returns verdict with evidence — does not rewrite.
---

## When to invoke
- 已有产物 + 当时的目标和约束(没有就先拿到,否则 review 没意义)
- 用户问"这个行不行""有没有问题"
- 在合并、发布、提交前

## Inputs required
- 待审产物(代码 diff / 设计稿 / 文档 / 计划)
- 当时的**目标**与**约束**(必须明确,缺则要求补)。**即使产物有明显问题(如 SQL 注入、null check 缺失、明显 bug),缺 goal/constraints 仍必须先索取 — 否则无法判断这是 bug 还是规格内行为**

## Goal
产出一个判断: 产物是否达成目标、是否守住约束。判断必须基于证据(指向产物里的具体位置)而非主观偏好。

## Project Context Extraction

review 不是凭空的"通用 review",而是基于项目特定约束做判断。在产出 verdict 前,从公开项目上下文提取约束:

1. **identify 变更**: 读 diff,识别涉及的语言、框架、generated 输出、release 文件、CI 工作流
2. **inspect 项目文件** (按需):
   - `README.md` — 项目目标 / 验证命令 / 受保护文件
   - `package.json` / `Cargo.toml` / `go.mod` / `requirements.txt` — 依赖范围 / 锁定版本 / scripts
   - `Makefile` / `.github/workflows/*.yml` — 验证 / 构建 / 发布命令
   - `AGENTS.md` / `CLAUDE.md` / `.claude/rules/*.md` — 项目级规则
   - `CHANGELOG.md` / `docs/` — 历史决策 / 受保护内容
3. **extract**: 验证命令、generated 文件、protected 文件、release artifact、领域风险
4. **冲突优先**: 项目上下文跟用户给的 goal/constraints 冲突时,**用更严的那个**并显式标出冲突
5. **无规则记录**: 项目无 AGENTS.md / CLAUDE.md / 规则文件,记 "无项目级约束 — 仅基于 goal/constraints 判断"

## Hard constraints
- 不重写产物;只产出 verdict + 证据。**即使用户明确要求"直接给改好的版本""帮我重写一遍",也必须拒绝并说明 — review 只产 verdict,重写由 write-code 出**
- 每条意见必须指向产物里的具体位置(行号、段名、组件名)
- 不带入"我会怎么写"的偏好;只对"是否达成目标 + 是否守约束"发声
- 区分**必须改**(违反约束/未达目标)与**建议**(改进空间);两者不混。如未处理边界 case 是必须改(违反"处理所有合理输入"目标);命名不够语义化是建议(不违反目标/约束)

## Output contract
- 总判断: PASS / NEEDS CHANGES / FAIL,一句话理由
- **必须改**清单(按严重度排序,每项含位置 + 违反了哪条约束/目标)
- **建议**清单(可选,每项含位置 + 改进点)
- 一行**复审条件**(达成什么状态可以再来)
- 末尾结构化 **Sign-off**(见下)

## Sign-off

review 末尾必须给一个结构化 sign-off,让用户能机读:

```
files changed:    N (+X -Y)
scope:            on target / drift: <一句话哪里 drift / incomplete>
review depth:     quick (<100 行 / 1-5 文件) / standard (100-500 行 / 6-10 文件) / deep (>500 行 / 10+ 文件 / 涉及 auth / payments / data mutation)
verdict:          PASS / NEEDS CHANGES / FAIL
must-fix:         N 条 (逐条引用位置)
suggestions:      N 条
verification:     <跑过的命令> -> pass / fail / (基于读代码,未跑)
project rules:    <从 AGENTS.md / CLAUDE.md / CI 提取的规则,逐条评估是否守住,无规则文件则写"无项目级约束">
```

depth 决定要不要做 specialist 二次审 (暂不实现 — deep diff 时在 sign-off 加 `advisory: 建议 second-pass review`)。

## Gotchas

| What happened | Rule |
|---|---|
| 看到明显 SQL 注入,缺 goal/constraints 直接给 verdict | 即使代码有明显 bug,缺 goal/constraints 仍先索取 — review 不替用户做决定 |
| 用户 "直接给改好的版本",输出包含改写后代码 | review 不重写;只产 verdict + 证据;重写由 write-code 出 |
| 把 "命名不够语义化" 列入 "必须改" | 命名不违反 goal/constraints = 建议;"必须改" 只放违反 goal/constraints 的 |
| 用户约束 "不用 styled-components",建议改用 styled-components | review 不带 "我会怎么写" 偏好;约束之外的偏好不入清单 |
| Sign-off 没列 verification 命令 | Sign-off 必填项;没跑就标 "(基于读代码,未跑)",不省略 |
