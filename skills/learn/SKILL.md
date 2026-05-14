---
name: learn
description: Use when entering an unfamiliar domain and the goal is to build understanding through producing — articles, tutorials, working artifacts — rather than passive reading. Produces an output that anchors the learning, not a summary of sources.
---

## When to invoke
- 进入不熟悉的领域(技术 / 学术 / 行业 / 工艺)
- 已有多份 read 笔记或材料,需要整合成自己的理解
- 不是"快速扫一眼"(那是 read);要的是"建立可被自己复述的理解"

## Inputs required
- 学习领域(一句话)
- (强烈建议)≥2 个 read 笔记文件路径(`docs/praxis/read/*.md`)或外部权威材料
- **目标产出形式**: 文章 / 教程 / 可运行 demo / 内部分享 — 没有就向用户索取,不自动选

## Goal
通过"产出"建立对该领域的可复述理解。最终交付的不是材料摘要,而是一份独立成立的产物(文章/教程/demo),其中体现了对这个领域核心概念的把握。

## Hard constraints
- 必须有具体产出形式(没有产出锚点 = 没在 learn,在 read)
- 不以"摘抄"或"翻译"代替理解 — 每个核心概念用自己的话讲一遍。"整合"综述时,概念地图必须是自己理解的概念关系,不是论文术语堆叠
- 不假装懂没懂的东西 — 没把握的部分显式标"未消化"。**材料不足以支撑产出深度("深入" / "详细" / "内部机制")时也要诚实说,产出能写部分 + 大量"未消化"标注,不强凑**
- 不在材料密度不足时硬产出(< 2 份独立来源直接说"先 read")。**即使主题广为人知,也必须先 read ≥ 2 份独立来源,不依赖内嵌知识**(高陷阱主题清单见 `references/embedded-knowledge-traps.md`)

## Output contract
- **产物**(按 Inputs 里指定形式 — 文章 / 教程 / demo)
- 一段**核心概念地图**(这个领域的 5-10 个关键概念 + 它们的关系)
- 一行**未消化的部分**(诚实标注)
- 一行**下一步**(继续学什么、用什么)

## Artifact
默认归档到 `docs/praxis/learn/<slug>.md`,slug 由学习领域生成 kebab-case (如 `rag-internal-share`、`react-server-components-tutorial`)。

文件结构:
- frontmatter: `skill: learn` / `slug` / `date` / `domain` / `read: [<read 文件路径列表>]` / `output_form: <文章/教程/demo/分享>`
- body: Output contract 的全部内容(产物 + 核心概念地图 + 未消化部分 + 下一步)

降级: `docs/praxis/` 不可写时,只 chat 输出,末尾标"未能归档 (原因: X)"。
防覆盖: `docs/praxis/learn/<slug>.md` 已存在时,改写到 `<slug>--YYYYMMDD-HHmm.md`。

## Gotchas

| What happened | Rule |
|---|---|
| 0 份材料要 2000 字 "量子计算科普",直接写了 | 主题再广为人知,< 2 份 read 材料就先 read,不依赖内嵌知识 |
| 1 份模糊笔记要 "3000 字深入 PyTorch autograd 内部机制",自信写了 | 材料密度 < 产出深度时,产出能写部分 + 大量 "未消化" 标注;不强凑 |
| 综述 3 篇 RAG 论文,概念地图全是论文术语堆叠 | 概念地图必须是自己理解的概念关系,不是术语列表 |
| 用户没说产出形式,自己默认按 "内部分享文章" 写 | 产出形式没给就索取,不自动选(参 Inputs required) |
| 单次浏览一篇 RAG 论文也触发了 learn | 单次浏览 = read,不是 learn;learn 需要 "通过产出建立理解" |
