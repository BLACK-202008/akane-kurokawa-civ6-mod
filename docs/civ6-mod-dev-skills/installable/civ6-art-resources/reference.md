# 技能 06: 美术资源链

## 适用场景

- 新单位需要 3D 表现或复用现有成员模型
- 新文明/新单位需要自有旗帜、肖像、UI 图集
- 图标链、UI 纹理链和 3D ArtDef 链开始分离

---

## 资源链分类

| 链路 | 用途 | 文件类型 |
|------|------|----------|
| IconTextureAtlases | UI 图标 | XML + DDS |
| .dep + ArtDef | 3D/系统资源 | .dep + .artdef |
| XLP/BLP | 高级 UI 资源 | .xlp/.blp |

---

## .dep 依赖声明

> 这一节必须以“复制已知可加载骨架，再做最小修改”为原则。不要手写抽象伪模板。
> 当前项目、`TXHBalance` 和 `JFD Russia` 的 `.dep` / `.artdef` 形状差异不小，但它们都证明了一件事：这类文件应从真实样本裁剪，而不是从零凭感觉拼。

```xml
<?xml version="1.0" encoding="utf-8"?>
<AssetObjects..GameDependencyData>
  <ID>
    <name text="MyMod_Art"/>
    <id text="your-guid-here"/>
  </ID>
  <RequiredGameArtIDs/>
  <SystemDependencies>
    <Element>
      <ConsumerName text="Units"/>
      <ArtDefDependencyPaths>
        <Element text="Cultures.artdef"/>
        <Element text="Unit_Bins.artdef"/>
        <Element text="Units.artdef"/>
      </ArtDefDependencyPaths>
      <LibraryDependencies>
        <Element text="Unit"/>
        <Element text="VFX"/>
        <Element text="Light"/>
      </LibraryDependencies>
      <LoadsLibraries>true</LoadsLibraries>
    </Element>
  </SystemDependencies>
</AssetObjects..GameDependencyData>
```

**关键点：**
- `.dep` 内部的 `ArtDefDependencyPaths` 使用的是裸文件名，如 `Units.artdef`，不是 `ArtDefs/Units.artdef`。
- 如果只是做单位 3D 复用，优先从 `TXHBalance_Units.dep` 这种最小骨架复制。

---

## ArtDef 定义

### 单位 ArtDef

> 下方片段用于识别真实骨架，**示意，不可直接复制**。真正落地时请从 `ArtDefs/Units.artdef` 或 `TXHBalance/ArtDefs/Units.artdef` 复制一个完整 `Units` 元素，再只改单位名、成员类型、音频和必要显示字段。

```xml
<?xml version="1.0" encoding="utf-8"?>
<AssetObjects..ArtDefSet>
  <m_Version>
    <major>4</major>
    <minor>0</minor>
    <build>253</build>
    <revision>293</revision>
  </m_Version>
  <m_TemplateName text="Units"/>
  <m_RootCollections>
    <Element>
      <m_CollectionName text="Units"/>
      <Element>
        <!-- 这里保留样本中的完整 m_Fields，不要手写简化版 -->
        <m_ChildCollections>
          <Element>
            <m_CollectionName text="Members"/>
            <Element>
              <m_Fields>
                <m_Values>
                  <Element class="AssetObjects..ArtDefReferenceValue">
                    <m_ElementName text="RockBand_Truck"/>
                    <m_RootCollectionName text="UnitMemberTypes"/>
                    <m_ArtDefPath text="Units.artdef"/>
                    <m_ParamName text="Type"/>
                  </Element>
                </m_Values>
              </m_Fields>
              <m_Name text="Members001"/>
            </Element>
          </Element>
          <Element>
            <m_CollectionName text="Audio"/>
            <Element>
              <m_Fields>
                <m_Values>
                  <Element class="AssetObjects..StringValue">
                    <m_Value text="RockBand"/>
                    <m_ParamName text="XrefName"/>
                  </Element>
                </m_Values>
              </m_Fields>
              <m_Name text="RockBand"/>
            </Element>
          </Element>
        </m_ChildCollections>
        <m_Name text="UNIT_MY_UNIT"/>
      </Element>
    </Element>
  </m_RootCollections>
</AssetObjects..ArtDefSet>
```

