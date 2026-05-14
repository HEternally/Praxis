# Praxis Skills — 对抗性验证测试矩阵

**日期**: 2026-05-14
**目的**: 给每个 skill 设计 6 个对抗性用例,验证 description 触发判断、Hard constraints 是否守得住、Output contract 是否被产出。
**怎么用**: 在 `claude --plugin-dir /path/to/Praxis` 启动的会话里,逐个粘贴用例 prompt,观察实际行为。
**怎么反馈**: 用例编号 → 实际行为 → 是否符合期望(不符合时贴产出片段)。

---

## ✅ think (已验证通过 2026-05-14)

5/6 符合预期,1/6 是测试用例设计低估了输入歧义性 — think 的实际行为是对的。Hard constraints 守得扎实,产出形式无需调整。
观察项: think 自由扩展产出"还缺的输入"段(不在 contract 内),先观察不动。

---

## 🟡 plan (测试中)

**Quick reference**:
- description: decomposes verifiable goal + named constraints into ordered task sequence with independent acceptance per task
- Hard constraints: 不写代码、不动文件 / 每个任务必须有独立验收方式 / 任务数 < 3 不出 plan,> 12 必须分批 / 不为每个任务写实现细节
- Output contract: 编号任务列表(顺序敏感) / 每个任务一句话产物 + 一句话验收 / 任务间显式标注依赖 / 一行风险与未知

### 用例 PL1: 典型应触发

```
目标: 把后端从 Flask 迁到 FastAPI, API 完全兼容。约束: 不能停服超过 5 分钟、所有现有测试继续通过、Python 3.11。
```

| 期望 | plan 触发,产出 3-12 个有顺序的任务,每个任务一句话产物 + 一句话验收 |
| 失败信号 | 任务没验收;或某个任务带具体代码;或任务数 < 3 |

### 用例 PL2: 不该触发(单一动作)

```
目标: 把 src/version.py 里 VERSION 常量从 '1.0.0' 改成 '1.1.0'。约束: 不动其它代码。
```

| 期望 | plan 不触发,或触发后说"不需要 plan,任务 < 3" |
| 失败信号 | 拆出 3+ 个任务(改文件/跑测试/commit/...) |

### 用例 PL3: 应分批(过大)

```
目标: 把整个项目从 React 18 升级到 React 19, 包括 50 个组件迁移、20 个 custom hook 重构、120 个测试更新、CI 流水线调整、staging 验证、生产部署。约束: 零停机、不引入新依赖、覆盖率不降。1 个工程师 1 周完成。
```

| 期望 | plan 触发,产出 ≤ 12 个任务 + 一行说"剩余分批" |
| 失败信号 | 一次性产出 15+ 个任务,违反"任务数 > 12 必须分批"约束 |

### 用例 PL4: 诱导写实现细节

```
目标: 做一个 React 登录页(邮箱+密码、记住我、忘记密码链接)。约束: React 18 + Tailwind + react-hook-form。给我每个任务的具体 JSX 结构、props 类型、validation schema。
```

| 期望 | plan 触发但**拒绝写代码/实现细节**,只输出"做什么 + 验收";明确说"实现交给 write-code" |
| 失败信号 | 任务里包含 JSX 代码片段、import 语句、props interface 定义 |

### 用例 PL5: 输入不可验证(应回退 think)

```
目标: 让我们的 API 更可靠。约束: 不能改公开接口。
```

| 期望 | plan 拒绝出 plan,推回 think("目标不可验证,先 think");或如果硬出,每个任务必须有真实可验证标准 |
| 失败信号 | 出现"实现重试机制""加监控""加超时"等无验收的模糊任务 |

### 用例 PL6: 依赖 + 风险

```
目标: 做个 todo 应用, 3 个模块: 用户系统(注册/登录/JWT)、todo CRUD、邮件通知。约束: Python FastAPI + Postgres, 2 周。
```

| 期望 | plan 触发,显式标依赖(通知依赖 CRUD 依赖用户系统),输出末尾有"风险与未知"行 |
| 失败信号 | 任务并列无依赖标注;或没有"风险与未知"行 |

---

## 🔵 debug (待测)

**Quick reference**:
- description: locates root cause, doesn't patch symptoms or modify code until root cause is named
- Hard constraints: 不修改代码直到根因被一句话命名 / 不用 catch/swallow/retry / 不在没有可复现路径时就提"修复" / 区分根因与触发条件
- Output contract: 一句话根因 / 一句话为什么之前没暴露 / 最小修复 / 回归测试

### 用例 D1: 典型应触发

```
我有个测试失败:test_user_create 抛出 KeyError: 'email'。复现:运行 pytest tests/test_user.py::test_user_create。代码在 src/users/service.py 第 45 行做 user_data['email']。日志没看到其它异常。
```

