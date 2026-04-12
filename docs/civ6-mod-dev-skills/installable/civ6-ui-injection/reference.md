# 技能 05: UI 注入与替换

## 适用场景

- 在现有界面加按钮、加浮层、加状态条
- 替换 UnitPanel、DiplomacyActionView、ProductionPanel 等原版脚本
- 在不重写整个界面的前提下，接入新的 Lua 交互

---

## 三种 UI 介入方式

### 方式 A：AddUserInterfaces（新增面板）

```xml
<AddUserInterfaces id="MyPanel">
  <Properties>
    <Context>InGame</Context>
    <LoadOrder>100001</LoadOrder>
  </Properties>
  <Items>
    <File>UI/MyPanel.xml</File>
  </Items>
</AddUserInterfaces>
```

### 方式 B：ReplaceUIScript（完全替换）

```xml
<ReplaceUIScript id="ReplaceUnitPanel">
  <Properties>
    <LoadOrder>100000</LoadOrder>  <!-- 高优先级 -->
    <LuaContext>UnitPanel</LuaContext>
    <LuaReplace>UI/MyUnitPanel.lua</LuaReplace>
  </Properties>
</ReplaceUIScript>
```

### 方式 C：轻量包装（推荐）

```lua
-- MyUnitPanel_Extension.lua
include("UnitPanel")  -- 先加载原版
include("MyUnitPanel")  -- 再加载扩展

-- 或者只包裹特定函数
local Original_OnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(...)
    Original_OnSelectionChanged(...)
    -- 添加你的逻辑
end
```

---

## InstanceManager 模式

用于动态创建和管理 UI 控件：

```lua
-- 创建实例管理器
local m_InstanceManager = InstanceManager:new(
    "MyInstance",       -- XML 实例名称
    "Root",             -- 根控件名称
    Controls.ParentStack -- 父控件
)

-- 获取实例
local instance = m_InstanceManager:GetInstance()
instance.NameLabel:SetText("Item Name")
instance.ValueLabel:SetText("100")

-- 重置所有实例
m_InstanceManager:ResetInstances()

-- 销毁所有实例
m_InstanceManager:DestroyInstances()
```

---

## 初始化模式

```lua
-- 文件头部
include("InstanceManager")
include("SupportFunctions")
include("Civ6Common")

-- 初始化函数
function Initialize()
    ContextPtr:SetInitHandler(OnInit)
    ContextPtr:SetRefreshHandler(OnRefresh)
end

function OnInit()
    -- 初始化控件
    Controls.MyButton:RegisterCallback(Mouse.eLClick, OnButtonClick)

    -- 注册事件
    Events.TurnBegin.Add(OnTurnBegin)
    Events.LocalPlayerChanged.Add(OnLocalPlayerChanged)
end

-- 文件末尾
Initialize()
```

---

## 控件操作 API

```lua
-- 文本
control:SetText(Locale.Lookup("LOC_TEXT_KEY"))

-- 图标
control:SetIcon("ICON_UNIT_WARRIOR")

-- 颜色
control:SetColor(UI.GetColorValueFromHexLiteral(0xFF00FF00))

-- 隐藏/显示
control:SetHide(true)

-- 回调
button:RegisterCallback(Mouse.eLClick, OnClick)

-- 查找控件
local control = ContextPtr:LookUpControl("/InGame/TopPanel/ScienceBar")
```

---

## 数据访问模式

```lua
-- 获取本地玩家
local ePlayer = Game.GetLocalPlayer()
local player = Players[ePlayer]

-- 获取产量
local scienceYield = player:GetTechs():GetScienceYield()
local cultureYield = player:GetCulture():GetCultureYield()
local goldYield = player:GetTreasury():GetGoldYield()

-- 获取选中单位
local selectedUnit = UI.GetHeadSelectedUnit()
if selectedUnit then
    local unitType = selectedUnit:GetType()
end
```

---

## 资料片 UI 分离

```xml
<!-- BaseGame -->
<ReplaceUIScript id="UnitPanel_Base" criteria="BaseGame">
  <LuaContext>UnitPanel</LuaContext>
  <LuaReplace>UI/MyUnitPanel_Base.lua</LuaReplace>
</ReplaceUIScript>

<!-- Expansion1 -->
<ReplaceUIScript id="UnitPanel_XP1" criteria="Expansion1">
  <LuaContext>UnitPanel</LuaContext>
  <LuaReplace>UI/MyUnitPanel_Expansion1.lua</LuaReplace>
</ReplaceUIScript>

<!-- Expansion2 -->
<ReplaceUIScript id="UnitPanel_XP2" criteria="Expansion2">
  <LuaContext>UnitPanel</LuaContext>
  <LuaReplace>UI/MyUnitPanel_Expansion2.lua</LuaReplace>
</ReplaceUIScript>
```

---

## 最小工作流

1. 先定位原版入口文件，确认是"新增面板"还是"必须替换上下文"
2. 只是加控件时，优先 `AddUserInterfaces`，再用 `LookUpControl()` 挂到现有树
3. 必须改原版行为时，优先"include 原版脚本后包裹函数"
4. 真的需要替换时，再上 `ReplaceUIScript`，按资料片分开
5. UI 调用 gameplay 状态时，只通过 `ExposedMembers` 或 `LuaEvents` 交互

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 只想加一个面板却用 ReplaceUIScript | 兼容性差 | 优先 AddUserInterfaces |
| 忘了本体和资料片 UI 路径不同 | 只在某个规则集生效 | 按 Base/XP1/XP2 分文件 |
| LookUpControl 失败后没处理 | UI 空白 | 加 nil 检查和 fallback |
| UI 逻辑和 gameplay 逻辑缠在一起 | 维护困难 | 通过 ExposedMembers 解耦 |
| LoadOrder 过低 | UI 被其他模组覆盖 | 使用 100000+ |

---

## 本地样例

- `UI/Akane_TopPanel.lua/xml` - AddUserInterfaces 新增面板
- `UI/Akane_UnitPanel_Base.lua` - include 包裹模式
- `UI/Akane_UnitPanel_Expansion2.lua` - ReplaceUIScript 重型改造

## 社区参照

- `QuickDeals/ui/diplomacyactionview_qd.lua` - 原版包裹写法
- `BetterLoadingScreen/UI/loadscreen.lua` - 前端界面接管

## 原版 UI 参考

| 文件 | 路径 | 用途 |
|------|------|------|
| TopPanel.lua | `Base/Assets/UI/TopPanel.lua` | 顶部产量显示 |
| UnitPanel.lua | `Base/Assets/UI/Panels/UnitPanel.lua` | 单位操作面板 |
| ProductionPanel.lua | `Base/Assets/UI/Panels/ProductionPanel.lua` | 城市生产 |
| DiplomacyActionView.lua | `Base/Assets/UI/DiplomacyActionView.lua` | 外交对话 |
| LoadScreen.lua | `Base/Assets/UI/FrontEnd/LoadScreen.lua` | 加载屏幕 |