### 复用原版成员

```xml
<!-- 复用 RockBand 的成员和音频：来自当前项目 -->
<m_Name text="UNIT_STAGE_ACTOR"/>
<m_ElementName text="RockBand_Truck"/>
<m_Value text="RockBand"/>
```

**说明：**
- 上面的 `ArtDefSet` 片段是“结构真实、字段裁剪”的骨架，不是从零发明的简化 XML。
- 真正落地时，优先从 `ArtDefs/Units.artdef` 或 `TXHBalance/ArtDefs/Units.artdef` 复制一个完整 `Units` 元素，再只改单位名、成员类型、音频和少数显示字段。

---

## 贴图尺寸规范

| 尺寸 | 用途 |
|------|------|
| 22x22 | 单位旗帜小图、列表图标 |
| 32x32 | 标准图标 |
| 38x38 | 中等图标 |
| 50x50 | 选择页图标 |
| 80x80 | 肖像缩略图 |
| 256x256 | 大图、载入图 |

### DDS 命名约定

```
Textures/
├── MyUnitFlags22.dds      # 22x22 旗帜
├── MyUnitFlags256.dds     # 256x256 旗帜
├── MyLeader32.dds         # 32x32 肖像
├── MyLeader256.dds        # 256x256 肖像
├── MyLeaderNeutral.dds    # 载入图（无背景）
└── MyLoadingBackground.dds # 载入背景
```

---

## .modinfo 配置

```xml
<InGameActions>
  <!-- 美术资源 -->
  <UpdateArt id="MyArt">
    <Properties><LoadOrder>80</LoadOrder></Properties>
    <File>MyMod.dep</File>
  </UpdateArt>

  <!-- 导入纹理 -->
  <ImportFiles id="Textures">
    <File>Textures/MyLeader32.dds</File>
    <File>Textures/MyLeader256.dds</File>
  </ImportFiles>
</InGameActions>

<FrontEndActions>
  <!-- 前端也需要导入纹理 -->
  <ImportFiles id="FrontEndTextures">
    <File>Textures/MyLeader32.dds</File>
    <File>Textures/MyLeader256.dds</File>
  </ImportFiles>
</FrontEndActions>
```

---

## 最小工作流

1. 判断需求属于哪条链：图标走 XML，3D 走 ArtDef
2. 若只是复用原版美术，优先在 ArtDef 中引用现成 UnitMemberTypes
3. 需要新 art 包时，先准备 .dep，把依赖写完整
4. 把 ArtDef、.dep、相关贴图全部列入 `<Files>`
5. 必要时给 UI 纹理补 `ImportFiles`

---

## 常见坑

| 问题 | 表现 | 解决 |
|------|------|------|
| 混淆图标链和 3D ArtDef | 排查方向错误 | 分开检查：XML 图标 vs ArtDef |
| 把 `.dep` 内路径写成 `ArtDefs/Units.artdef` | UpdateArt 载入异常 | `.dep` 内优先沿用样本的裸文件名写法 |
| UpdateArt 写了但 .dep 没配对 | 资源不生效 | 检查 ConsumerName 和 ArtDef 路径 |
| 只接了 ArtDef，没导入 UI 纹理 | UI 图标缺失 | FrontEndActions + InGameActions 都要 ImportFiles |
| 可以复用原版却做全套新资源 | 成本过高 | 优先引用现有 UnitMemberTypes |

---

## 本地样例

- `Akane_Art.dep` - 完整资源依赖包
- `ArtDefs/Units.artdef` - 复用 RockBand 成员
- `TXHBalance/ArtDefs/Units.artdef` - 用原版成员拼新单位

## 社区参照

- `JFD's Russia.dep` - 带 UserInterface.artdef 的完整包
- `JFD Russia/Core/RussiaPeter_IconDefinitions.sql` - 成套旗帜/肖像 atlas
- `JFD Russia/XLPs/Icons.xlp` - 高级 UI 图集资源
