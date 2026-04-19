# 技能 02: XML/SQL 数据定义

## 适用场景

- 调整单位、建筑、区域、政策、特性数值
- 新增单位、区域、文明、领袖、政策卡、修正器与需求集
- 需要保证"数据改动"和"文本描述"同步

---

## 核心模式

### 新内容定义顺序

```
Types → 主表定义 → TypeTags/AIInfos/Upgrades → Modifiers/Requirements → 文本
```

### 修改现有数据

```sql
-- 直接修改
UPDATE Units SET Cost=350 WHERE UnitType='UNIT_MUSKETMAN';

-- 幂等插入（避免重复构建报错）
INSERT OR IGNORE INTO Types (Type, Kind) VALUES ('MY_NEW_UNIT', 'KIND_UNIT');
INSERT OR REPLACE INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('MY_REQUIREMENT_SET', 'REQUIREMENTSET_TEST_ALL');
```

### SELECT 复制模式

从现有单位复制属性，只修改需要的字段：

```sql
-- 从火枪手复制，创建新单位
INSERT INTO Units (UnitType, Cost, Combat, BaseMoves, Domain, FormationClass)
SELECT 'UNIT_MY_MUSKETMAN', 350, Combat + 5, BaseMoves, Domain, FormationClass
FROM Units WHERE UnitType = 'UNIT_MUSKETMAN';
```

---

## 新单位定义链

```xml
<GameInfo>
  <!-- 1. 注册类型 -->
  <Types>
    <Row Type="UNIT_MY_UNIT" Kind="KIND_UNIT"/>
  </Types>

  <!-- 2. 单位主表 -->
  <Units>
    <Row
      UnitType="UNIT_MY_UNIT"
      Cost="120"
      Maintenance="2"
      BaseMoves="2"
      BaseSightRange="2"
      Domain="DOMAIN_LAND"
      FormationClass="FORMATION_CLASS_LAND_COMBAT"
      PromotionClass="PROMOTION_CLASS_MELEE"
      Name="LOC_UNIT_MY_UNIT_NAME"
      Description="LOC_UNIT_MY_UNIT_DESCRIPTION"
      PurchaseYield="YIELD_GOLD"
      PrereqTech="TECH_BRONZE_WORKING"
    />
  </Units>

  <!-- 3. 类型标签（用于升级链、政策等） -->
  <TypeTags>
    <Row Type="UNIT_MY_UNIT" Tag="CLASS_LANDCIVILIAN"/>
  </TypeTags>

  <!-- 4. AI 信息 -->
  <UnitAiInfos>
    <Row UnitType="UNIT_MY_UNIT" AiType="UNITAI_CIVILIAN"/>
  </UnitAiInfos>

  <!-- 5. 升级链 -->
  <UnitUpgrades>
    <Row Unit="UNIT_MY_UNIT" UpgradeUnit="UNIT_NEXT_UNIT"/>
  </UnitUpgrades>
</GameInfo>
```

---

## Modifier/Requirement 系统

### 基本结构

```sql
-- 定义 Modifier（效果）
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
('MY_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 'MY_REQUIREMENT_SET');

-- 定义 Modifier 参数
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MY_MODIFIER', 'YieldType', 'YIELD_FOOD'),
('MY_MODIFIER', 'Amount', '5');

-- 绑定到对象
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_CIVILIZATION_MY_CIV', 'MY_MODIFIER');
```

### Requirement 定义

```sql
-- 定义 Requirement
INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('MY_CITY_HAS_DISTRICT', 'REQUIREMENT_CITY_HAS_DISTRICT');

INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('MY_CITY_HAS_DISTRICT', 'DistrictType', 'DISTRICT_CAMPUS');

-- 组成 RequirementSet
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('MY_REQUIREMENT_SET', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('MY_REQUIREMENT_SET', 'MY_CITY_HAS_DISTRICT');
```

---

## 动态 SQL 生成（BBG 模式）

为所有区域批量创建需求集：

```sql
-- 动态创建需求集
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType)
    SELECT 'MY_CITY_HAS_' || DistrictType, 'REQUIREMENTSET_TEST_ALL'
    FROM Districts;

-- 动态创建需求
INSERT INTO Requirements(RequirementId, RequirementType)
    SELECT 'MY_CITY_HAS_' || DistrictType || '_REQ', 'REQUIREMENT_CITY_HAS_DISTRICT'
    FROM Districts;

-- 绑定需求集与需求
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId)
    SELECT 'MY_CITY_HAS_' || DistrictType, 'MY_CITY_HAS_' || DistrictType || '_REQ'
    FROM Districts;

-- 动态设置参数
INSERT INTO RequirementArguments(RequirementId, Name, Value)
    SELECT 'MY_CITY_HAS_' || DistrictType || '_REQ', 'DistrictType', DistrictType
    FROM Districts;
```

