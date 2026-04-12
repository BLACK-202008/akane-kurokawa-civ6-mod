# 技能 04: Gameplay Lua

## 适用场景

- 效果依赖单位充能、城市是否已触发、玩家冷却、全国 Buff 层数
- 需要处理 `GameEvents`、读档恢复、到期清算
- 需要响应 `LuaEvents` 或 UI 主动调用

---

## 核心模式

### 状态存储（读档安全）

```lua
-- 定义 Property Key
local PROPERTY_MY_STATE = "MY_MOD_STATE"

-- 写入状态
local function SaveState(player, value)
    player:SetProperty(PROPERTY_MY_STATE, value)
end

-- 读取状态
local function LoadState(player)
    local value = player:GetProperty(PROPERTY_MY_STATE)
    return tonumber(value) or 0
end

-- 单位/城市也支持 Property
unit:SetProperty("CHARGES", 3)
city:SetProperty("TRIGGERED", 1)
```

### 事件驱动

```lua
-- Gameplay 层事件：当前项目已验证
GameEvents.PlayerTurnStarted.Add(OnTurnStarted)
GameEvents.CityBuilt.Add(OnCityBuilt)

-- 自定义脚本事件：当前项目的实际模式
local MY_EVENT = "MY_CUSTOM_EVENT"
GameEvents[MY_EVENT].Add(OnCustomEvent)

-- UI 或单位命令侧触发
local params = {}
params[UnitCommandTypes.PARAM_NAME] = MY_EVENT
UnitManager.RequestCommand(unit, UnitCommandTypes.EXECUTE_SCRIPT, params)
```

```lua
-- UI 层事件要和 gameplay 层分开看
Events.UnitMoved.Add(OnUnitMovedUI)
Events.LocalPlayerChanged.Add(OnLocalPlayerChanged)
```

**说明：**
- 当前仓库与已验证样本里，能直接对上的事件类型是 `GameEvents.PlayerTurnStarted`、`GameEvents.CityBuilt`、自定义 `GameEvents[EVENT_NAME]` 和 UI 层的 `Events.UnitMoved`。
- 本文档不再把 `GameEvents.OnUnitMoved` 记为“当前已验证模式”；如果你需要单位移动触发，先以 `Events.UnitMoved` 或现有样本为准，再决定是否扩展。
- 不要把 UI `Events.*` 和 gameplay `GameEvents.*` 混写成一层。

### 读档恢复

```lua
-- 关键：脚本加载时立即恢复状态
local function RestoreState()
    local aliveMajors = PlayerManager.GetAliveMajors()
    if aliveMajors == nil then return end

    for _, player in ipairs(aliveMajors) do
        local state = LoadState(player)
        if state > 0 then
            -- 重新应用效果，如 AttachModifierByID
            player:AttachModifierByID("MY_MODIFIER")
        end
    end
end

-- 必须在脚本末尾调用
RestoreState()
```

### UI 通信

```lua
-- 暴露给 UI 的 API
ExposedMembers.MyMod = ExposedMembers.MyMod or {}
ExposedMembers.MyMod.GetState = function(playerID)
    local player = Players[playerID]
    if player == nil then return 0 end
    return LoadState(player)
end

ExposedMembers.MyMod.RequestAction = function(playerID, action)
    -- 执行逻辑并返回结果
    return true, "LOC_SUCCESS_MESSAGE"
end
```

---

## Modifier 附加模式

### 动态附加

```lua
-- 附加 Modifier
player:AttachModifierByID("MY_MODIFIER")
city:AttachModifierByID("MY_CITY_MODIFIER")

-- 批量附加
local MODIFIERS = { "MOD_1", "MOD_2", "MOD_3" }
for _, modId in ipairs(MODIFIERS) do
    player:AttachModifierByID(modId)
end
```

### 正负 Modifier 对消

```lua
-- 加 Buff
local function ApplyBuff(player)
    player:AttachModifierByID("MY_BUFF_POSITIVE")
end

-- 减 Buff（用负数值的 Modifier 撤销效果）
local function RevertBuff(player)
    player:AttachModifierByID("MY_BUFF_NEGATIVE")
end
```

---

## 数据访问 API

### GameInfo（静态数据库）

```lua
-- 查询单位
local unitDef = GameInfo.Units["UNIT_MY_UNIT"]
print(unitDef.Cost, unitDef.Combat)

-- 遍历
for row in GameInfo.Units() do
    print(row.UnitType, row.Name)
end

-- 获取 Index
local unitIndex = GameInfo.Units["UNIT_MY_UNIT"].Index
```

### Players（动态数据）

```lua
local player = Players[playerID]

-- 组件访问
local cities = player:GetCities()
local techs = player:GetTechs()
local culture = player:GetCulture()
local treasury = player:GetTreasury()

-- 属性访问
local goldYield = treasury:GetGoldYield()
local scienceYield = techs:GetScienceYield()
```

### City/Unit

```lua
-- 城市
local cityX, cityY = city:GetX(), city:GetY()
local population = city:GetPopulation()
local districts = city:GetDistricts()

-- 单位
local unitType = unit:GetType()
local owner = unit:GetOwner()
local x, y = unit:GetX(), unit:GetY()
```

---

## 最小工作流

1. 定义清楚状态挂在哪：`City`、`Player`、`Unit` 各自保存什么属性
2. 把属性 key 集中命名，再在脚本里统一读写
3. 用 `GameEvents`/`LuaEvents` 处理触发时机，用 `AttachModifierByID` 把效果落回游戏系统
4. 所有跨回合存在的状态都要存进 property，而不是只留在 Lua 变量里
5. 若 UI 要读运行时状态，给出明确的 `ExposedMembers` API

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 状态只存在 local 变量 | 读档丢失 | 用 SetProperty/GetProperty |
| 只处理加 Buff，不处理负向清算 | 效果残留 | 配套写负数值 Modifier |
| 不检查 owner 上下文 | 事件串对象 | 验证 unit:GetOwner() == playerID |
| UI 直接读取脚本内部表 | 后续一改就崩 | 通过 ExposedMembers API 访问 |
| 脚本末尾没调用恢复函数 | 读档后状态不正确 | 必须调用 RestoreState() |
| 混用 `GameEvents` 和 `Events` | 脚本加载正常但逻辑不触发 | 先分清 gameplay 层与 UI 层 |

---

## 本地样例

- `Scripts/Akane_Gameplay.lua` - 单位演出、城市触发、全国 Buff
- `Scripts/Akane_ModeSystem.lua` - 模式冷却、金钱奖励、ExposedMembers

## 社区参照

- `QuickDeals/gameplay/qd_cachemanager.lua` - 缓存层和 ExposedMembers 模式
