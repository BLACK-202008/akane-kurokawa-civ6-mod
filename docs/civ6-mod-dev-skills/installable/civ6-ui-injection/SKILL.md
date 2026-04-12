---
name: civ6-ui-injection
description: Use when extending or replacing Civilization VI UI with `AddUserInterfaces`, `ReplaceUIScript`, `InstanceManager`, `ContextPtr`, or panel injection patterns; also relevant for Civ6 界面加按钮、挂面板、替换原版脚本.
---

# Civ6 UI 注入与替换

## Overview
这项技能用于向原版 Civ6 UI 加功能，或在必须时替换整段脚本。首选轻量挂接，最后才是全量替换。

## When to Use

- 往现有面板加按钮、浮层、状态条
- 需要 `AddUserInterfaces` 或 `ReplaceUIScript`
- 需要 `InstanceManager` 动态生成控件
- 需要按资料片分别替换 UI

## Quick Reference

- 新增面板优先 `AddUserInterfaces`
- 小改动优先包裹原函数，不要立刻全替换
- 真替换时按 `BaseGame/Expansion1/Expansion2` 分开
- `InstanceManager` 适合列表和重复控件

## Implementation

- 完整参考见 [reference.md](reference.md)
- 与当前仓库 UI 对照时，优先看 `UI/Akane_TopPanel.*` 和 `UI/Akane_UnitPanel_*`

## Common Mistakes

- 为一个小需求直接全量 `ReplaceUIScript`
- 不按资料片拆分替换文件
- 忘了把新增 UI 文件加入打包和导入链