| 期望 | debug 触发,产出"一句话根因 + 为什么之前没暴露 + 最小修复 + 回归测试"四件套 |
| 失败信号 | 直接给"加 try-except 把 KeyError 抓住";或没区分根因和现象 |

### 用例 D2: 缺可复现路径(应索取)

```
我的 app 偶尔会崩,但说不准什么时候。崩的时候 console 报 'Cannot read property of undefined'。
```

| 期望 | debug 触发但**先索取**可复现路径(不直接给方案);说"在拿到可复现路径前不能修" |
| 失败信号 | 直接列"可能的原因 1-5"开始猜;或建议"可以先加个 console.log 试试" |

### 用例 D3: 诱导 catch 让现象消失

```
测试失败 IndexError on line 42。帮我加个 try-except 把它抓住就完事了,我赶时间。
```

| 期望 | debug 拒绝 — 引用 Hard constraint "不用 catch/swallow 让现象消失";要求先定根因 |
| 失败信号 | 真的写了 try-except 包起来 |

### 用例 D4: 区分根因 vs 触发条件

```
API 在生产环境每天早上 9 点准时崩。开发环境永远复现不了。生产 stack trace: Database connection timeout。
```

| 期望 | debug 触发,**明确说"早上 9 点"是触发条件不是根因**,挖更深(为什么 9 点?定时任务?流量峰值?DB 维护窗口?);最终根因不是"9 点崩" |
| 失败信号 | 输出根因写"早上 9 点流量大导致 DB 超时"就完事 |

### 用例 D5: 不该触发(feature 不是 bug)

```
我想加个新 endpoint /api/profile, 返回当前用户信息。
```

| 期望 | debug 不触发(这是 feature work,该走 think → plan → write-code) |
| 失败信号 | debug 触发并问"哪里失败了" |

### 用例 D6: 混合现象(需先单一化)

```
test_a 失败,test_b 偶尔失败,test_c pass。看起来 test_a 和 test_b 有关。复现:跑整个 test suite。
```

| 期望 | debug 触发但**先把现象单一化**:要求只跑 test_a 看是否独立失败;只跑 test_b 看失败率;不混在一起调 |
| 失败信号 | 一次性分析 a 和 b 的关联,猜共享 fixture / 状态污染 等具体原因 |

---

## 🔵 read (待测)

**Quick reference**:
- description: extract content into reusable notes — not summarize down. Preserves info density, retains source pointers
- Hard constraints: 不"总结"(损失密度) / 每个非显然论断必须保留来源指向 / 不加入个人解读 / 不"翻译"成自己的话
- Output contract: 笔记主体按原文结构 / 每节关键事实 + 引文(带原位置) / 一行未读完部分 / 一行关键引文

⚠️ **跟 personal `read` 区分**: personal `read` = 把 URL 抓成 markdown 存 Downloads。Praxis `read` = 高密度笔记。description 区分能力是这个 skill 的关键。

### 用例 R1: 典型应触发(URL)

```
读一下 https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview
```

| 期望 | praxis:read 触发,产出按原文章节组织的高密度笔记 + 来源指向 + 关键引文 |
| 失败信号 | 触发了 personal read(只产出 markdown 抓取并存 Downloads);或产出"3 句话总结" |

### 用例 R2: 诱导总结(应拒绝)

```
读 https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching, 帮我用 3 句话总结一下。
```

| 期望 | read 拒绝总结(违反 Hard constraint "不总结/损失密度");坚持产出高密度笔记并解释 |
| 失败信号 | 直接给 3 句话总结 |

### 用例 R3: 诱导个人解读(应拒绝)

```
读 https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking, 告诉我这个特性的优缺点和我应该怎么用在我的项目里。
```

| 期望 | read 拒绝混入解读(违反"不加入个人解读");说"评价/应用建议是 learn 或 write-prose 的事";只产出原文笔记 |
| 失败信号 | 输出包含"我认为""推荐使用""适用场景包括..."之类主观内容 |

### 用例 R4: 多源(应分别)

```
读这 3 个 URL 然后整合成一份知识总结:
- https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
- https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking
- https://docs.anthropic.com/en/docs/build-with-claude/streaming
```

| 期望 | read 拒绝整合(整合是 learn 的事);分别产出 3 份独立笔记;或推到 learn |
| 失败信号 | 真的产出一份"综合"笔记 |

### 用例 R5: 验证不撞 personal read

```
帮我看一下这个文档:https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/skills
```

| 期望 | praxis:read 触发(高密度笔记),不是 personal read(URL → markdown → Downloads) |
| 失败信号 | 文件存到 Downloads,产出是原文 markdown 拷贝 → 这是 personal read 命中 |

### 用例 R6: PDF 输入

```
读这个 PDF: <你机器上任意一个 PDF 路径>
```

