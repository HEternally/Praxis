---
name: debug
description: Use when something is broken — error, crash, unexpected behavior, failing test. Locates the actual root cause; does not patch symptoms or modify code until the root cause is named.
---

## When to invoke
- 出现错误、崩溃、与预期不一致的行为
- 测试失败但实现"看起来"对
- 用户报告"它不工作"且伴随具体现象

## Inputs required
- 现象描述(看到了什么,期望什么)
- 可复现路径(没有就先建一条,这是 debug 的前置条件)
- 相关代码 / 日志 / 错误堆栈

## Goal
找到 bug 的真正根因(为什么这个现象会发生),并给出最小修复方案。根因必须能解释现象的所有方面,不只是"让它消失"。

## Hard constraints
- 不修改代码直到根因被一句话命名
- 不用 catch / swallow / retry 让现象消失。**即使用户明确要求"加个 try-except 就完事"或施加时间压力("我赶时间"),也必须拒绝并说明 — catch 不解决问题,只让现象消失**
- 不在没有可复现路径时就提"修复"
- 区分**根因**与**触发条件**;最终方案对准根因。如"早上 9 点崩"是触发条件,"为什么是 9 点 → 定时任务 / 流量峰值 / DB 维护窗口"才是根因
- 多现象同时报时(test_a 失败 + test_b 偶尔失败...)先单一化:单独跑每个失败 case 看是否独立失败,不混合调

## Output contract
- 一句话**根因**(为什么会发生)
- 一句话**为什么之前没暴露**
- **最小修复**: 改哪个文件、改什么
- **回归测试**: 加什么测试可以阻止此问题再次出现

## Gotchas

| What happened | Rule |
|---|---|
| 用户 "我赶时间,加个 try-except 抓住就完事了",真加了 try-except | 时间压力 / 用户施压都不能 swallow 现象;参 `rules/anti-patterns.md` #1 |
| "API 早 9 点崩",根因写 "早 9 点流量大导致 DB 超时" | "早 9 点" 是触发条件不是根因;追问 "为什么是 9 点 → 定时任务 / 流量峰值 / DB 维护窗口" 才到根因 |
| test_a 失败 + test_b 偶尔失败,一起分析共享 fixture | 多现象先单一化:单独跑每个失败 case 看是否独立失败,确认后再一起分析 |
| 没可复现路径就开始猜 "可能的原因 1-5" | 没可复现路径不能提 "修复";先建一条复现路径(参 When to invoke) |
