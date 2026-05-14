# UI 状态清单

按组件类型展开的完整状态清单。SKILL.md 的 Hard constraint 引用本文件。

## 通用状态(所有交互组件最少要列)

- default — 静默状态
- hover — 鼠标悬停
- active — 鼠标按下中
- focus — 键盘焦点(无障碍必备)
- disabled — 不可交互
- loading — 异步操作中
- error — 输入或操作失败
- empty — 无数据

## input 类(text input / textarea / select / search)

- default: 无内容,placeholder 显示
- focus: 边框高亮 + 光标可见
- typing: 用户正在输入(focus + 有内容,可显示实时校验)
- has-value: 有内容 + 失去焦点(展示填好的值)
- error: validation 失败 + 错误信息
- disabled: 不可编辑(灰底)
- readonly: 仅展示(不同于 disabled — 可选择)

## list 类(列表 / 表格 / 网格)

- default: 有数据
- loading: 加载中(skeleton / spinner)
- empty: 无数据(空状态 placeholder + 引导动作)
- empty-results: 有过滤条件但 0 结果(跟 empty 区分,提示用户改条件)
- error: 加载失败(错误信息 + 重试按钮)
- partial: 加载了一部分,还有更多(分页 / infinite scroll)

## data 类(实时数据 / dashboard / 监控)

- fresh: 数据是最新的(< N 秒前)
- stale: 数据过期(> N 秒未刷新,显示时间戳)
- syncing: 正在拉新数据(细微 spinner)
- error: 拉取失败
- offline: 离线 / 网络断开

## button 类

- default / hover / active / focus / disabled
- pressed: toggle button 的 on 状态
- loading: 异步操作中(禁用 + spinner)
- success: 操作成功后短暂显示(✓)
- destructive: 危险操作的视觉(红色 / 警告)

## modal / dialog 类

- closed: 隐藏(不渲染或 display: none)
- opening: 动画中(背景渐入 + 内容缩放/滑入)
- open: 完全展开,内容可交互
- closing: 关闭动画中
- error-state: 内部表单或操作失败

## form 类(整体)

- pristine: 用户未交互过
- dirty: 有字段被改过(未保存 vs 已保存)
- validating: 异步校验中
- valid / invalid: 全字段校验结果
- submitting: 提交中
- submitted: 提交成功(短暂确认)
- failed: 提交失败

## 写出 Output contract 的格式

每个状态用一行描述视觉差异:

> - default: 边框 1px 灰 (#e5e5e5),底白
> - focus: 边框 2px 品牌色,subtle glow
> - typing: focus + 右侧 char count(小字)
> - has-value: 边框 1px 深灰,底白,无 placeholder
> - error: 边框 2px 红,下方红字错误信息
> - disabled: 边框 1px 浅灰,底浅灰,文字浅灰
