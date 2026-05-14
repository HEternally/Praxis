---
name: design-ui
description: Use when building any user interface, component, page, or visual layout. Produces a design with a committed aesthetic and explicit functional purpose — not generic defaults dressed in a framework. Not for single-property tweaks (changing padding/color/border-radius values) — those go to write-code.
---

## When to invoke
- 要产出新的界面、组件、页面、视觉布局
- 已有 UI 需要重新设计 / 重排 / 加状态(**不是单属性微调:改 padding / color / border-radius 等单值走 write-code,不走 design-ui**)
- 在 write-code 写 UI 之前(目的是先确定形,再写代码)

## Inputs required
- 这个界面的**功能目的**(用户来这里要做什么)
- 适用场景与约束(屏幕尺寸、品牌色、必须复用的组件库)
- 1-3 个参考(可以是产品截图、风格关键词)
- (可选)对应 think 文件路径: `docs/praxis/think/<slug>.md` — 如有,design-ui 直接消费目标 + 约束

## Goal
产出一份有明确审美方向 + 明确功能行为的界面方案。方案能直接被 write-code 当输入消费,不需要再问"这里应该用什么颜色 / 间距 / 状态"。

## Hard constraints
- 必须明确陈述**审美选择** — 禁用空词,改用具体描述。完整空词清单 + 替代词汇 + 整体定位例子见 `references/aesthetic-vocabulary.md`
- 不依赖 UI 框架默认值搪塞(默认值 = 没设计)。**即使用户明确要求"快速""默认 Tailwind 即可""不用想太多""简单些",也必须做出审美选择 — design-ui 的存在意义就是不出默认设计**
- 每个交互状态必须列出。完整状态清单(按组件类型分: input / list / data / button / modal / form)见 `references/state-checklist.md`
- 不为不存在的场景设计(YAGNI: 没要求的暗黑模式 / 国际化 / 无障碍可以提但不实现)。用户列出投机性场景(手表 / 电视 / 可穿戴等真实需求未确认)时,先 push back 确认范围,不全部做

## Output contract
- **审美陈述**: 这个界面长什么样 + 为什么这么选(2-3 句)
- **布局**: 文字描述或低保真线框
- **每个组件的所有状态**清单
- **token 表**(颜色 / 字号 / 间距,如果项目有 token 系统则用,无则现起)

## Artifact
默认归档到 `docs/praxis/design-ui/<slug>.md`,slug 由界面 / 组件名生成 kebab-case (如 `saas-settings-page`、`search-input-component`)。

文件结构:
- frontmatter: `skill: design-ui` / `slug` / `date` / `goal` / `think: <think 文件路径,如有>`
- body: Output contract 的全部内容(审美陈述 + 布局 + 状态清单 + token 表)

降级: `docs/praxis/` 不可写时,只 chat 输出,末尾标"未能归档 (原因: X)"。
防覆盖: `docs/praxis/design-ui/<slug>.md` 已存在时,改写到 `<slug>--YYYYMMDD-HHmm.md`。

## Gotchas

| What happened | Rule |
|---|---|
| "把 Button.tsx padding 8px 12px 改成 12px 16px" 触发了 design-ui | 单属性微调走 write-code,不走 design-ui |
| 审美陈述写 "现代简洁,信息密度适中" | 禁用 "现代 / 简洁 / 简约 / 清爽" 等空词;改用 "密度低字号大""按钮 ghost 而非实心""卡片硬边而非圆角" 等具体描述 |
| 搜索框组件状态清单只列 default + focus | input 类必须细分 typing / has-value;list 类加 empty-results / loading;data 类加 stale / syncing |
| 用户 "快速给个登录页就行,默认 Tailwind",输出泛 Tailwind 模板 | 即使用户要求 "默认即可",也做审美选择 — design-ui 存在意义就是不出默认设计 |
| 用户列出 "支持手表 / 电视 / 可穿戴",真的全设计了 | 投机性场景先 push back 确认范围;不全部做 |