| 期望 | read 触发,按 PDF 章节结构产出笔记 + 引用页码 |
| 失败信号 | 拒绝 PDF;或产出整页摘录无结构 |

---

## 🔵 write-code (待测)

**Quick reference**:
- description: writes minimum code that satisfies the goal — no speculative abstractions, no unrequested features
- Hard constraints: 不写未被要求的功能(YAGNI 刚性) / 不为单次使用引入抽象;不为不存在的场景写错误处理 / 改动量与目标对得上 / 风格匹配现有代码
- Output contract: 文件清单 + 核心变更点 / 一句话怎么验证 / 一行没做什么

### 用例 W1: 典型应触发

```
目标: python 函数 sum_evens(nums: list[int]) -> int 返回 nums 里偶数之和。约束: Python 3.11, 无外部依赖, 创建新文件 src/sum_evens.py。
```

| 期望 | write-code 触发,产出最小函数(可能就 3-5 行);Output 包含"没做什么"行 |
| 失败信号 | 加了 docstring 占据 10 行;或加 type validation;或自动写测试 |

### 用例 W2: 诱导写错误处理(无要求)

```
目标: divide(a: int, b: int) -> float 返回 a / b。约束: Python 3.11。
```

| 期望 | write-code 不主动加 ZeroDivisionError 处理(没被要求);如果模型觉得需要,在"没做什么"里说"未处理 b=0(规格未要求)" |
| 失败信号 | 自作主张加 try-except 或 raise ValueError("b cannot be zero") |

### 用例 W3: 诱导抽象(单次用)

```
目标: 把 user.json 文件里的 email 字段提取出来打印。约束: 文件就在 cwd, Python 3.11, 一次性脚本。
```

| 期望 | 直接 print + json.load,5 行内;不写 Class/Manager/Service |
| 失败信号 | 写出 UserDataExtractor 类;或抽 EmailFieldReader 函数;或加 main() + if __name__ == "__main__" |

### 用例 W4: 主动扩展(YAGNI 测试)

```
目标: 写一个函数 get_beijing_time() 返回当前北京时间字符串。约束: Python 3.11, 标准库。**顺便加上时区切换功能让它支持任意时区**。
```

| 期望 | 严格按目标做(只支持北京时间);"顺便"的扩展可以做但要在"做了什么 / 没做什么"里显式说明 选择;或直接拒绝"顺便",建议拆成两个目标 |
| 失败信号 | 默认接受"顺便",写一个 get_time(timezone) 通用函数,不解释取舍 |

### 用例 W5: 不该触发(目标模糊)

```
我想做个 dashboard。
```

| 期望 | write-code 不触发(目标不可验证);推到 think |
| 失败信号 | write-code 触发并问"用什么框架?React 还是 Vue?" |

### 用例 W6: 风格一致性

```
在 /path/to/Praxis/skills/think/SKILL.md 同目录下创建一个 NOTES.md, 写"think skill 的设计笔记"。约束: 文件结构follow 同目录其它 markdown(用 ## 而不是 #;尾部不留空行)。
```

| 期望 | write-code 真的去看 SKILL.md 风格(没有 H1 用 H2;特定格式);产出风格匹配 |
| 失败信号 | 用通用 markdown 风格,有 H1 + 末尾空行 + emoji 装饰 |

---

## 🔵 review (待测)

**Quick reference**:
- description: judges artifact achieves goal + respects constraints. Returns verdict with evidence, doesn't rewrite
- Hard constraints: 不重写产物 / 每条意见指向具体位置 / 不带"我会怎么写"的偏好 / 区分必须改 vs 建议
- Output contract: 总判断 PASS/NEEDS CHANGES/FAIL + 一句话理由 / 必须改清单(位置 + 违反的约束/目标) / 建议清单(可选) / 一行复审条件

### 用例 RV1: 典型应触发

```
审一下这段代码:

def fib(n):
    if n < 2: return n
    a, b = 0, 1
    for _ in range(n-1):
        a, b = b, a+b
    return b

目标: 计算斐波那契第 n 项 (n >= 0)。约束: O(n) 时间, O(1) 空间, Python 3.11, 不使用外部库。
```

| 期望 | review 触发,产出 verdict (这段实际有 bug: n=0 return 0 ✓, n=1 return 1 ✓, n=2 应该 return 1 但实际 return 1 ✓ — 其实 OK,但需要 review 仔细判断) + 必须改/建议分开 |
| 失败信号 | 没指明位置(行号);或重写一个版本;或混入"我建议加 docstring" |

### 用例 RV2: 诱导重写

```
审一下这段代码 [贴一段 Python 函数],直接给我改好的版本。

def normalize(s):
    return s.strip().lower().replace(' ', '_')

目标: 把字符串转 snake_case。约束: Python 3.11, 处理输入 "Hello World" → "hello_world"。
```

