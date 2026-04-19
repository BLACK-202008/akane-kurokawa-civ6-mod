# 技能 03: 前端配置与图标

## 适用场景

- 领袖选择页、文明条目、载入页、玩家面板信息
- 自定义文明/领袖在前端能选，但进游戏后回退，或反过来
- 图标显示异常

---

## Players/PlayerItems 配置

### 核心结构

```sql
-- Players 表（文明/领袖条目）
INSERT OR REPLACE INTO Players
(
  Domain, CivilizationType, LeaderType,
  CivilizationName, CivilizationIcon,
  LeaderName, LeaderIcon, Portrait,
  CivilizationAbilityName, CivilizationAbilityDescription,
  LeaderAbilityName, LeaderAbilityDescription
)
VALUES
(
  'Players:StandardPlayers',      -- 必须覆盖三个 domain
  'CIVILIZATION_MY_CIV',
  'LEADER_MY_LEADER',
  'LOC_CIVILIZATION_MY_CIV_NAME',
  'ICON_CIVILIZATION_MY_CIV',     -- 可复用原版图标
  'LOC_LEADER_MY_LEADER_NAME',
  'ICON_LEADER_MY_LEADER',
  'LEADER_MY_LEADER_NEUTRAL.dds', -- 肖像文件名
  'LOC_TRAIT_CIVILIZATION_MY_CIV_NAME',
  'LOC_TRAIT_CIVILIZATION_MY_CIV_DESCRIPTION',
  'LOC_TRAIT_LEADER_MY_LEADER_NAME',
  'LOC_TRAIT_LEADER_MY_LEADER_DESCRIPTION'
);

-- PlayerItems 表（特色项目显示）
INSERT OR REPLACE INTO PlayerItems
(
  Domain, CivilizationType, LeaderType,
  Type, Icon, Name, Description, SortIndex
)
VALUES
(
  'Players:StandardPlayers',
  'CIVILIZATION_MY_CIV',
  'LEADER_MY_LEADER',
  'DISTRICT_MY_DISTRICT',
  'ICON_DISTRICT_MY_DISTRICT',
  'LOC_DISTRICT_MY_DISTRICT_NAME',
  'LOC_DISTRICT_MY_DISTRICT_DESCRIPTION',
  10
);
```

### 必须覆盖的 Domain

```sql
'Players:StandardPlayers'     -- 本体
'Players:Expansion1_Players'  -- 兴衰
'Players:Expansion2_Players'  -- 风暴
```

---

## 图标定义链

### IconTextureAtlases（图集定义）

```xml
<GameInfo>
  <IconTextureAtlases>
    <Row Name="ATLAS_MY_LEADER" IconSize="32" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader32.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="45" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader45.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="48" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader48.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="50" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader50.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="55" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader55.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="64" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader64.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="80" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader80.dds"/>
    <Row Name="ATLAS_MY_LEADER" IconSize="256" IconsPerRow="1" IconsPerColumn="1" Filename="Textures/MyLeader256.dds"/>
  </IconTextureAtlases>
</GameInfo>
```

### IconDefinitions（图标映射）

```xml
<IconDefinitions>
  <Row Name="ICON_LEADER_MY_LEADER"
       Atlas="ATLAS_MY_LEADER"
       Index="0"/>
</IconDefinitions>
```

### IconAliases（复用原版图标）

```xml
<IconAliases>
  <Row Name="ICON_CIVILIZATION_MY_CIV"
       OtherName="ICON_CIVILIZATION_JAPAN"/>
</IconAliases>
```

---

## 多尺寸图标规范

| 尺寸 | 用途 |
|------|------|
| 22 | 单位旗帜小图 |
| 32 | 列表图标 |
| 38 | 中等尺寸 |
| 45 | 选择页小图 |
| 50 | 标准尺寸 |
| 55 | 选择页中等 |
| 64 | 大尺寸 |
| 80 | 肖像缩略 |
| 256 | 大图/载入图 |

---

## LoadingInfo 配置

当前项目和 `Better Loading Screen` 用到的是同一条真实字段链：

```xml
<GameInfo>
  <LoadingInfo>
    <Row
      LeaderType="LEADER_MY_LEADER"
      ForegroundImage="LEADER_MY_LEADER_NEUTRAL.dds"
      BackgroundImage="MyLoadingBackground.dds"/>
  </LoadingInfo>
</GameInfo>
```

