---
name: read
description: Use when given any URL, PDF, paper, or long document and the goal is to extract its content into reusable notes — not to summarize it down. Preserves information density, retains source pointers.
---

## When to invoke
- 用户给出 URL / PDF / 论文链接,要"看一下""读一下""记下要点"
- 准备 learn 或 write-prose 之前需要消化外部材料
- 不是要"总结"(总结会丢密度) — 要的是高密度可复用笔记

## Inputs required
- 至少 1 个 URL / 文件路径 / 文档标题
- (可选)关注的角度("我关心 X 方面")

## Goal
产出一份高密度笔记: 保留原文的关键事实、定义、数据、论证链路,而非压缩成摘要。笔记必须可以脱离原文被引用、被 learn / write-prose 当输入消费。

## Hard constraints
- 不"总结"(损失密度);保持原文的术语、数字、引文。**即使用户明确要求"用 N 句话总结""概括一下""简化",也必须拒绝并说明 — 总结由 learn / write-prose 出,read 只产高密度笔记**
- 每个非显然的论断必须**保留来源指向**(段落 / 章节 / 时间戳)
- 不加入个人解读 / 评价 / 联想(那是 learn / write-prose 的事)。**即使用户明确要求"告诉我优缺点""我应该怎么用""适不适合 X 场景",也只产笔记,推到 learn**
- 不"翻译"成自己的话来"通顺化" — 关键术语保持原文
- 多源(≥ 2 个 URL / PDF / 文档)时各产一份独立笔记,不整合;"整合"是 learn 的事,推过去

## Output contract
- 笔记主体: 按原文结构组织(章节标题对齐)
- 每节包含: 关键事实、定义、数据、引文(带原位置标注 — PDF 用页码、URL 用章节锚点 / 标题、论文用 section 编号 / 图表号)
- 一行**未读完 / 未消化的部分**(诚实标注)
- 一行**关键引文 1-3 条**(原文摘抄,可直接用)

## Artifact
默认归档到 `docs/praxis/read/<slug>.md`,slug 由 URL / PDF 标题生成 kebab-case (3-5 词,如 `anthropic-prompt-caching-docs`)。

文件结构:
- frontmatter: `skill: read` / `slug` / `date` / `source: <URL 或 PDF 路径>`
- body: Output contract 的全部内容(笔记主体 + 关键事实 + 未读完部分 + 关键引文)
- 多源时各产一份独立文件,不合并(对应 Hard constraint)

降级: `docs/praxis/` 不可写时,只 chat 输出,末尾标"未能归档 (原因: X)"。
防覆盖: `docs/praxis/read/<slug>.md` 已存在时,改写到 `<slug>--YYYYMMDD-HHmm.md`。

## Gotchas

| What happened | Rule |
|---|---|
| 用户 "读这 3 个 URL 整合一份知识总结",真的整合了 | 多源各产一份独立笔记;"整合" 是 learn 的事 |
| 用户 "告诉我这个特性的优缺点和我应该怎么用",输出含 "我认为推荐..." | 不加入个人解读 / 评价 / 应用建议;那是 learn / write-prose 的事 |
| 用户 "用 3 句话总结一下",真给了 3 句总结 | 不 "总结"(损失密度);坚持产高密度笔记,即使用户施压 |
| PDF 引文没标页码,URL 引文没标章节锚点 | 不同源用对应位置标注:PDF 用页码,URL 用章节锚点 / 标题,论文用 section 编号 / 图表号 |
