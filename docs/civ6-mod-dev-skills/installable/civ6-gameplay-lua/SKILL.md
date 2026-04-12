---
name: civ6-gameplay-lua
description: Use when a Civilization VI mod needs runtime state, `SetProperty/GetProperty`, `GameEvents`, `LuaEvents`, `ExposedMembers`, turn-based cooldowns, read-save restore, or unit/city/player logic that cannot be expressed purely in SQL or XML.
---

# Civ6 Gameplay Lua

## Overview
这项技能用于处理 Civ6 运行时逻辑。重点是把跨回合状态落到 property，把触发留给已验证的事件链。

## When to Use

- 充能、冷却、全国 Buff、城市或单位一次性触发
- 读档恢复后需要重建运行时状态
- UI 需要通过 `ExposedMembers` 调用 gameplay 逻辑
- 纯 SQL/XML 已经不够表达目标行为

## Quick Reference

- 跨回合状态优先 `SetProperty/GetProperty`
- 当前已验证的模式包括 `GameEvents.PlayerTurnStarted`、`GameEvents.CityBuilt`、自定义 `GameEvents[EVENT_NAME]`、UI 层 `Events.UnitMoved`
- UI 与 gameplay 事件层必须分开看
- UI 读状态时经由 `ExposedMembers`

## Implementation

- 完整参考见 [reference.md](reference.md)
- 先从仓库内 `Scripts/Akane_Gameplay.lua` 和 `Scripts/Akane_ModeSystem.lua` 对照

## Common Mistakes

- 状态只存在 Lua 局部表，读档后全丢
- 把 UI `Events.*` 当成 gameplay `GameEvents.*`
- 把未实证事件名当成当前项目标准
