# 内嵌知识陷阱

learn 必须警惕的高陷阱主题。SKILL.md 的 Hard constraint 引用本文件。

---

## 为什么这是陷阱

LLM 训练数据里大量出现的主题,模型 prima facie 看起来很懂,但在以下方面会出错:
- **细节**: 边界 case / 默认值 / 命名细节
- **最新进展**: 训练截止后的新版本 / 新 API / 新 best practice
- **争议**: 业界还在演进的问题(模型给"看起来对"的答案掩盖争议)

## 高陷阱主题清单

### 框架与运行时
- React (尤其 hooks / Server Components / Concurrent / Suspense / use API)
- TypeScript (高级类型 / mapped types / conditional types)
- Vue / Angular / Svelte (各 reactivity 机制)
- Node.js (async hooks / streams / worker threads)
- Bun / Deno
- Rust (lifetimes / async / unsafe)

### AI / ML
- Transformer 架构 / Attention 机制
- RAG (Retrieval-Augmented Generation) / 各种 retrieval 技术
- Fine-tuning vs prompt engineering vs RLHF
- Vector databases (Pinecone / Weaviate / Chroma 各家细节)
- Multimodal models / vision-language

### 系统与基础设施
- Docker (BuildKit / multi-stage / layer caching)
- Kubernetes (operators / CRDs / network policies)
- Service mesh (Istio / Linkerd)
- Database (Postgres tuning / sharding / replication)
- Caching strategies (Redis / Memcached / CDN)

### 算法与计算
- 经典算法(快排 / Dijkstra / DP / B-tree) — LLM 容易给"教科书答案"忽略实际优化
- 加密算法(具体参数 / 安全 vs 性能 tradeoff)
- 分布式共识(Paxos / Raft 细节)
- Bitcoin / 区块链共识算法

### Web 标准
- HTTP/2 / HTTP/3 / QUIC
- WebSocket / SSE / Long polling 细节差异
- CORS / CSP / 各种 security headers
- Service Worker / Cache API

---

## 反制规则

即使主题在这清单里,learn 也必须先 read ≥ 2 份独立来源:

1. **一份权威源**: 官方 doc / 原始论文 / 主要 maintainer 的 blog
2. **一份近期源**: < 6 个月的实践 / 教程 / 技术博客(因为细节变化快)

不允许:
- "我已经知道 X 了,直接产出文章" — 触发 anti-patterns #1 用户压力反制
- 基于内嵌知识写"深入" / "详细" / "内部机制"内容 — 必有"未消化"标注
- 用户施压"主题广为人知,直接讲" — 拒绝并说明(参 SKILL.md Hard constraint)

---

## 区分清单内 vs 清单外

| 类型 | 触发要求 |
|---|---|
| **清单内**(高陷阱) | 必须先 read,模型容易过度自信,不能凭印象 |
| **清单外**(冷门 / 内部工具 / 新发布) | 当然要 read,因为模型本来就不熟 |

清单不是穷尽的 — 任何感觉"模型很熟但实际可能错"的主题,默认按高陷阱处理。

---

## learn 怎么用这个清单

进入 learn 工作流之前的 self-check:

```
Q: 我要 learn 的主题在 embedded-knowledge-traps.md 清单里吗?
   - 在 → 严格执行 ≥ 2 份 read,不依赖内嵌知识
   - 不在 → 也要 ≥ 2 份 read(常态),但风险更低

Q: 用户施压"这个主题广为人知,直接产出"怎么办?
   - 拒绝。参 anti-patterns #1 用户压力反制。
   - 解释:"这个主题模型容易过度自信,不 read 直接产出有错误风险。"
```
