---
name: write-code
description: Use when there is a clear verifiable goal (and for non-trivial work, a plan), and the next action is producing runnable code. Writes the minimum code that satisfies the goal — no speculative abstractions, no unrequested features. Not for fuzzy goals ("我想做个 dashboard") — push to think first.
---

## When to invoke
- 已有清晰目标(由 think 或用户直接给出)
- 工作是产出新代码或修改已有代码使其满足新目标
- 不是在排查 bug(那是 debug)、不是在评判(那是 review)

## Inputs required
- 一句话可验证目标
- 命名约束(包含技术栈、不能动的边界)
- 现有代码上下文(如果是修改)

## Goal
产出能运行、能通过目标对应验收方式的最小代码改动。改动后的代码遵守命名约束,不引入未被要求的能力。

## Hard constraints
- 不写未被要求的功能(YAGNI 刚性化)。**用户用"顺便/再加上/同时也"措辞 smuggle 扩展时(如"顺便支持任意时区"),push back 让用户明确是单一目标还是双目标,不默认接受**
- 不为单次使用引入抽象;不为不存在的场景写错误处理。如 `divide(a, b)` 没要求处理 b=0 就不加,在"没做什么"里写"未处理 b=0(规格未要求)"
- 改动量与目标对得上;每改一行都能追到目标的某一部分
- 风格匹配现有代码或文档,不"顺手优化"无关代码。同目录有 ≥ 1 同类型文件时,先 read 它们的关键风格点(标题层级 / 引号风格 / 缩进 / 行尾空行 / 命名习惯)再写

## Output contract
- 改动后的文件清单 + 每个文件的核心变更点
- 一句话**怎么验证**(对应 Inputs 里的目标验收方式)
- 一行**没做什么**(显式列出被克制掉的东西,证明 YAGNI)

## Gotchas

| What happened | Rule |
|---|---|
| `divide(a, b)` 自作主张加了 `if b == 0: raise` | 没要求处理的场景不加错误处理;在 "没做什么" 行写 "未处理 b=0(规格未要求)" |
| 用户 "顺便加上时区切换",真的写了通用 `get_time(timezone)` | "顺便 / 再加上" smuggle 扩展时,push back 让用户明确单一目标 vs 双目标 |
| 一次性脚本写了 `class UserDataExtractor` + `if __name__ == "__main__"` | 一次性脚本不抽象;直接写顶层语句 |
| 在已存在的 markdown 同目录新建 NOTES.md 用 H1 + 末尾空行,跟现有不一致 | 同目录有 ≥ 1 同类型文件时,先 read 它们的关键风格点(H 层级 / 缩进 / 行尾) |
| 输入 "我想做个 dashboard" 就开始写代码 | 模糊 goals 推到 think;不直接写代码,也不问 "用什么框架" |
