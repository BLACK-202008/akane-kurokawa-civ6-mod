---
name: civ6-debugging
description: Use when debugging a Civilization VI mod with `Database.log`, `Lua.log`, `Modding.log`, `DebugConfiguration.sqlite`, cache directories, or crash triage; also relevant for Civ6 图标异常、前端回退、SQL 未入库、Lua 不触发、启动崩溃.
---

# Civ6 日志与调试

## Overview
这项技能用于给 Civ6 模组故障排查定顺序。原则是先确认改动真的部署了，再按日志、缓存库和资源链逐层收窄。

## When to Use

- SQL 没进库
- 图标、加载页、领袖选择页异常
- Lua 不触发或读档状态不对
- 早期崩溃或进游戏后崩溃

## Quick Reference

- 先看 `Database.log`、`Lua.log`、`Modding.log`
- 前端问题常要查 `DebugConfiguration.sqlite`
- 早期崩溃先隔离 `Cache` 与 `PackageTemp`
- 改动后先确认仓库已经同步到测试目录

## Implementation

- 完整参考见 [reference.md](reference.md)
- 本机日志、缓存和部署状态见 [../shared/local-environment.md](../shared/local-environment.md)

## Common Mistakes

- 盯着旧日志目录判断
- 数据没同步到测试目录就开始追 Lua
- 只看文件，不查缓存数据库实际行
