---
name: civ6-frontend-config
description: Use when a Civilization VI mod affects leader select, loading screens, icons, `Players`, `PlayerItems`, `LoadingInfo`, or front-end-only config tables; also relevant when Civ6 前端能选但进游戏回退，或图标显示异常.
---

# Civ6 前端配置与图标

## Overview
这项技能处理 Civ6 前端可见内容，包括选择页、图标图集和加载页信息。常见故障是 gameplay 数据正确，但前端配置链没补全。

## When to Use

- 领袖选择页、文明条目、载入页异常
- 图标不显示或尺寸链不完整
- 只在前端或只在游戏内生效，表现不一致
- 需要 `Players`、`PlayerItems`、`LoadingInfo`

## Quick Reference

- 前端配置优先单独放 `Config` 文件；结构化参数常用 XML，配置表改写也可用 SQL
- `Players`/`PlayerItems` 要覆盖 `Standard/Expansion1/Expansion2`
- 纹理文件名显式写成 `Textures/...dds`
- 缺加载页信息时直接查 `LoadingInfo`

## Implementation

- 完整参考见 [reference.md](reference.md)
- 调试时经常要结合 [../shared/local-environment.md](../shared/local-environment.md) 里的缓存库路径

## Common Mistakes

- 只写 gameplay 数据，没补配置库
- 只覆盖 `StandardPlayers`
- 图标定义在，纹理没导入
