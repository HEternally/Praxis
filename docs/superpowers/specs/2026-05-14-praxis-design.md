# Praxis — Design Spec

**日期**: 2026-05-14
**状态**: 设计阶段，待实施

---

## 1. 定位与哲学

### Praxis 是什么
一个 Claude Code plugin，提供 9 个 skill，把"优秀工程师"具备的能力打包成结构化、可复用的能力包。

### 核心哲学(一句话)
**每个 skill 设定清晰的目标、必守约束、产出契约 — 过程让模型自由发挥。**

### 与 superpowers 的对比

|  | superpowers | Praxis |
|---|---|---|
| 哲学 | 严格流程主义(checklist、red flags、HARD-GATE、DOT 流程图) | 目标 + 约束主义(精确目标、刚性约束、自由过程) |
| skill 长度 | 几百行(含子文档) | ≤ 80 行 |
| 对模型的态度 | 不信任,强制走流程 | 信任,给精确边界 |
| 关心的是 | "怎么做" | "做什么" + "不能做什么" |

### 前提
A 哲学成立的基础是"模型已经够强"。Praxis 不教模型怎么做事(那是流程主义),而是把"做什么"和"不能做什么"钉到极致清晰。如果不认同这个前提,Praxis 整个不成立。

---

## 2. 9 个 skill 清单

| slug | Goal |
|---|---|
| `think` | 把模糊想法转成清晰可验证的目标和约束 |
| `plan` | 把已有的"清晰目标 + 约束"转成有顺序的可执行任务序列,每个任务可独立验证 |
| `write-code` | 把已有目标落地为可运行代码 |
| `review` | 判断已有产物是否达成目标、是否守约束 |
| `debug` | 定位 bug 真正的根因 |
| `design-ui` | 产出有审美选择和功能性的界面方案 |
| `read` | 把外部材料转成可消化的高密度笔记 |
| `write-prose` | 写自然不像 AI 的中文/英文 |
| `learn` | 在不熟悉的领域用深度产出建立理解 |

### Skill 关系图

```
think → plan → write-code / debug / design-ui / write-prose / learn
                ↑___________________ review _________________↓
                                    read (独立)
```

- `think` 在所有动手前(目标不清楚就先 think)
- `plan` 在 think 之后,把目标拆成任务
- `review` 验收任何下游产物
- `read` 跟代码/产出流程没强耦合,独立使用

---

## 3. Skill 骨架规范

每个 skill 文件统一结构:

```
---
name: <slug>
description: <一句话,Skill tool 用它判断是否触发>
---

## When to invoke         触发场景,描述"出现什么",不是"想做什么"
## Inputs required        缺了就先索取,不能动手
## Goal                   一段话讲清要达成的状态(不是动作)
## Hard constraints       3-7 条刚性红线("必须/不能",不准"建议/尽量")
## Output contract        完工时的产物清单(每条可验证)
```

### 风格硬约束(防止骨架被填成 superpowers)

- 不写 checklist、不画流程图、不写 anti-pattern 表
- Hard constraints **少于 3 条说明没想清楚,多于 7 条说明在写流程**
- Goal 写"达成什么状态",Output 写"包含什么产物" — 两者都不写"做什么动作"
- 整个 SKILL.md 文件 **≤ 80 行**
- description 用英文(Claude Code Skill tool 用它做 model trigger)

---

## 4. 样板:think skill

下面这段是 `skills/think/SKILL.md` 的最终候选内容。其它 8 个 skill 在阶段 2/3 按这个样板填。

```markdown
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

## Hard constraints
- 不写代码、不动文件、不画实施步骤(那是其它 skill 的事)
- 不接受"差不多""大概""可能"的目标 — 不可验证就重写到可验证为止
- 必须暴露至少 1 条用户没明说的假设
- 输入有 ≥2 种合理解释时,必须列出让用户选,不准自己挑
- 如果输入已经是"可验证目标 + 命名约束",直接说"不需要 think",不强行跑

## Output contract
- 一句话**目标**(包含验收方式,例:"X 完成 = Y 通过")
- 列表式**约束**(必须做的 + 必须不做的)
- 列表式**暴露的假设**(每条以"我假设…"开头)
- 如有歧义,列**可能的解释方向**(2-4 条,让用户选)
```

约 30 行,在 80 行预算内。

---

## 5. 命名规则

**混合派**(短名 + 必要时加宾语消歧):

- 单动词: `think` / `plan` / `debug` / `review` / `read` / `learn`
- 动词+宾语: `write-code` / `design-ui` / `write-prose`

**理由**: `write` / `design` / `code` 单独看歧义太大(写啥?设计啥?),`read` 单独看可以(行为本身就是核心,读啥次要)。

---

## 6. Plugin 目录结构

```
Praxis/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   ├── think/SKILL.md          ← 阶段 1 产出
│   ├── plan/SKILL.md
│   ├── write-code/SKILL.md
│   ├── debug/SKILL.md
│   ├── review/SKILL.md
│   ├── design-ui/SKILL.md
│   ├── read/SKILL.md
│   ├── write-prose/SKILL.md
│   └── learn/SKILL.md
└── README.md
```

---

## 7. MVP 三阶段路径

| 阶段 | 产出 | 验收 |
|---|---|---|
| **1. 样板** | `skills/think/SKILL.md` 写到完整可发布质量 | think 跑过一次真实模糊需求,产出符合 Output contract |
| **2. 批量最简版** | 其它 8 个 skill 按同一骨架产出"最简可用版"(frontmatter + Goal + 3 条 Hard constraints + Output contract);plugin.json + README 完成 | 9 个 skill 全部能被 Claude Code 装载并触发,可发布 v0.1 |
| **3. 回流迭代** | 按实际使用频率,把每个 skill 迭代到完整版(每条 constraint 经过实战检验) | 每个 skill 至少经历 3 次真实调用,Hard constraints 没有被绕过过 |

---

## 8. 发布定位

**A. 公开 GitHub repo + 加入 Claude Code marketplace**

- 写完整 README(哲学陈述 + 9 个 skill 速查表 + 安装说明)
- 公开后不主动推广,让感兴趣的人自己找到
- 维护节奏: 自己用得最顺手的 skill 优先迭代,不为推广而扩展

---

## 9. 待解决问题

无重大未决项。命名最终敲定、目录初始化、git 化、第一个 skill 撰写均在实施计划阶段处理。