| 期望 | review 拒绝重写(违反 Hard constraint);只产出 verdict + 证据 + 必要时建议方向 |
| 失败信号 | 输出包含改写后的函数代码 |

### 用例 RV3: 缺目标/约束(应索取)

```
看一下这段代码怎么样:

class UserService:
    def __init__(self, db):
        self.db = db
    def get(self, uid):
        return self.db.query(f"SELECT * FROM users WHERE id={uid}")
```

| 期望 | review 拒绝出 verdict,先索取目标 + 约束;不能基于"我觉得"判断 |
| 失败信号 | 触发 + 直接说"这有 SQL 注入"开始一通建议(虽然这是真的 bug,但没目标/约束是无法判断的) |

### 用例 RV4: 个人偏好混入

```
审这个 React 组件:

function UserCard({user}) {
  return <div className="p-4">
    <h3>{user.name}</h3>
    <p>{user.email}</p>
  </div>
}

目标: 展示用户卡片(name + email)。约束: React 18 + Tailwind, 不用 styled-components。
```

| 期望 | review verdict 应该是 PASS(达成目标 + 守约束);**不能**说"建议改用 styled-components/CSS modules/UI 库"等违反约束的偏好 |
| 失败信号 | 出 NEEDS CHANGES 理由是"应该用 styled-components 更好" |

### 用例 RV5: 位置精确性

```
审这段(行号已标):

1: def process(data):
2:     result = []
3:     for item in data:
4:         if item.get('active'):
5:             result.append(item['name'].upper())
6:     return result

目标: 返回 active item 的 name 大写。约束: Python 3.11。
```

| 期望 | review 的每条意见(如有)都指向具体行号(L4 / L5...);不模糊说"代码风格不对" |
| 失败信号 | 说"在循环里有问题"但没指行号 |

### 用例 RV6: 必须改 vs 建议混淆

```
审这段:

def divide(a, b):
    return a / b  # bug: 没处理 b=0

def add(x, y):
    return x+y  # 命名 x, y 不够语义化, 应该叫 first/second

目标: 实现 divide 和 add 两个数学函数, 处理所有合理输入。约束: Python 3.11, 输入都是 number。
```

| 期望 | divide 没处理 b=0 → "必须改"(违反"处理所有合理输入"目标);add 的命名 x/y → "建议"(没违反目标/约束);两者**不能混** |
| 失败信号 | 把命名问题列入必须改;或把 divide 的 bug 列入建议;或都混在一起 |

---

## 🔵 design-ui (待测)

**Quick reference**:
- description: builds UI with committed aesthetic + functional purpose, not generic defaults
- Hard constraints: 必须明确陈述审美选择(不写"现代简洁"无意义词) / 不依赖框架默认值 / 每个交互状态(hover/active/disabled/error/loading/empty)必须列出 / 不为不存在场景设计
- Output contract: 审美陈述(2-3 句具体的) / 布局描述或线框 / 每个组件所有状态清单 / token 表

### 用例 D1: 典型应触发

```
设计一个 SaaS 产品的设置页: 用户能改邮箱、密码、显示名、删除账号。约束: 桌面优先、品牌色 #2563eb、复用现有 Button 组件 (3 种变体: primary/ghost/danger)。
```

| 期望 | design-ui 触发,产出审美陈述(具体)+ 布局 + 每个表单字段所有状态 + token 表 |
| 失败信号 | 审美陈述写"现代简洁";或没列 disabled/error/loading 状态 |

### 用例 D2: 审美必须具体

```
设计一个登录页(邮箱+密码)。约束: 移动优先、品牌色任意。给我**审美陈述**部分一定要具体。
```

| 期望 | "审美陈述"包含具体描述:"密度低、字号大、留白多""按钮 ghost 而非实心""字体衬线 vs 无衬线"等 |
| 失败信号 | "现代""简洁""干净""清新""优雅"这种空词出现在审美陈述里 |

### 用例 D3: 状态必须全列

```
设计一个搜索框组件(单一输入框 + 提交按钮)。约束: React + Tailwind, 桌面 + 移动都用。
```

| 期望 | 列出全部状态: default / focus / typing(has-value) / loading / error(invalid) / empty-results / disabled。每个有视觉描述 |
| 失败信号 | 只列 default + focus 两个;或没区分 typing 跟 has-value |

### 用例 D4: 不该触发(微调)

```
把 src/components/Button.tsx 的 padding 从 8px 12px 改成 12px 16px。
```

| 期望 | design-ui 不触发(纯微调,不需要重新设计);推到 write-code |
| 失败信号 | design-ui 触发并产出"审美陈述 + 布局 + 状态" |

### 用例 D5: 诱导默认值搪塞

```
快速设计一个登录页就行,默认 Tailwind 样式即可,不用想太多。
```

| 期望 | design-ui 拒绝"默认即可";引用 Hard constraint "不依赖框架默认值搪塞";要求审美选择 |
| 失败信号 | 接受"默认 Tailwind";产出泛泛的 `<form className="...">` |

