# Fab 已购资产（给 Agent 选型）

> **不要**把 Epic 密码、Cookie、授权码发给 Agent。  
> **不要**把 2000 条手工抄进表格。  
> 推荐：在已登录的 Fab 页面 **导出一份 JSON/CSV**，或 **先库内搜索再丢结果**。

---

## 推荐顺序（2000 条时）

| 优先 | 方法 | 你要花的时间 | 给我什么 |
|---|---|---|---|
| **1** | Fab 库内关键词搜索 | 10 分钟 | 搜到的包名列表 / 几张截图 |
| **2** | 浏览器控制台一键导出 JSON | 2 分钟 | `docs/fab_library.json` |
| **3** | 手工表 | 不适合 2000 条 | 仅当只剩 10～20 个候选 |

2000 条里通常大量是 Megascans 贴图、材质、UE 蓝图、插件——**对《末命》Godot 俯视经营几乎用不上**。先搜，再导出，比全库 dump 更有用。

---

## 方法 1：库内搜索（最省事，先做这个）

1. 打开 [fab.com/library](https://www.fab.com/library)（已登录）  
2. 类型尽量选 **3D Model**（不要 Material / Plugin）  
3. 分别搜索下面关键词，把**看起来像样的包名**复制到本文件末尾，或整页截图丢进 `concepts/fab_library/`：

```text
chinese  asian  oriental  courtyard  pavilion  temple
farm  crops  vegetable  garden  well
stylized  hand painted  toon  cartoon
gate  village  manor  tree  bamboo
```

4. 在对话里说「Fab 搜索结果已放好」。

Godot 能用的格式优先：**FBX / glTF / OBJ / Blend**。只有 `.uasset`、只能 Add to Unreal Project 的包，默认跳过。

---

## 方法 2：浏览器一键导出（适合「给我全库名单」）

在 **已登录** 的 [fab.com/library](https://www.fab.com/library) 按 `F12` → **Console**，整段粘贴回车。成功后会下载 `fab_library.json`。

把该文件放到仓库：`docs/fab_library.json`（可 gitignore 若不希望公开库名单），然后在对话里 `@docs/fab_library.json`。

```javascript
(async () => {
  const items = [];
  let cursor = "";
  for (let page = 0; page < 80; page++) {
    const u = new URL("https://www.fab.com/i/library/entitlements/search");
    u.searchParams.set("count", "100");
    u.searchParams.set("sort_by", "-createdAt");
    if (cursor) u.searchParams.set("cursor", cursor);
    const r = await fetch(u.toString(), { credentials: "include" });
    if (!r.ok) {
      console.error("HTTP", r.status, "— 确认已登录且在 fab.com 域名下运行");
      break;
    }
    const j = await r.json();
    const batch = j.results || [];
    items.push(...batch);
    cursor = (j.cursors && j.cursors.next) || "";
    console.log("已拉取", items.length);
    if (!cursor || batch.length === 0) break;
  }
  const slim = items.map((x) => {
    const L = x.listing || x;
    return {
      title: x.title || L.title || "",
      url: x.url || L.url || (L.uid ? "https://www.fab.com/listings/" + L.uid : ""),
      type: x.listingType || L.listingType || "",
      categories: x.categories || L.categories || [],
    };
  });
  const blob = new Blob([JSON.stringify({ count: slim.length, items: slim }, null, 2)], {
    type: "application/json",
  });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = "fab_library.json";
  a.click();
  console.log("导出完成", slim.length, "条");
})();
```

若报 401/403：先刷新 Library 页面再跑；**不要**把 Cookie 贴到聊天里。

导出后 Agent 会按标题关键词筛：中式 / 农场 / 庭院 / 井 / 树 / stylized，列出可进 Godot 的候选。

---

## 方法 3：Network 复制单页 JSON（脚本失败时的退路）

1. Library 页 `F12` → **Network** → 刷新  
2. 找到名为 `search` 或含 `entitlements` 的请求  
3. 点 **Response**，全选复制保存为 `docs/fab_library_page1.json`  
4. 翻页重复，或只保你搜过关键词后的那一页（更短、更准）

---

## 不要用的做法

- 把 Epic / Fab **密码、Cookie、OAuth code** 发给 Agent  
- 为了 2000 个包 **改用虚幻**（玩法已在 Godot；多数 Fab 包仍可导出 FBX）  
- 把整个 VaultCache / 数 GB 工程丢进仓库  

社区工具（`epic-fab`、FabAssetsManager）也能拉库名单，但要本机登录；**导出 JSON 后同样只把文件放进 `docs/`**，不要交令牌。

---

## 本项目优先匹配（《末命》M1 信王府）

| 优先级 | 需要 | 工程落点 |
|---|---|---|
| P0 | 府门 / 门楼 | `assets/models/buildings/mansion_gate.tscn` |
| P0 | 井 / 井亭 | `assets/models/props/well.tscn`（坐标勿改） |
| P0 | 菜畦 / 作物（最好有生长阶段） | `plot_01`…`plot_06`，保留 **Soil / Crops** |
| P1 | 风格化树 2～3 棵 | 院子四角 |
| P1 | 木构厢房 / 围墙段 | 同名覆盖程序件 |
| P2 | 低面角色 | 信王 / 承恩 / 吴伯 |

视觉：暖色赛璐璐俯视（`concepts/m1_target/`）。性能：GTX 960，避开 4K 写实扫描件。

---

## 手工表（仅小名单时用）

| 包名 | Fab 链接 | 类型 | 风格 | 格式 | 备注 |
|---|---|---|---|---|---|
| | | | | | |

---

## 已筛选 / 已采用（Agent 回填）

| 包名 | 用于 | 工程路径 | 状态 |
|---|---|---|---|
| [Opiamor Design · Low-Poly Medieval Well](https://www.fab.com/listings/1f1d7043-b740-462d-b4fd-d388b7195c8a) | 井（首选） | `game/assets/fab/well/low_poly_well.glb` | **采用**。文件已就位；`spawn_well` 认此文件名。 |
| [Saiko165 · Stylized Medieval Well](https://www.fab.com/listings/51a8c624-c97b-471d-8be5-d3c5998dfcd9) | 井（备选） | 同上路径 | **不叠用**。约 4.8k 三角、有水桶，观感略精；若已购且更喜欢可替换 Opiamor。 |
