---
name: write-prose
description: Use when explicitly asked to write or polish prose in Chinese or English. Strips AI writing patterns and produces text with an author's voice — not LLM defaults dressed up. Not for code comments, commit messages, or inline docs.
---

## When to invoke
- 用户明确要求"写""润色""改一段文字"
- 要产出公开发布的文字(文章、邮件、说明)
- 不是写代码注释、commit message、内联文档(那些用清晰直白即可,不需要 prose 风格)

## Inputs required
- 写什么(主题 / 一句话粗想法)
- 给谁看 + 在哪发(场景决定语气)
- (可选)风格参考: 喜欢哪种作者、哪种文章

## Goal
产出有作者声音、自然不像 AI 的中文 / 英文。读者读完不会立即识别为 LLM 输出。

## Hard constraints
- 删掉 AI 套话(完整清单 + 写完后自查清单见 `references/ai-cliche-list.md`)
- 禁止 ABC 三件套(逗号隔开 3 个并列形容词 / 动词);例子 + 改写方法见 `references/ai-cliche-list.md`
- 不用 emoji 装饰、不用全文加粗;1000 字以内最多 1 层 H2,不用 H3+,不用 bullet 取代段落叙述
- 不写"显得专业"的废话(空洞的过渡句、车轱辘话)
- 长短句必须有节奏变化 — 不全是中长句堆叠
- 用户给风格参考时(如"风格学习王小波"),产出必须真的体现该风格特征(短句多 / 讥讽感 / 口语词 / 回避四字成语等),不能只在"风格说明"里口头致敬而正文还是默认 LLM 文风

## Output contract
- 成文(可直接发布质量)
- 一行**风格说明**(声音定位 + 参考)
- (可选)**保留的反常用法**(故意为之的非标准表达,告诉用户不是错误)

## Gotchas

| What happened | Rule |
|---|---|
| 用户没说什么,产出含 "在当今 AI 时代""值得注意的是""总而言之" | 套话清单默认禁用 — 即使用户没明说,也应该不出现 |
| 介绍开发者工具堆 "高效、稳定、易用" | ABC 三件套是中文 LLM 最顽固模式;3 个属性分散到不同句子 / 段落,不在一句逗号并列 |
| 用户 "风格学习王小波",产出仍默认 LLM 文风,在风格说明里写 "参考王小波" | 风格参考要真实体现(短句 / 讥讽 / 口语 / 回避四字成语),不能只 lip service |
| 用户要 commit message,触发了 write-prose | commit message / 代码注释 / inline doc 不走 write-prose;直接给一行,不调 skill |
| 1000 字技术博客拆出 H2 + H3 + H4 + bullet + emoji | 1000 字内最多 1 层 H2;不用 H3+;不用 bullet 取代段落叙述;不用 emoji 装饰 |
