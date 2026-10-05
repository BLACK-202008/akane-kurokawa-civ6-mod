# 回归验证

从仓库根目录执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run-regressions.ps1
```

需要 `lua`（5.3 或更新版本）、`python`（3.10 或更新版本）和 PowerShell。

- 现有 `verify-*.ps1` 检查数据与文本约定。
- `test-mode-runtime.lua` 执行生产 ModeSystem/TopPanel，保留属性与附加效果，覆盖切换、重复读档、临时加成清算、同步操作验证及 UI 异步刷新。
- `test-faith-purchases.lua` 执行生产 Gameplay/PurchaseSupport，覆盖信仰交易返金、失败购买、金币购买、无关信仰支出、重复事件、币种报价、编队及参数校验。
- `test-building-adjacency.py` 把游戏数据库复制到内存并加载真实模组 SQL，检查三级附件链、23 个收益参数、邻接、替代区域、跨城作用域及按城市限叠。

建筑数据库测试默认读取当前用户 Civ6 缓存目录里的 `DebugGameplay.sqlite`。也可指定另一个 Gathering Storm 数据库：

```powershell
$env:CIV6_GAMEPLAY_DATABASE = 'D:/path/to/DebugGameplay.sqlite'
python -B tests/test-building-adjacency.py
```

源数据库以只读方式打开；测试不会改写它。`Make_Hash` 仅用测试替代实现满足数据库触发器，不能检验游戏中的哈希或美术映射。

Lua 测试替换游戏 API 边界，不能证明原生操作队列顺序、即时 modifier 结算或联机同步。三级建筑链测试检查数据的主体和筛选约定，不模拟引擎的特色建筑继承规则。交付前仍需实机检验 README 中的场景。
