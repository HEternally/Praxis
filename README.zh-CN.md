# Praxis

[English](./README.md) · [中文](./README.zh-CN.md)

为 Claude Code 设计的 9 个 skill,把模型的原始能力转换成精确产出。

每个 skill 划出清晰的**目标**、命名**刚性约束**、定义**产出契约**,需要时归档可复用的产物。怎么做这件事,留给模型。

## 设计哲学

模型本身已经很强,但缺乏结构时,产出会变得泛泛、不精确。Praxis 加的不是流程脚本,而是把"做什么"和"不做什么"写得极其清楚,然后信任模型的"怎么做"。

三个设计选择:

- **Skill 保持小巧。** 一个 SKILL.md 在 30–90 行。约束刚性,执行开放。
- **跨 skill 规则单独提取。** 共性的用户压力反制和反模式放在 `rules/anti-patterns.md`,不在每个 skill 里重复。
- **产物持久化。** 5 个 skill (`think` / `plan` / `read` / `design-ui` / `learn`) 默认归档到 `docs/praxis/<skill>/<slug>.md`,下游 skill 和协作者可以跨会话消费。

## 怎么选 (Praxis vs Waza vs Superpowers)

| | [superpowers](https://github.com/obra/superpowers) | [waza](https://github.com/tw93/Waza) | Praxis |
|---|---|---|---|
| 立场 | 完整方法论 + 强制工作流 | 工程习惯 codified | 约束 + 判断 |
| Skill 数 | 约 14 个,体量大,带 scripts / agents | 8 个,中等 (100–200 行) | 9 个,小 (30–90 行) |
| 触发方式 | 自动触发,mandatory | 手动转接 | 手动触发 |
| 持久化 | 文件输出 | 不归档 | 归档到 `docs/praxis/` |
| 平台 | Claude Code / Codex / Gemini / Cursor / Copilot / OpenCode / Factory | Claude Code / Codex / Claude Desktop | 仅 Claude Code |
| 适合谁 | 需要严格流程的团队 / TDD-by-default / junior 引导 | 个人或小团队工程师,想要习惯 codified + 项目感知 review | 资深开发者,信任模型,想要红线而非 checklist |

**选 Praxis 如果**: 你不喜欢框架规定步骤,但仍要保持"什么算做完"的一致性。Praxis 划红线,然后让位。

**选 Waza 如果**: 你想要工程习惯被显式记录 — `/check` 读项目 README / manifest / CI 提取约束,`/hunt` 自动跑 `git bisect`,triage / release follow-through 等模式预置好。

**选 Superpowers 如果**: 你希望模型先停下来问"你究竟想做什么",然后自动走 brainstorming → plan → TDD → review。最适合需要每个贡献者跟同一流程的团队。

三者并不互斥。Praxis 借鉴了 waza 的几个具体设计 (RESOLVER routing / anti-patterns 单独 / Gotchas tables / project-context extraction / sign-off templates / `references/`),也保持着 superpowers "process over guessing" 的精神 — 在 Praxis 故意更轻的场景里。

## 9 个 Skills

| Skill | 产出 | 归档 |
|---|---|---|
| `think` | 可验证目标 + 命名约束 + 暴露的假设 + Implementation Handoff | `docs/praxis/think/` |
| `plan` | 有顺序的任务序列,每个任务独立验收 | `docs/praxis/plan/` |
| `write-code` | 满足目标的最小可运行代码 — 不写多余 | (代码本身) |
| `review` | Verdict (PASS / NEEDS CHANGES / FAIL) + 证据 + 结构化 Sign-off | (不归档) |
| `debug` | 命名根因 + 最小修复 + 回归测试 | (修复在代码里) |
| `design-ui` | 锁定的审美 + 状态 + token,可被 write-code 直接消费 | `docs/praxis/design-ui/` |
| `read` | 高密度笔记,保留原文术语、数字、引文 | `docs/praxis/read/` |
| `write-prose` | 中英文 prose,有作者声音,删 AI 套话 | (用户决定) |
| `learn` | 可发布的产物 (文章 / 教程 / demo),让理解被锚定 | `docs/praxis/learn/` |

`think` 内含两个 sub-mode — Lightweight (针对"怎么修") + Evaluation (针对 Kill / Keep / Pivot 价值判断) — 避免小问题也走完整设计流程。

## Skill 关系

```
think → plan → write-code / debug / design-ui / write-prose / learn
                ↑___________________ review _________________↓
                                    read (独立,喂给 learn / write-prose)
```

- `think` 在目标不可验证时先跑
- `plan` 在 think 之后,如果工作需要拆步骤;`plan` 消费 `think` 产物
- `design-ui` 和 `learn` 分别消费 `think` 和 `read` 产物
- `review` 用项目上下文 (README, manifests, CI, AGENTS.md) 验证下游产物

完整路由表 + 10 条歧义消解规则见 `skills/RESOLVER.md`。

## 项目结构

```
.
├── README.md / README.zh-CN.md
├── rules/
│   └── anti-patterns.md         # 8 条跨 skill 反模式 (用户压力反制 / 范围蔓延 / 编造验证等)
├── scripts/
│   └── verify-skills.sh         # 形式合规校验 (frontmatter / sections / RESOLVER 一致性 / references 链路)
├── skills/
│   ├── RESOLVER.md              # 工作流路由 + 10 条歧义消解
│   ├── <skill>/
│   │   ├── SKILL.md             # frontmatter + 5 个必需 section + Gotchas
│   │   └── references/          # 从 SKILL.md 抽出来的详细材料 (按需)
└── docs/
    └── praxis/                  # think / plan / read / design-ui / learn 的产物归档
```

## SKILL.md 结构

每个 SKILL.md 的形状一致:

```
---
name: <slug>
description: <一行触发文本,60-300 字符>
---

## When to invoke         什么场景调这个 skill
## Inputs required        开始前必须有的输入
## Goal                   要到达的状态 (不是动作清单)
## Hard constraints       3-7 条刚性红线 (must / must not)
## Output contract        可验证的交付项
## Artifact               (5 个 skill) 产物归档到哪里
## Gotchas                "What happened | Rule" 真实失败案例总结
```

跨 skill 守则 (用户压力反制 / 凭空捏造路径 / 编造验证等) 在 `rules/anti-patterns.md`,SKILL.md 不重复。

## 校验

```bash
bash scripts/verify-skills.sh
```

6 项检查: anti-patterns + RESOLVER 存在性、SKILL.md 结构、description 长度 (60-300 字符)、Artifact 路径正确、RESOLVER 引用所有 skill、`references/` 链路完整。

## 安装

```bash
# Marketplace 安装 (待支持)
/plugin install praxis

# 当前: 手动 clone 作为 plugin
git clone https://github.com/HEternally/Praxis.git ~/.claude/plugins/praxis
```

或直接以 plugin 目录方式启动:

```bash
claude --plugin-dir /path/to/praxis
```

## 致谢

Praxis 借鉴了 [Waza](https://github.com/tw93/Waza) ([@tw93](https://github.com/tw93)) 的几个关键设计: 集中的 RESOLVER 路由表、anti-patterns 单独成文、Gotchas 表 codify 真实失败、review 的 project-context 提取、结构化 sign-off 模板、`references/` 子目录抽离详细材料。Waza 自己的哲学 — "each rule the author writes becomes a ceiling" — 也影响了 Praxis 保持 SKILL.md 极简的决定。

跟 Waza 不同: SKILL.md 更小,`plan` 和 `write-code` 是独立 skill 不是 think 的子模式,产物归档到 `docs/praxis/`,有对抗性测试矩阵验证 SKILL 设计。

跟 [Superpowers](https://github.com/obra/superpowers) 不同: 没有 mandatory workflow、不自动触发、不强制 TDD。模型决定怎么做,Praxis 决定哪些是出界。

## 状态

v0.2 — 9 个 skill 都到位。跨 skill 规则提取到 `rules/`。路由集中在 `RESOLVER.md`。5 个归档 skill 已 wire up。校验脚本就绪。待办: 在干净 plugin 会话里跑测试矩阵的 9 个高风险用例 (`docs/superpowers/tests/2026-05-14-skills-validation.md`)。

## License

MIT
