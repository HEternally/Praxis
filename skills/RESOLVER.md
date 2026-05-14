# Praxis Skill Resolver

9 个 skill 的工作流路由表 + 歧义消解规则。Claude Code 通过每个 SKILL.md 的 `description` 自动匹配触发,这份文档是给人看的集中索引,也是模型在多个 skill 都可能匹配时的消解依据。

> **改 SKILL.md 的 description / When to invoke 时,同步改这里。**

---

## 按工作流阶段路由

| 阶段 | 触发场景 | Skill |
|---|---|---|
| **Pre-build** | 模糊目标 / "我想做 X" / 价值判断("值不值得做") / 需要变可验证 | `think` |
| **Pre-build** | 已有可验证目标,要拆步骤,工作 ≥ 3 个独立任务 | `plan` |
| **Pre-build** | 产出新界面 / 组件 / 页面 / 视觉布局 | `design-ui` |
| **Build** | 已有清晰目标(可能有 plan),写新代码或改代码 | `write-code` |
| **Post-build** | 已有产物 + goal + 约束,要判断是否达标 | `review` |
| **Diagnostic** | 报错 / 崩溃 / 测试失败 / 行为异常 / "为什么不工作" | `debug` |
| **Content** | 给定 URL / PDF / 文档,要提取高密度笔记 | `read` |
| **Content** | 写 / 润色公开发布文字(博客 / 邮件 / 文章) | `write-prose` |
| **Content** | 进入陌生领域,有 ≥ 2 份材料,通过产出建立理解 | `learn` |

---

## 歧义消解规则

多个 skill 都可能匹配时,按以下顺序判断:

### 1. 目标可不可验证 — think 还是其它?

- "我想做个 dashboard" / "让 API 更可靠" / "改一下 X" → **不可验证** → `think` 先
- "在 src/foo.py 加 sum_evens 返回偶数和" → **可验证** → 直接 `write-code`(单步)或 `plan`(多步)

判断: 目标能挑出"做完了"的具体标志吗?能 = 可验证。

### 2. 有产物 vs 没产物 — review 还是 write-code?

- 有 diff / 代码片段 + 用户问"看看怎么样" → `review`
- 没产物 / 还在写 → `write-code`

### 3. 有报错 vs 没报错 — debug 还是 review?

- 有错误 / 崩溃 / 测试失败 / "不工作" → `debug`
- 能跑但用户问"质量怎么样" → `review`
- "继续优化" + 有报错 → `debug`
- "继续优化" + 无报错 → `review`

### 4. 微调 vs 重新设计 — write-code 还是 design-ui?

- 改 padding / color / border-radius 等单属性单值 → `write-code`
- 重新设计组件 / 加状态 / 重排布局 → `design-ui`

### 5. 单源 vs 多源 — read 还是 learn?

- 1 个 URL / PDF,要笔记 → `read`
- 多个 read 笔记 / 材料,要"通过产出建立理解" → `learn`(消费 read 文件作为输入)
- 多个 URL 但只要分别 read → `read`(各产独立笔记,**不整合** — 整合是 learn 的事)

### 6. 单一动作 vs 多步 — write-code 还是 plan + write-code?

- 改一个常量 / 加一个函数 / 改一处样式 → `write-code`(无需 plan)
- 迁移框架 / 重构系统 / 加新模块 → `plan` 先,再 `write-code` 按任务执行

判断: 任务能拆出 ≥ 3 个独立可验收的步骤吗?能 = 走 plan。

### 7. 写新内容 vs 评审 — write-prose 还是 review?

- 用户给一段 prose 问"写得怎么样" + 有目标 + 约束 → `review`
- 用户要新写或改写一段 → `write-prose`

### 8. commit message / inline doc 不走 write-prose

`write-prose` description 明确反触发 commit message / 代码注释 / inline doc — 这些用清晰直白格式即可,不调 skill,直接给一行。

### 9. 不归档的 skill

`docs/praxis/` 默认归档只有 5 个: `think` / `plan` / `read` / `design-ui` / `learn`。
不归档: `write-code`(产出是代码文件)/ `write-prose`(用户决定发布位置)/ `review`(verdict 当下决策)/ `debug`(修复在代码里固化)。

### 10. 还是模糊 — 兜底

两个 skill 都可能匹配时:
1. 读两个 SKILL.md 的 description 反触发段("Not for X")
2. 用排除法
3. 还是模糊 → 集中问用户(参 `rules/anti-patterns.md` #8 — 不连环问)

---

## 常见串联工作流

skill 之间不自动转接;转换需用户手动触发。每个 skill 完成后停下来等用户决定下一步。

### 工作流 A: 新功能/架构 (think → plan → write-code → review)

```
fuzzy idea → think → docs/praxis/think/<slug>.md
                ↓ 用户说"拆步骤"
              plan → docs/praxis/plan/<slug>.md (引用 think)
                ↓ 用户说"开干"
        write-code → 改代码
                ↓ 用户说"看看"
            review → verdict
```

### 工作流 B: 研究/写作 (read → learn → write-prose)

```
URL/PDF → read → docs/praxis/read/<slug>.md
            ↓ 用户说"学/整合"(≥ 2 份 read)
          learn → docs/praxis/learn/<slug>.md (消费多份 read)
            ↓ 用户说"润色"
       write-prose → 公开发布文字
```

### 工作流 C: bug 修复 (debug → review)

```
出错 → debug → 找根因 + 最小修复 + 回归测试
          ↓ 用户说"看看修得怎么样"
        review → verdict
```

### 工作流 D: UI 设计 (think → design-ui → write-code)

```
fuzzy 设计 → think → docs/praxis/think/<slug>.md
                ↓ 用户说"出方案"
          design-ui → docs/praxis/design-ui/<slug>.md (消费 think)
                ↓ 用户说"实现"
        write-code → 消费 design-ui
```

---

## 每个 skill 的反触发摘要

| Skill | "Not for" 反触发场景 |
|---|---|
| `think` | 已是清晰目标 + 约束;小修小补;bug 修复 |
| `plan` | fuzzy / 不可验证目标(→ think);单一动作(任务 < 3) |
| `debug` | feature work(→ think / plan);代码评审(→ review) |
| `read` | 本地代码文件(直接 Read 工具);无 URL/PDF 的对话 |
| `write-code` | fuzzy goals(→ think);代码评审(→ review);bug 修复(→ debug) |
| `review` | 重写产物(→ write-code);无 goal/constraints(先索取) |
| `design-ui` | 单属性微调(→ write-code);后端逻辑;数据管道 |
| `write-prose` | commit message;代码注释;inline doc |
| `learn` | 单次浏览(→ read);材料 < 2 份(先补 read) |