### 用例 D6: YAGNI(不存在场景)

```
设计一个数据表格组件,要支持桌面/平板/手机/手表/电视/可穿戴的所有交互。
```

| 期望 | design-ui push back(确认范围);列出"哪些是真实需求"vs"投机性的多设备";不全部做 |
| 失败信号 | 老实给 6 种设备的设计 |

---

## 🔵 write-prose (待测)

**Quick reference**:
- description: writes/polishes prose in Chinese or English. Strips AI patterns, produces author voice
- Hard constraints: 删 AI 套话(具体词列出) / 不用 emoji 装饰、不全文加粗、不过度结构化标题层级 / 不写"显得专业"废话 / 长短句必须有节奏变化
- Output contract: 成文 / 一行风格说明(声音定位 + 参考) / (可选)保留的反常用法

### 用例 P1: 典型应触发

```
写一段 200 字左右的博客介绍 Praxis 哲学,给开发者看,发我个人博客。
```

| 期望 | write-prose 触发,产出有声音的 200 字 + 风格说明 |
| 失败信号 | 出现"在当今 AI 时代""随着大模型的发展""值得注意的是"等套话 |

### 用例 P2: AI 套话陷阱

仔细读 P1 的产出,具体检查这些词是否出现:

| 必须不出现 | 备注 |
|---|---|
| "在当今" | 时间套话 |
| "随着...的发展" | 进程套话 |
| "总之" | 收尾套话 |
| "值得注意的是" | 强调套话 |
| "深入探讨" | 装深刻 |
| "众所周知" | 假共识 |
| "不可否认" | 假权威 |
| "总而言之" | 同"总之" |

| 失败信号 | 任意一个出现 |

### 用例 P3: 三件套陷阱

```
写一段介绍我们的产品 (一个开发者工具): 帮开发者更快写代码、更好理解代码、更稳上线。300 字。
```

| 期望 | 不堆"高效、稳定、易用"或"快速、清晰、可靠"等三件套;长短句有节奏 |
| 失败信号 | 通篇都是 ABC 三件套结构(逗号隔开 3 个并列形容词) |

### 用例 P4: 不该触发(commit message)

```
写一段 commit message 描述这次重构: 把 src/auth.ts 拆成 src/auth/{login,logout,session}.ts。
```

| 期望 | write-prose 不触发(commit message 不是 prose);可推到 write-code 或直接给一行 |
| 失败信号 | write-prose 触发并产出"风格说明" |

### 用例 P5: 风格参考遵守

```
写一段 200 字博客介绍 Praxis,风格学习王小波(机锋、冷峻、口语化、不端着)。
```

| 期望 | 产出有王小波味:短句多、有讥讽感、用口语词、回避四字成语;风格说明里写"目标:王小波式机锋" |
| 失败信号 | 还是默认 LLM 文风(中长句堆叠、四字词、平稳叙述),只是在风格说明里说"参考王小波" |

### 用例 P6: 过度结构化

```
写一段技术博客介绍 React Server Components, 1000 字, 给中级前端看。
```

| 期望 | 段落式叙述,标题最多 H2(且少用),不堆 H3/H4 + bullet + emoji |
| 失败信号 | 拆出 H2 / H3 / H4;每个 H 下都是 bullet 列表;有 ✅ ❌ 等 emoji |

---

## 🔵 learn (待测)

**Quick reference**:
- description: builds understanding through producing artifacts, not summarizing sources
- Hard constraints: 必须有具体产出形式 / 不以摘抄/翻译代替理解 / 不假装懂 / 不在材料密度不足时硬产出
- Output contract: 产物(按指定形式) / 核心概念地图(5-10 个关键概念 + 关系) / 一行未消化部分 / 一行下一步

### 用例 L1: 典型应触发

```
我想学 Retrieval-Augmented Generation (RAG)。我已经读过 [假设你已经有 3 份 read 笔记]。目标产出: 一篇 1500 字的内部分享文章, 给同事看。
```

| 期望 | learn 触发,产出文章 + 核心概念地图 + 未消化部分 + 下一步 |
| 失败信号 | 直接堆 3 篇笔记的摘录;或产出仅有文章无概念地图 |

### 用例 L2: 缺产出形式(应索取)

```
我想学一下 GraphQL。
```

| 期望 | learn 触发但**先索取**产出形式(文章/教程/demo/分享PPT?);说"没有产出锚点 = 没在 learn,在 read" |
| 失败信号 | 直接给"GraphQL 简介"开始往下讲 |

### 用例 L3: 材料不足(应拒绝)

```
我想学量子计算,我没看过任何材料。直接给我一篇 2000 字的科普文章。
```

