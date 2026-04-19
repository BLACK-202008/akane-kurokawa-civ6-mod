# Civilization VI Mod Dev Skills for Codex

这是可直接安装到 Codex 的版本。

安装方式：

1. 把当前目录下的 7 个技能目录和 `shared/` 一起复制到 `C:\Users\oh_black\.codex\skills`
2. 保持 `shared/local-environment.md` 与各技能目录处于同一层级
3. 不要只复制 `SKILL.md`，每个技能目录内的 `reference.md` 也要一起带上

目录说明：

- `civ6-modinfo-assembly/`
- `civ6-database-definitions/`
- `civ6-frontend-config/`
- `civ6-gameplay-lua/`
- `civ6-ui-injection/`
- `civ6-art-resources/`
- `civ6-debugging/`
- `shared/`

`shared/local-environment.md` 记录当前机器上已验证过的本地 Civ6 环境事实，以及“尚未部署”的目录状态。

## 新增吸收的结构经验

这套技能包现在额外吸收了同一个 `TXHBalance` 模组的两种重构范式：

- `codex` 版：按子系统和加载阶段分层，例如 `Balance/`、`BCY/`、`NewUnits/`、`Compat/`，适合整合型大模组。
- `opus` 版：按文件类型集中，例如 `SQL/`、`Text/`、`XML/`、`Config/`，由 `.modinfo` 的 action id、文件名和 `LoadOrder` 明确编排。

技能包中的相关参考文档已经把这两种做法总结成规则：

- `.modinfo` 负责真实加载顺序，目录结构只负责维护体验。
- SQL/XML/Text 的拆分要围绕主题边界、依赖链和兼容关系，而不是随意按体积切文件。
- Gameplay Lua 最稳的模式是“单入口注册事件，再决定是否向子模块拆分”。
- 前端参数定义与文本文案必须逻辑分离，是否物理分文件则按复用范围选择。
