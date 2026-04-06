# 2026-04-06 美术接入与崩溃排查记录（后续参考）

## 适用范围

- 项目：`new civi6 mod`
- 场景：领袖图标/静态肖像接入后，前端显示异常或游戏启动崩溃

---

## 本次实际症状

1. 领袖选择页：
- 右侧领袖图标回退到越南（说明自定义领袖图标未生效）
- 左侧静态图空白（说明 `Players.Portrait` 链路未生效）

2. 游戏内：
- 右上角头像显示 `?`（图标定义存在但纹理/配置链路断裂）

3. 后续出现启动崩溃：
- `EXCEPTION_ACCESS_VIOLATION`
- 启动阶段日志停在 `GUIInit / SetupGraphics` 附近

---

## 关键结论

1. **先看对的日志路径**
- 当前环境正确日志路径是：
  - `C:\Users\oh_black\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\Logs\Database.log`
  - `C:\Users\oh_black\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\Logs\Modding.log`
  - `C:\Users\oh_black\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\Logs\Lua.log`
- `Documents\My Games\...\Logs` 在本环境下不是本次会话的有效来源。

2. **配置库是否入库要查缓存数据库，不靠猜**
- 检查：
  - `C:\Users\oh_black\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\Cache\DebugConfiguration.sqlite`
- 本次发现 `Players/PlayerItems` 中没有 `CIVILIZATION_LALALAI`，导致前端回退显示。

3. **图标链路要显式**
- `IconTextureAtlases` 的 `Filename` 显式写为 `Textures/...dds`
- `modinfo` 里用 `ImportFiles` 明确导入图标和肖像纹理（前端 + 游戏内）
- 领袖图标建议补齐尺寸：`32/45/48/50/55/64/80/256`

4. **配置写法优先幂等 SQL**
- 配置数据库建议使用 `INSERT OR REPLACE INTO Players/PlayerItems` 的 `.sql`
- 比直接 XML Row 在复杂模组组合下更稳，重复构建时不易丢行

5. **启动崩溃先做缓存隔离**
- 若崩溃发生在 `SetupGraphics` 前后且未进入模组组件加载：
  - 重建 `Cache` 与 `PackageTemp`（先备份后重建）
  - 路径：
    - `C:\Users\oh_black\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\Cache`
    - `C:\Users\oh_black\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\PackageTemp`

---

## 本次有效修复动作（按顺序）

1. 资源接入修复
- 新增/补齐领袖图标 `dds`（含 `48`）
- 新增静态肖像 `LEADER_KUROKAWA_AKANE_NEUTRAL.dds`

2. 配置链路修复
- 新增 `Data/Akane_Config.sql`，使用 `INSERT OR REPLACE` 写入 `Players` 与 `PlayerItems`
- `AkaneKurokawa.modinfo` 的 `FrontEndActions` 改为加载 `Akane_Config.sql`

3. 图标链路修复
- `Icons/Akane_Icons.xml`：
  - 根标签使用 `GameInfo`
  - `IconTextureAtlases` 文件名改为 `Textures/...`
  - 保留 `ICON_LEADER_KUROKAWA_AKANE` 定义
- `modinfo` 增加 `ImportFiles`，显式导入 `Textures/*.dds`

4. 启动崩溃修复
- 备份并重建 `Cache` / `PackageTemp`

---

## 推荐排查流程（后续固定执行）

1. 先确认日志是否来自 `AppData` 路径。
2. 看 `Modding.log`：
- 是否出现 `Loading Mod ... AkaneKurokawa.modinfo`
- 是否出现 `ModdingUpdateConfigurationDatabase - Loading Data/Akane_Config...`
- 是否出现 `UpdateIcons - Loading Icons/Akane_Icons.xml`
3. 查 `DebugConfiguration.sqlite`：
- `Players` 是否有 `LEADER_KUROKAWA_AKANE`
- `PlayerItems` 是否有 `CIVILIZATION_LALALAI`
4. 若图标异常：
- 检查 `IconTextureAtlases` 尺寸是否齐全
- 检查纹理文件是否在 `modinfo` `<Files>` + `ImportFiles` 中
5. 若启动即崩：
- 先重建 `Cache`/`PackageTemp`
- 再做模组二分隔离

---

## 防踩坑清单

- 不要只看 `Documents\My Games` 旧日志判断本次问题。
- 不要只改 `Icons.xml` 不导入纹理文件。
- 不要只改 `Data/Akane_Config.xml` 却不验证配置库中是否真的有行。
- 每一大轮修改后，**先同步到测试目录再测**：
  - `C:\Users\oh_black\Documents\My Games\Sid Meier's Civilization VI\Mods\new civi6 mod`

