---
name: civ6-database-definitions
description: Use when editing Civilization VI gameplay data in XML or SQL, especially for Civ6 单位、建筑、文明、领袖、Modifier、Requirement, balance changes, or new content definitions that must stay consistent with text and upgrade chains.
---

# Civ6 XML/SQL 数据定义

## Overview
这项技能用于管理 Civ6 的数据库层定义。核心目标是把新内容链和旧内容修改链分清楚，并避免只改半条链。

## When to Use

- 调整数值、政策、建筑、区域、单位
- 新增单位、文明、领袖、Modifier、Requirement
- 需要 `INSERT OR IGNORE`、`INSERT OR REPLACE` 或 `SELECT` 复制
- 文本描述和数据效果必须同步

## Quick Reference

- 新内容顺序：`Types -> 主表 -> TypeTags/AIInfos/Upgrades -> Modifiers/Requirements -> 文本`
- 修改原版多用 `SQL`
- 声明新行多用 `XML`
- 改单位时同步检查对应 UU、升级链和描述文本
- 改建筑时同步检查对应 UB 和描述文本
- 改区域时同步检查对应 UD 和描述文本

## Implementation

- 完整参考见 [reference.md](reference.md)
- 与本地样本对照时，优先看仓库内 `Data/` 与 `TXHBalance`

## Common Mistakes

- 新单位漏掉 `UnitAiInfos` 或升级链
- 只改基准单位，忘了特色替代
- 幂等数据用普通 `INSERT`，重复构建后出问题
