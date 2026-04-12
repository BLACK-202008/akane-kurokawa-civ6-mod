---
name: civ6-art-resources
description: Use when a Civilization VI mod needs icons, DDS textures, `.dep`, `ArtDef`, XLP/BLP, loading portraits, or 3D unit presentation; also relevant for Civ6 美术资源链、单位成员复用、贴图导入和 ArtDef 依赖问题.
---

# Civ6 美术资源链

## Overview
这项技能用于处理 Civ6 的 UI 图标链和 3D 美术链。最重要的原则是从真实样本裁剪，不从空白模板猜结构。

## When to Use

- 新单位需要 3D 表现
- 新文明或领袖需要旗帜、肖像、图集
- `.dep`、`ArtDef`、XLP/BLP 链出问题
- 图标链和 3D 链开始分离

## Quick Reference

- UI 图标链：`IconTextureAtlases` + `IconDefinitions` + DDS
- 3D 链：`.dep` + `ArtDefs/*.artdef`
- `.dep` 里的 `ArtDefDependencyPaths` 优先沿用真实样本的裸文件名
- 复用原版成员时，先改最少字段

## Implementation

- 完整参考见 [reference.md](reference.md)
- 优先对照当前仓库 `Akane_Art.dep`、`ArtDefs/Units.artdef` 和 `TXHBalance`

## Common Mistakes

- 手写简化版 ArtDef 结构
- `.dep` 里把依赖路径写成错误形式
- 图标链、加载图、3D 资源链混在一起排错