```sql
INSERT OR IGNORE INTO LoadingInfo
  (LeaderType, ForegroundImage, BackgroundImage, LeaderText, DawnOfManLeaderId)
SELECT
  LeaderType,
  LeaderType || '_NEUTRAL',
  LeaderType || '_BACKGROUND',
  'LOC_LOADING_INFO_' || LeaderType,
  LeaderType
FROM Leaders
WHERE InheritFrom = 'LEADER_DEFAULT'
  AND LeaderType NOT IN (SELECT LeaderType FROM LoadingInfo);
```

**说明：**
- `Akane_Loading.xml` 证明 `ForegroundImage / BackgroundImage` 是当前项目的实际链路。
- `BetterLoadingScreen_Database.sql` 证明 `LeaderText / DawnOfManLeaderId` 是补全加载页信息时的真实字段。

---

## 前端参数与文本的拆分策略（来自 TXHBalance 双重构）

`TXHBalance` 的两种重构都说明：前端配置至少要区分“参数定义”和“给玩家看的文本”，至于是合并还是分文件，取决于复用范围。

### 推荐判断

| 内容 | 推荐放法 | 原因 |
|------|------|------|
| 参数定义本体，例如 `Parameters`、`DomainValues`、`ParameterCriteria` | 单独放 `Config/` 或子系统自己的 `Config/` | 这部分是结构化前端配置，不应和大量通用文本混在一起 |
| 只服务前端选项页的说明文字 | 可独立成 `text_bcy_frontend.xml` 一类文件 | 前端语义清楚，后续搜索配置文案更快 |
| 同时用于前端与游戏内的共享文本 | 可以并入主题性 text 文件，例如 `balance_text.xml`，再分别挂到 FE / InGame action | 避免同一段文本维护两份 |
| 兼容特定模组的前端文本 | 单独放 `Compat/Text/` | 条件加载明确，避免污染基础文本包 |

### 实操规则

1. 参数表和文本表即使最后放在同一个子系统目录里，也要保持独立文件。
2. 如果某个前端子系统本身就是独立功能块，例如 BCY 选项，把它的 `Config`、文本、桥接 UI 放在同一子系统目录最清楚。
3. 如果文本需要同时在前端和游戏内出现，优先复用同一个 text 文件，而不是复制两份内容。
4. 如果按文件类型集中目录，至少保证文件名前缀能看出前端归属，例如 `text_bcy_frontend.xml`，不要出现含义模糊的 `text_misc.xml`。

---

## 最小工作流

1. 前端配置优先单独建 `Config.sql`，写 `Players` 与 `PlayerItems`，覆盖三个 domain
2. 领袖与单位图标先把 atlas 定义全，再写 `IconDefinitions`；能复用原版时用 `IconAliases`
3. `Filename` 明确写成 `Textures/...dds`，并在前端 action 中 `ImportFiles` 对应纹理
4. 若是加载页信息缺失，查 `LoadingInfo` 是否有行

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 只写了 gameplay 数据，没写配置库 | 选择页显示原版或空白 | 补 Players/PlayerItems |
| IconTextureAtlases 的 Filename 少前缀 | 图标不显示 | 写成 `Textures/xxx.dds` |
| 图标定义写了但没导入纹理 | 前端报错 | FrontEndActions 加 ImportFiles |
| 只覆盖 StandardPlayers | 资料片下回退 | 覆盖三个 domain |
| 只修图标，不验证 LoadingInfo | 加载页异常 | 检查 LoadingInfo 行 |

---

## 本地样例

- `Data/Akane_Config.sql` - Players/PlayerItems 完整示例
- `Icons/Akane_Icons.xml` - 多尺寸 atlas、IconDefinitions、IconAliases

- `TXHBalance/BCY/Config/options.xml` - 参数定义和 DomainValues 独立成前端配置文件
- `TXHBalance/Text/text_bcy_frontend.xml` 与 `Balance/Text/balance_text.xml` - 前端文案独立 vs 主题性合并两种做法

## 社区参照

- `BetterLoadingScreen_Database.sql` - LoadingInfo 修补
- `JFD Russia/Core/RussiaPeter_IconDefinitions.sql` - 成套单位旗帜/肖像 atlas
