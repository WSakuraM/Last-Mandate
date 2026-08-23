# M1A1 吴伯私囊教程 — 实现概览

## 完成内容

按设计敲定记录 `13_设计敲定记录.md` 区块一待落地清单第 1 项，实现 M1A1「吴伯·私囊教程」玩法。

### 新建文件
- `game/scripts/ui/PrivatePurseTutorial.gd` — CanvasLayer 教程面板，4 步银两归类轻交互

### 修改文件
- `game/scripts/managers/ResourceManager.gd` — 新增 `private_purse` 字段 + `add_private_purse()` + `get_state()` 含私囊
- `game/scripts/world/Act1Director.gd` — 开场字幕后触发教程，锁世界直到完成
- `game/scripts/ui/Act1Closure.gd` — 接入 `SaveManager.save_state()` 全量存档 + 收束画面新增私囊结余行
- `docs/story/13_设计敲定记录.md` — M1A1 状态：待落地 → 已落地
- `docs/story/12_剧情走向总图.md` — 吴伯私囊教程状态：未落地 → 已落地

### 教程流程
1. 开场字幕（6 秒或按 E 消失）
2. 吴伯登场：「王爷，老奴今日有几笔银子要请您过目」
3. 4 步银两归类（每步选私/公 → 吴伯反馈 → 按 E 继续）：
   - 王府月例银 12 兩 → 私囊
   - 田庄秋租 28 兩 → 私囊
   - 户部拨银 50 兩 → 官银
   - 官员馈银 20 兩 → 官银
4. 结算：私囊结余存入 `ResourceManager.private_purse`（跨幕 M2 国库初值），官银入国库（×0.1 缩放），回忆碎片 `MF_A1_PURSE_TUTORIAL`
5. 吴伯点题：「私囊是你家的，官银是天下人的。这天下的账，迟早要算的。」

### 关键设计决策
- **玩家选择决定银两去向**：无论对错，玩家选"私囊"的银两进 private_purse，选"官银"的进国库。吴伯反馈但不强制纠正——选择有真实后果
- **私囊 ×0.1 缩放入国库**：银两单位（兩）与国库资源（0-100）不同，需缩放避免数值溢出
- **ACT1_END 全量存档接入**：收束时调用 `SaveManager.save_state()` 写入五资源+回忆+旗标+私囊，为 M2 继承铺路

### 校验
- Godot 4.7.2 headless 校验：0 报错，0 警告
- 本地提交：`92b4ca0`（6 files, +279 行）

### 待办
- 推送至 GitHub + Gitee 双远程（需用户在已登录终端执行 `git push origin main`）
- 后续 M1A2（菜畦种收加 MF_LAST_SOW 回忆钩）