**说明：**
- 这段模式直接参考 `BBG/sql/_utils.sql`。
- 如果缺了 `RequirementSetRequirements` 这一步，生成出来的是“空需求集”，名字对但完全不生效。

---

## 文件拆分与命名粒度（来自 TXHBalance 双重构）

两份 `TXHBalance` 的共同结论是：SQL/XML 的拆分粒度应该围绕“规则主题”和“依赖链”设计，而不是按文件大小随手切。

### 两种稳定拆法

| 策略 | 样例 | 优点 | 适用 |
|------|------|------|------|
| 主题顺序化拆分 | `01_units_and_prereqs.sql`、`02_siege_rules_and_policies.sql`、`03_economy_and_infrastructure.sql` | 一眼能看出执行顺序和主题边界；适合大型整合平衡包 | 需要严格控制编号与职责 |
| 类型目录下语义文件名 | `SQL/units_balance.sql`、`SQL/buildings_districts.sql`、`Text/text_civs_leaders.xml` | 文件名直接表达改动对象；中等模组维护成本低 | `.modinfo` 要承担更多编排职责 |

### 拆分规则

1. 一个数据库文件只负责一个“可描述的变更集”，例如“攻城规则”“经济与基础设施”“运行时支持对象生成”。
2. 如果某段 SQL 只是给 Lua 预生成 modifier、requirement、辅助表，单独拆为 `runtime_support` 一类文件，不要混进主平衡数值文件。
3. 基础规则、兼容补丁、前端参数、文本描述分开存放；不要把兼容模组覆盖文本塞回主文本文件。
4. 如果改动会同时触发“基准单位”和“对应 UU/UB/UD”连锁检查，尽量放在同一主题文件里，避免漏改。
5. 文件名要能直接映射到 `.modinfo` 的 action id；看到文件名就应知道它为什么存在。

### 文本拆分规则

- 文本可以按主题合并成一个 `balance_text.xml`，前提是这批文本都属于同一套平衡包并且通常一起加载。
- 文本也可以按对象拆成 `text_buildings_improvements.xml`、`text_civs_leaders.xml`、`text_new_units.xml`；这种更适合按类型集中的目录结构。
- 兼容文本始终独立，例如 `pen_wonder_compat.xml`；它的加载条件应由 `.modinfo` 显式控制。
- 前端专用文本如果只服务配置菜单，可以单独成文件；如果同一批文本既要前端显示又要游戏内显示，可以复用同一个 text 文件并分别挂到两个 action。

---

## 最小工作流

1. 判断是"声明新行"还是"修改旧行"：新内容优先 XML，修改用 SQL
2. 新内容定义顺序：Types → 主表 → TypeTags/AIInfos/Upgrades → Modifiers/Requirements → 文本
3. 改原版单位或建筑时，同步检查对应 UU/UB/UD
4. 需要幂等时用 `INSERT OR IGNORE` 或 `INSERT OR REPLACE`
5. 每次改动后都补文本，避免"效果改了，说明没改"

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 新单位缺 TypeTags | 无法正确分类 | 补充 CLASS_ 标签 |
| 新单位缺 UnitAiInfos | AI 不会使用 | 补充 AI 类型 |
| 只改基础单位，不改特色单位 | 某文明被隐性削弱/强化 | 检查 UU 并同步修改 |
| 需求集拆太散 | 追踪困难 | 集中命名，添加注释 |
| 用普通 INSERT 写配置数据 | 重复构建报错 | 使用 INSERT OR IGNORE |

---

## 本地样例

- `Data/Akane_Units.xml` - 新单位最小定义
- `Data/Akane_Modifiers.sql` - 复杂 Modifier/Requirement 链
- `TXHBalance/database.sql` - 大批量 UPDATE 和 INSERT OR IGNORE

- `TXHBalance/Balance/Database/*.sql` - 按主题和执行顺序拆分的整合型平衡文件
- `TXHBalance/SQL/*.sql` 与 `TXHBalance/Text/*.xml` - 按文件类型集中、由命名表达主题的轻量重构

## 社区参照

- `JFD Russia/Core/RussiaPeter_GameDefines.sql` - SELECT 复制模式、Trait 绑定
- `BBG/sql/_utils.sql` - 动态 SQL 生成
