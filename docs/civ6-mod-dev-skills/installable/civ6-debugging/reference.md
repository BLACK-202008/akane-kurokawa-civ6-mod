# 技能 07: 日志与调试

## 适用场景

- 图标显示错位、文明条目缺失、SQL 没进库
- Lua 不触发、游戏启动即崩
- 需要在"进游戏前"和"进游戏后"都有验证手段

---

## 日志路径

| 日志 | 用途 | 路径 |
|------|------|------|
| Modding.log | 模组加载状态 | `%LOCALAPPDATA%\Firaxis Games\Sid Meier's Civilization VI\Logs\Modding.log` |
| Database.log | SQL/XML 错误 | `%LOCALAPPDATA%\Firaxis Games\Sid Meier's Civilization VI\Logs\Database.log` |
| Lua.log | Lua 错误 | `%LOCALAPPDATA%\Firaxis Games\Sid Meier's Civilization VI\Logs\Lua.log` |

---

## 调试流程

### 1. 数据库问题

```powershell
# 查看 Database.log 中的错误
Select-String -Path "$env:LOCALAPPDATA\Firaxis Games\Sid Meier's Civilization VI\Logs\Database.log" -Pattern "error|Error|ERROR"

# 检查缓存数据库
sqlite3 "$env:LOCALAPPDATA\Firaxis Games\Sid Meier's Civilization VI\Cache\DebugConfiguration.sqlite"
> SELECT * FROM Players WHERE LeaderType = 'LEADER_MY_LEADER';
```

### 2. Lua 问题

```lua
-- 在脚本中添加日志
print("[MyMod] Script loaded")
print("[MyMod] Variable value: " .. tostring(value))

-- 使用 Log 函数
local function Log(message)
    print("[MyMod] " .. tostring(message))
end
Log("PlayerID: " .. tostring(playerID))
```

### 3. 前端配置问题

检查 `DebugConfiguration.sqlite`：
- `Players` 表：领袖选择页数据
- `PlayerItems` 表：特色项目显示
- `LoadingInfo` 表：加载屏幕信息

### 4. 崩溃问题

**早期崩溃（SetupGraphics 阶段）：**
1. 隔离 Cache 目录
2. 隔离 PackageTemp 目录
3. 模组二分排查

**进游戏后崩溃：**
1. 检查 Lua.log 最后几行
2. 检查 Database.log 是否有 SQL 错误
3. 禁用 UI 替换类模组

---

## 静态验证

### PowerShell 验证脚本

```powershell
# 当前仓库的真实模式：tests/verify-strengthening.ps1
$districts = Get-Content -Raw "Data\Akane_Districts.xml"
$modifiers = Get-Content -Raw "Data\Akane_Modifiers.sql"
$modeSystem = Get-Content -Raw "Scripts\Akane_ModeSystem.lua"
$textZh = Get-Content -Raw "Text\Akane_Text_zh_Hans_CN.xml"

if ($districts -notmatch 'Lalalai_CityCenter_Gold') {
    throw 'Missing city center adjacency definition.'
}
if ($modifiers -notmatch "\('AKANE_MODE_SWITCH_BUFF_FOOD', 'Amount', '8'\)") {
    throw 'Missing mode switch all-yield buff.'
}
if ($modeSystem -notmatch 'GrantSwitchGoldReward') {
    throw 'Missing switch gold reward logic.'
}
if ($textZh -notmatch '\+20%') {
    throw 'Localized text did not catch strengthened bonus.'
}
```

**建议：**
- 优先维护项目内真实校验脚本，例如 `tests/verify-strengthening.ps1`。
- 新增技能或机制时，不要只靠肉眼检查；把最关键的契约改成正则或结构检查。

---

## 常见问题排查

### 图标不显示

1. 检查 `IconTextureAtlases` 是否定义
2. 检查 DDS 文件是否在 `ImportFiles` 中
3. 检查 `IconDefinitions` 的 Atlas 名称是否匹配
4. 查看 Database.log 是否有图标相关错误

### 领袖选择页异常

1. 检查 `Players` 表是否有对应行
2. 确认覆盖了三个 domain（Standard/XP1/XP2）
3. 检查 `PlayerItems` 是否有特色项目
4. 查看 `DebugConfiguration.sqlite`

### Lua 脚本不触发

1. 检查 `.modinfo` 中 `AddGameplayScripts` 是否正确
2. 检查脚本是否有语法错误（Lua.log）
3. 确认 `Initialize()` 函数被调用
4. 检查事件是否正确注册

### UI 替换不生效

1. 检查 `LuaContext` 是否正确
2. 确认 `LoadOrder` 足够高
3. 检查是否有其他模组覆盖
4. 确认按资料片分离（Base/XP1/XP2）

---

## 最小工作流

1. 改完数据或文案，先跑静态检查，不要每次都直接进游戏
2. 同步到测试模组目录后，再看日志
3. 前端配置异常时，查 `DebugConfiguration.sqlite`
4. UI 问题先对照原版文件路径
5. 启动即崩时，先隔离 Cache 和 PackageTemp

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 看错日志目录 | 盯着旧日志判断 | 确认是 `%LOCALAPPDATA%` 下 |
| 以为 SQL 写了就入库 | 数据没生效 | 查缓存数据库验证 |
| 没同步到测试目录 | 调的是旧文件 | 每次修改后同步 |
| 把早期崩溃怪到 Lua | 方向错误 | 先隔离图形缓存 |

---

## 本地样例

- `tests/verify-strengthening.ps1` - 静态验证脚本

## 社区参照

- `BetterLoadingScreen_Database.sql` / `loadscreen.lua` - 对照前端配置与加载页链路是否正常
- `QuickDeals.modinfo` / `diplomacyactionview_qd.lua` - 对照 UI wiring 与 ReplaceUIScript 是否正确
- `JFD's Russia.dep` / `RussiaPeter_IconDefinitions.sql` - 对照美术资源链和图标链是否完整
- `BetterBalancedGame.modinfo` / `sql/_utils.sql` - 对照复杂 criteria 和批量 SQL 模式是否写对

## 附录参考

- [本地环境配置](../shared/local-environment.md) - 完整的本机路径与当前部署状态
