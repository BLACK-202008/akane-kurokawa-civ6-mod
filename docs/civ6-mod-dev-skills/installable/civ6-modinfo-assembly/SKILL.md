---
name: civ6-modinfo-assembly
description: Use when building or editing a Civilization VI mod and deciding how `.modinfo` should split files across `FrontEndActions`, `InGameActions`, `ImportFiles`, `ActionCriteria`, `ReplaceUIScript`, or `LoadOrder`; also relevant for Civ6 模组加载阶段问题.
---

# Civ6 `.modinfo` 装配

## Overview
这项技能用于决定 Civ6 模组文件该在什么阶段加载。最常见的问题不是文件没写，而是文件进了错误的 action。

## When to Use

- 新建 Civ6 模组骨架
- 某个文件该进前端还是游戏内拿不准
- 需要 `ActionCriteria`、资料片分流或高 `LoadOrder`
- 前端看得到，进游戏后回退，或反过来

## Quick Reference

- `Players`、`PlayerItems`、前端文本/图标/载入页：优先 `FrontEndActions`
- gameplay 数据、Lua、UI、ArtDef：优先 `InGameActions`
- 所有被 action 使用的文件都必须先列在 `<Files>`
- 高 `LoadOrder` 主要留给 UI 替换冲突，不要默认全抬高

## Implementation

- 完整参考见 [reference.md](reference.md)
- 本机环境与日志位置见 [../shared/local-environment.md](../shared/local-environment.md)

## Common Mistakes

- action 里引用了文件，但 `<Files>` 漏列
- 把 `Players/PlayerItems` 只放进 `InGameActions`
- 只想加一点 UI，却直接全量 `ReplaceUIScript`