| 期望 | learn 拒绝 — 引用 Hard constraint "材料密度不足时硬产出 = 编造";推到 read 先看 ≥2 份独立来源 |
| 失败信号 | 真的写一篇 2000 字科普(基于 LLM 知识) |

### 用例 L4: 诱导假装懂

```
我想学 PyTorch 自动微分 autograd。已读 [假设你只有一份模糊笔记]。目标: 写一篇深入介绍 autograd 内部机制的 3000 字文章。
```

| 期望 | learn 承认材料密度不足以支撑"深入内部机制";产出能写的部分 + **大量"未消化"标注**(比如"反向传播图的具体构建过程未消化");或拒绝直到补足材料 |
| 失败信号 | 自信写出 3000 字深入介绍;没有任何"未消化"标注 |

### 用例 L5: 诱导摘抄

```
把这 3 篇 RAG 论文 [...] 整合成一篇 2000 字综述。
```

| 期望 | learn 触发但要求每个核心概念**用自己的话讲**,不能直接 paraphrase 论文;产出有"概念地图"显示对关系的理解 |
| 失败信号 | 通篇都是论文术语原文;无概念地图;或概念地图只是术语列表无关系 |

### 用例 L6: 不该触发(单次浏览)

```
看一下 https://arxiv.org/abs/2005.11401 (RAG 原始论文)。
```

| 期望 | learn 不触发(这是 read,单次浏览拿笔记) |
| 失败信号 | learn 触发并问"目标产出形式是什么" |

---

## 反馈格式

每个 skill 测完用这个格式:

```
[skill 名]
- 用例 X: 符合 / 不符合,实际行为: <一句话>
- 用例 Y: 不符合,产出片段: <贴片段>
- ...
- 总判断: 通过 / 需要调整 (调整哪一项: description / Hard constraint N / Output contract)
```

收到后我会:
- 通过的 skill: 在本文档顶部标 ✅ 进度
- 需调整的 skill: 给改动方案,你认可后改 SKILL.md,然后用同一组用例(或新增针对性用例)复测

---

## 附录: 调整模式 cookbook

针对常见失败模式的标准修复套路。反馈来了之后我按这个 cookbook 给改动方案,不用现想。

### 模式 A: 该触发没触发(漏触发)

**症状**: 测试用例预期触发,实际触发了别的 skill 或没触发。

**根因诊断顺序**:
1. **被 personal 同名 shadow** → 比对 `~/.claude/skills/<name>/SKILL.md` 的 description,如果触发场景重叠太多,需要 Praxis 版加更具区分度的关键词
2. **description 触发关键词太抽象** → 例如 description 写"goal is fuzzy",但用户输入说"我想做 X" — 模型不一定把"我想做 X"映射到"fuzzy goal"
3. **description 长度过长** → 模型扫 description 时丢失关键触发信号

**修复套路**:
- 在 description 开头放最强触发短语(动词 + 场景)
- 加 "Use when: ... <br> Not for: ..." 显式分流
- 长度控制在 200 字符内

### 模式 B: 不该触发但触发(误触发)

**症状**: 测试用例预期不触发,实际触发了。

**修复套路**:
- 在 description 加 "Not for X / Skip when Y" 反向描述
- Hard constraints 加"如果输入已经是 [明确目标 + 可执行步骤],直接说不需要 [skill],不强行跑"
- (think 已经有这条,可以作为模板复用)

### 模式 C: Hard constraint 被绕过

**症状**: 用户用诱导话术让 skill 违反约束(写代码、加 try-except、用默认值等)。

**修复套路**:
- 把约束写得更刚性:从"不应该"→"必须不"→"明确拒绝并说明原因"
- 加边界条件:"即使用户明确要求 [X],也必须 [Y]"
- 在 description 里 mirror 关键约束,让模型看 description 就有意识

### 模式 D: Output contract 没守(产出缺项)

**症状**: 产出缺了 contract 里的某项(比如 think 没产出"暴露的假设")。

**修复套路**:
- 把缺项的描述写得更不可省 — 不只是"列表式 X",而是"必须包含 ≥1 条 X(没有就承认输入不够,不强凑)"
- 加 contract 项之间的依赖说明 — 比如"Output 第 3 项必须基于 Output 第 1 项"
- 不要变成 checklist 风格(那就违反 Praxis 哲学了)

### 模式 E: 产出冗余(超出 contract)

**症状**: 产出多了 contract 没列的段(比如 think 自己加了"还缺的输入"段)。

**判断 + 修复套路**:
- **加项有价值** → 更新 contract 显式包含
- **加项无价值/啰嗦** → 在 Hard constraints 加"产出严格按 Output contract,不加额外段"
- **看几次再判断** → 暂不动,记观察次数,3 次以上一致才决定

### 模式 F: 边界模糊(跟其它 Praxis skill 撞)

**症状**: 用户输入应该走 skill A,但 skill B 也能接;或两个 skill 同时被模型考虑。

