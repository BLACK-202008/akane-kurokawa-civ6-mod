# 技能 01: .modinfo 装配

## 适用场景

- 新建模组骨架
- 判断某个文件应该进 `FrontEndActions` 还是 `InGameActions`
- 同时兼容本体、Expansion1、Expansion2
- 需要兼容其他模组或配置开关

---

## 核心结构

> 下方是结构骨架，重点在 action 分层和字段位置；真正起手时应直接从当前仓库或 `TXHBalance.modinfo` 复制再改。

```xml
<?xml version="1.0" encoding="utf-8"?>
<Mod id="unique-uuid-here" version="1">
  <!-- 基础属性 -->
  <Properties>
    <Name>模组名称</Name>
    <Teaser>简短描述</Teaser>
    <Description>详细描述</Description>
    <Authors>作者</Authors>
    <AffectsSavedGames>0</AffectsSavedGames>  <!-- 仅UI模组设为0 -->
    <CompatibleVersions>2.0</CompatibleVersions>
  </Properties>

  <!-- DLC/资料片依赖 -->
  <Dependencies>
    <Mod id="1B28771A-C749-434B-9053-D1380C553DE9" title="Expansion: Rise and Fall" />
    <Mod id="4873eb62-8ccc-4574-b784-dda455e74e68" title="Expansion: Gathering Storm" />
  </Dependencies>

  <!-- 文件清单（必须列出所有要打包的文件） -->
  <Files>
    <File>Data/Gameplay.xml</File>
    <File>Scripts/Gameplay.lua</File>
    <File>Text/Text_zh_Hans_CN.xml</File>
    <File>Icons/Icons.xml</File>
  </Files>

  <!-- 前端加载（菜单阶段） -->
  <FrontEndActions>
    <UpdateDatabase id="Config">
      <File>Data/Config.sql</File>
    </UpdateDatabase>
    <UpdateText id="FrontEndText">
      <File>Text/Text_zh_Hans_CN.xml</File>
    </UpdateText>
    <UpdateIcons id="FrontEndIcons">
      <File>Icons/Icons.xml</File>
    </UpdateIcons>
    <ImportFiles id="FrontEndTextures">
      <File>Textures/Leader256.dds</File>
    </ImportFiles>
  </FrontEndActions>

  <!-- 游戏内加载 -->
  <InGameActions>
    <UpdateDatabase id="Gameplay">
      <File>Data/Gameplay.xml</File>
    </UpdateDatabase>
    <UpdateArt id="Art">
      <File>MyMod.dep</File>
    </UpdateArt>
    <AddGameplayScripts id="Scripts">
      <File>Scripts/Gameplay.lua</File>
    </AddGameplayScripts>
    <AddUserInterfaces id="UI">
      <File>UI/MyPanel.xml</File>
    </AddUserInterfaces>
    <ReplaceUIScript id="ReplaceUI">
      <Properties>
        <LuaContext>UnitPanel</LuaContext>
        <LuaReplace>UI/MyUnitPanel.lua</LuaReplace>
      </Properties>
    </ReplaceUIScript>
  </InGameActions>

  <!-- 条件加载 -->
  <ActionCriteria>
    <Criteria id="Expansion2">
      <GameCoreInUse>Expansion2</GameCoreInUse>
    </Criteria>
  </ActionCriteria>
</Mod>
```

---

## Action 类型对照表

| Action | 用途 | 常见阶段 |
|--------|------|----------|
| `UpdateDatabase` | 加载 SQL/XML 数据 | FrontEnd + InGame |
| `UpdateText` | 加载本地化文本 | FrontEnd + InGame |
| `UpdateIcons` | 加载图标定义 | FrontEnd + InGame |
| `UpdateArt` | 加载 .dep/ArtDef | InGame |
| `ImportFiles` | 导入文件（纹理、脚本等） | FrontEnd + InGame |
| `AddGameplayScripts` | 游戏逻辑脚本 | InGame |
| `AddUserInterfaces` | 新增 UI 面板 | InGame |
| `ReplaceUIScript` | 替换原版 UI | InGame |

---

## FrontEnd vs InGame 分离原则

| 内容 | 放置位置 | 原因 |
|------|----------|------|
| Players/PlayerItems 配置 | FrontEndActions | 领袖选择页需要 |
| 领袖/文明图标 | FrontEndActions | 选择页显示 |
| 载入图纹理 | FrontEndActions | 加载屏幕需要 |
| 游戏数据（单位、建筑） | InGameActions | 只在游戏内生效 |
| Modifier/Requirement | InGameActions | 只在游戏内生效 |
| Gameplay Lua | InGameActions | 游戏逻辑 |
| UI 替换脚本 | InGameActions | 游戏内界面 |

**关键点：** 同一文件可以同时在 FrontEndActions 和 InGameActions 中加载（如 Better Loading Screen）。

---

## ActionCriteria 高级用法

### 基础条件

```xml
<!-- 资料片检测 -->
<Criteria id="Expansion2">
  <GameCoreInUse>Expansion2</GameCoreInUse>
</Criteria>

<!-- 反向条件（非 XP1 且非 XP2） -->
<Criteria id="BaseGame">
  <GameCoreInUse inverse="1">Expansion1</GameCoreInUse>
  <GameCoreInUse inverse="1">Expansion2</GameCoreInUse>
</Criteria>
```

### 多条件组合

```xml
<!-- AND 逻辑：多个 Criteria 标签 -->
<UpdateDatabase id="Content">
  <Criteria>Expansion2</Criteria>
  <Criteria>HasDLC</Criteria>  <!-- 两个条件都满足才加载 -->
  <File>Data/Content.sql</File>
</UpdateDatabase>

<!-- OR 逻辑：在 Criteria 内使用 any="1" -->
<Criteria id="XP1_or_XP2" any="1">
  <GameCoreInUse>Expansion1</GameCoreInUse>
  <GameCoreInUse>Expansion2</GameCoreInUse>
</Criteria>
```

### DLC 和模组检测

```xml
<!-- DLC 检测 -->
<Criteria id="HasAztec">
  <ModInUse>dlc-aztec-id</ModInUse>
</Criteria>

<!-- 冲突模组排除 -->
<Criteria id="NoConflict">
  <ModInUse inverse="1">conflicting-mod-id</ModInUse>
</Criteria>
```

### 游戏设置检测

```xml
<Criteria id="VictoryCultural2">
  <ConfigurationValueMatches>
    <ConfigurationId>VictoryCulturalSetting</ConfigurationId>
    <Group>Game</Group>
    <Value>2</Value>
  </ConfigurationValueMatches>
</Criteria>
```

---

## 目录组织策略（来自 TXHBalance 双重构）

`TXHBalance` 的两份整理结果说明了一点：目录结构服务的是“人类维护”，真正决定加载结果的仍然是 `.modinfo`。当前验证过两种都可长期维护的组织方式：

| 策略 | 典型目录 | 优点 | 风险 | 适用 |
|------|------|------|------|------|
| 按子系统/加载阶段分层 | `Balance/Database`、`Balance/Text`、`BCY/Config`、`BCY/Database`、`BCY/Scripts`、`NewUnits/Database/UI/Text`、`Compat/Text` | 子系统边界清楚；更容易让目录结构直接映射到 `FrontEndActions` / `InGameActions`；适合整合型大模组 | 目录层级更深；跨子系统搜索时要多跳几层 | 一个模组里同时有平衡、配置、运行时 Lua、新单位、兼容补丁 |
| 按文件类型集中，由 `.modinfo` 显式编排 | `SQL/`、`Text/`、`XML/`、`Config/`、`BCY/`、`Scripts/` | 全局按类型检索快；中等体量模组更直观；迁移旧项目成本低 | 语义主要落在文件名与 action id 上；规模变大后更容易出现“一个目录装太多主题” | 规则集中、模块数不多、维护者更习惯按 SQL/XML/Text 分类 |

### 推荐混合做法

1. 先按“是否是独立子系统”拆第一层，例如 `BCY`、`NewUnits`、`Compat`。
2. 子系统内部再按文件类型拆第二层，例如 `Database` / `Text` / `UI` / `Scripts`。
3. 如果一个子系统体量很小，可以退化成 `SQL/`、`Text/`、`XML/` 的扁平结构，但要把语义写进文件名和 action id。
4. 不要把目录名当成加载顺序本身；顺序仍由 `.modinfo` 的 action 排列和 `LoadOrder` 明确声明。
5. 兼容补丁、前端配置、运行时支持这三类内容，最好始终独立于“主平衡文件”。

### `.modinfo` 与目录命名的映射规则

- 如果目录是按子系统拆的，`UpdateDatabase` / `UpdateText` id 也应体现子系统名，例如 `TXHBalance_BCY_CoreRules`、`TXHBalance_Balance_EconomyAndInfrastructure`。
- 如果目录是按文件类型拆的，文件名本身必须承载主题，例如 `units_balance.sql`、`text_civs_leaders.xml`，不要出现 `part1.sql`、`misc2.xml` 这类无语义名字。
- `<Files>` 建议与 action 的分组顺序保持接近，这样 diff 时更容易看出“哪个子系统少列了文件”。

---

## 最小工作流

1. 把内容按运行阶段拆开：配置库/前端文本/前端图标/前端贴图走 `FrontEndActions`，Gameplay 数据/Lua/UI/ArtDef 走 `InGameActions`
2. 所有要打包的文件先放进 `<Files>`
3. 根据内容类型选择 action：`UpdateDatabase`、`UpdateText`、`UpdateIcons`、`ImportFiles`、`UpdateArt`、`AddGameplayScripts`、`AddUserInterfaces`、`ReplaceUIScript`
4. 只有在确实要分资料片或规则集时才写 `ActionCriteria`
5. 给 UI 替换类动作留足 `LoadOrder`（建议 100000+）

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 文件未列入 Files | 加载失败 | 确保所有 action 引用的文件都在 `<Files>` 中 |
| Players/PlayerItems 只在 InGameActions | 选择页显示原版 | 配置数据库必须进 FrontEndActions |
| 忘记 ImportFiles 纹理 | 图标显示异常 | DDS 文件需要显式导入 |
| LoadOrder 过低 | UI 被覆盖 | UI 替换使用 100000+ |
| 未处理资料片差异 | 只在某个规则集生效 | 使用 ActionCriteria 分文件加载 |

---

## 本地样例

- `civi6_AkaneKurokawa_mod.modinfo` - 完整的前后端分离、三套 ReplaceUIScript、ActionCriteria
- `TXHBalance.modinfo` - 轻量级平衡模组，最小化配置

- `TXHBalance`（codex 版）- 目录按子系统和阶段分层，适合整合型模组
- `TXHBalance`（opus 版）- 目录按文件类型集中，依赖 `.modinfo` action id 和文件名表达语义

## 社区参照

- `BetterLoadingScreen.modinfo` - 前端+游戏内双加载
- `QuickDeals.modinfo` - AddGameplayScripts + AddUserInterfaces + ReplaceUIScript 组合
- `BetterBalancedGame.modinfo` - 大体量模组的 ActionCriteria 高级用法