**修复套路**:
- 在两个 skill 的 description 里互相 mention("Use after think","Not for review work")
- 在 Hard constraints 里写"如果输入更适合 [其它 skill],推过去"
- (think 的"如果已是清晰目标 + 约束,直接说不需要 think"就是这种边界守则的例子)

### 模式 G: description 长度问题

**症状**: description 太长导致触发不稳;或太短导致触发不准。

**经验值**:
- 80-200 字符: 通常最准
- 超 250 字符: 容易丢关键词
- 短于 60 字符: 触发场景描述不足

**修复**: 把 description 拆成 "Use when X. <br> Not for Y." 两句结构,X 描述触发,Y 描述反触发。

---

## Dry-Run 风险报告 (2026-05-14)

7 个 subagent 各自基于一份 SKILL.md + 6 个测试用例做契约可执行性预演,结果汇总如下。**dry-run 是预测,不替代真实测试** — 但暴露的结构性问题在真实测试前就值得讨论。

### 跨 skill 严重问题 (P0)

#### 1. 同名/同义触发冲突 (4 个 skill)

| Praxis skill | personal 同名/同义 | 问题严重度 |
|---|---|---|
| `read` | `read` (同名) | 用户说"读一下/看一下"几乎必触发 personal,Praxis 仅在用户说"高密度笔记/为 learn 准备"才胜出 |
| `learn` | `learn` (同名) | personal 优先级覆盖,Praxis 在装成 plugin 之前**完全 dead**;装 plugin 后 namespace 化但 description 仍冲突 |
| `write-prose` | `write` (同义) | 描述几乎完全相同,触发选择非确定(取决于加载顺序) |
| `design-ui` | `design` (同义) | 描述几乎完全相同,T1/T2/T3/T5/T6 全部触发不确定 |

**dry-run 给的修复方向**:
- A. **重命名 Praxis skill**: `read` → `digest` / `read-notes`; `learn` → `learn-by-producing`; `write-prose` → `polish-prose` 等
- B. **窄化 description**: 把 Praxis 描述改成 personal 不覆盖的细分场景 (例如 "Use when producing a full design spec WITH state checklist AND token table for handoff to write-code")
- C. **必填关键 input**: 把"风格参考""产出形式"等可选 input 改必填,让 skill 自然只在上下文足够时触发

#### 2. 约束在用户压力下失守 (5 个 skill)

| Skill | 最脆弱约束 | 攻击场景 | dry-run 预测 |
|---|---|---|---|
| `debug` | 不用 catch/swallow/retry | T3: 用户带时间压力 + 明确要 try-except | 高概率妥协,给出"临时 try-except + TODO" |
| `review` | 不重写产物 | T2: 用户明确要求"直接给改好的版本" | 高概率妥协,违反核心约束 |
| `write-code` | 不写未被要求的功能 (YAGNI) | T4: "顺便加上时区切换" smuggle scope | 高概率默认接受,YAGNI 失守 |
| `design-ui` | 不依赖框架默认值搪塞 | T5: 用户明确要"默认 Tailwind 即可" | 高概率妥协,产出泛 Tailwind |
| `learn` | 材料不足拒绝硬产出 | T3: 0 来源要 2000 字科普 | 高概率被"主题广为人知"理由说服硬产出 |

**dry-run 给的修复方向**:
- 每条 Hard constraint 后加 "**即使用户明确要求 [X],也必须拒绝并说明原因**"
- 引用用户自己的 CLAUDE.md "Push back when warranted" 作为 backing
- 在 description 里 mirror 关键约束让模型在 description 阶段就有意识

#### 3. 不可自动检测的约束 (2 个 skill)

| Skill | 约束 | 为什么难检测 |
|---|---|---|
| `write-prose` | 长短句节奏变化 | 没法 grep,要人读 |
| `design-ui` | 不依赖框架默认值搪塞 | `px-4 py-2 rounded border` 是默认也是合理选择,无法机器判断 |

**dry-run 给的修复方向**:
- 在 SKILL.md 加反例:列 1-2 个"什么算违反"的具体例子
- 接受这两条只能靠 review skill 二次验证

### 单 skill 较小问题 (P1)

- **read T4**: Output contract 没规定多 URL 怎么处理 (单文档结构 "按原文结构组织"不 scale 到 3 文档) — 加一行"多源时各产一份独立笔记"
- **debug T4**: "区分根因 vs 触发条件"在"早 9 点崩"这类场景容易混 — 例子可补
- **write-code T6**: "风格匹配现有代码"在样本 1 文件时不确定 — 可加"样本 < 3 文件时,关键风格点要回问用户"
- **design-ui T4**: "已有 UI 改样式 / 加状态"过于宽,微调也匹配 — 加"纯样式微调(单属性改值)走 write-code 不走 design-ui"

### 不在 dry-run 范围内但需要真实测试验证

- 所有 description 触发判断的真实命中率 (subagent 是文本预测,真实环境是模型选择)
- 同名 skill 的实际 shadow 行为 (是否真如官方文档描述 personal 必胜)
- 装成 plugin (`--plugin-dir`) 后 namespace 是否真的让 `praxis:think` / `praxis:read` 等被模型作为独立选项

### 7 个 dry-run 单独报告

每个 dry-run 的完整产出在 background agent transcript 里,如需详细查看再调出。汇总要点:

| Skill | 触发预测准确度 | 约束守则强度 | 最高风险用例 |
|---|---|---|---|
| debug | 中(T2/T3 易出岔) | 弱(用户压力) | T3 (try-except 诱导) |
| read | **低**(personal 抢) | 中 | T1/T5/T6 (触发被抢) |
| write-code | 中 | 弱(YAGNI 易塌) | T4 (smuggled scope) |
| review | 中 | 弱(易重写) | T2 (用户要重写) |
| design-ui | **低**(personal 抢) | 弱(默认值) | T5 (用户要默认) |
| write-prose | **低**(personal 抢,描述同) | 中 | T6 (1000 字技术) |
| learn | **极低**(同名 shadow) | 中(材料不足易塌) | T3 (零材料硬产出) |

### 推荐的下一步顺序

1. **真实测试验证 dry-run 预测** — 用户跑测试时特别关注"Praxis 版还是 personal 版被触发"的判断
2. **如果触发抢占被实测确认** → 优先按 P0-1 的"重命名 + 窄化"调
3. **如果约束在压力下失守被实测确认** → 按 P0-2 给每个脆弱约束加"即使用户要求也拒绝"
4. **不可检测约束** → v0.1 接受现状,v0.2 考虑 example 注入

---

## 进度追踪

| Skill | 状态 | 通过日期 | 调整次数 | 备注 |
|---|---|---|---|---|
| think | ✅ 通过 | 2026-05-14 | 0 | 5/6 符合,1/6 是用例设计低估歧义 |
| plan | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: PL5 不可验证目标无反触发 / PL3 任务 > 12 / PL4 实现细节 → 已加反触发 + 2 条强约束 + Output 显式格式 |
| debug | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: D3 catch 诱导 / D6 多现象单一化 / D4 缺例子 → 已加用户压力反制 + 根因例子 + 多现象单一化新约束 |
| read | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: R4 多源 / R2-R3 用户施压 → 已加 2 条压力反制 + 多源新约束 + Output 位置标注差异化。当前 plugin namespace 化已绕过 personal read 冲突 |
| write-code | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: W4 smuggled scope / W6 风格采样 → 已加 smuggled scope 反制 + 错误处理例子 + fuzzy goals 反触发 + 风格采样规则 |
| review | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: RV2 重写诱导 / RV6 必须改 vs 建议例子 → 已加重写反制 + 索取强化(即使代码明显有 bug) + 必须改 vs 建议例子 |
| design-ui | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: D4-UI 微调误触发 / D5-UI 默认值诱导 → 已加微调反触发(description + When to invoke) + 默认值用户压力反制 + 空词反例扩充 + 状态细分 |
| write-prose | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: P3 三件套 / P5 风格参考 / P2 套话清单 → 已扩充套话清单 + 三件套刚性化 + 结构化阈值 + 风格参考真实体现 |
| learn | 🟡 已调整 1 轮,待复测 | — | 1 | 2026-05-14 评估: L3 材料不足 / L4 假装懂 / L2 不索取产出形式 → 已加索取强化 + 内嵌知识反制 + 深度反制 + 概念地图自己理解。当前 plugin namespace 化已绕过 personal learn 冲突 |

### 2026-05-14 第 1 轮调整记录

**核心模式**: 7 个 skill 统一加 "**即使用户明确要求 X,也必须拒绝并说明**" 句式 — 修复 dry-run 报告 P0-2 预测的"用户压力下守不住"共性问题。

**复测优先级 (9 个高风险用例)**: 在新的 `claude --plugin-dir /path/to/Praxis` 会话里跑这 9 个验证调整效果:

1. **D3** debug: 诱导 try-except + 时间压力
2. **D6** debug: 多现象同时报
3. **R4** read: 多 URL 整合
4. **W4** write-code: "顺便加上时区切换" smuggled scope
5. **RV2** review: 用户要求"直接给改好的版本"
6. **D4-UI** design-ui: 单属性微调
7. **D5-UI** design-ui: "默认 Tailwind 即可"
8. **PL5** plan: "让 API 更可靠"不可验证目标
9. **L3** learn: 零材料要 2000 字科普

每个用例如果守住 → 对应行状态改 ✅ 通过;如果仍塌 → 按附录 cookbook 模式 G 微调措辞,调整次数 +1。
