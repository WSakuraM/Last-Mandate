# 区块二 落地概览——日常小事件填充 + 种收回忆钩

## 完成内容

按设计敲定记录区块二（第一幕玩法循环比重与节奏）两大待落地项，全部实现完毕。

### 新建文件
- `game/scripts/ui/DailyVignette.gd` — 夜召空窗期日常小事件（8 条街坊/天气/市井片段）

### 修改文件
- `game/scripts/managers/EventBus.gd` — 新增 `narration(text)` 信号
- `game/scripts/world/CourtPlot.gd` — `_harvest()` 加旱象减产 + 丰收分邻回忆钩
- `game/scripts/world/Act1Director.gd` — 池空触发日常小事件 + 监听 narration 显示浮字
- `docs/story/13_设计敲定记录.md` — 区块二落地状态更新
- `docs/story/12_剧情走向总图.md` — 新增日常小事件 + 收获钩子两行

## 日常小事件填充

夜召池空时（6 次空窗期），`Act1Director._start_night_council()` 调用 `_start_daily_vignette()` 代替直接 return。弹出轻量叙事卡：

| # | 标题 | 内容摘要 |
|---|------|----------|
| 1 | 夜·无议 | 无人报事，承恩添灯油劝歇 |
| 2 | 天象 | 厚云压天，像要落雨终究没下 |
| 3 | 市井 | 吴伯叹米价涨三成，城中已有抢米 |
| 4 | 街坊 | 张屠户送肉谢去年帮衬 |
| 5 | 秋声 | 枣树落叶一地，日子过得慢 |
| 6 | 旧学 | 忆幼时先生讲「民为邦本」 |
| 7 | 邸报 | 辽东在打，陕西报旱 |
| 8 | 灯下 | 夜静，烛芯爆响，好歹有人守着 |

不占决策、不抢戏——E 键或 6 秒自动消失，世界恢复运转。

## 种收回忆钩

`CourtPlot._harvest()` 在原有数值结算后，新增两条回忆钩：

| 条件 | 回忆碎片 | 权重 | 支柱 | 旁白浮字 |
|------|---------|------|------|----------|
| drought flag = true | MF_A1_DROUGHT_HARVEST | 6 | Ⅲ（人民疾苦） | 「旱象连年，这畦菜瘦得可怜……」 |
| 收获丰收(r>1.1) 且春/秋 | MF_A1_BOUNTY_SHARE | 4 | Ⅰ（信王个人） | 「丰收了，你让吴伯分些给街坊。」 |

- `EventBus.narration(text)` 信号驱动 `Act1Director._on_narration()` 在屏幕底部显示 3.5 秒浮字
- 回忆碎片由 `IssueManager.add_memory()` 自动去重（同 ID 留高 weight），无需额外防重

## 校验
- Godot 4.7.2 headless 校验：0 报错
- 本地提交：`568ab4b`（7 files, +214/-31 行）
- 推送：沙箱限制，需用户在已登录终端 `git push origin main`

## 总体进度

| 区块 | 状态 |
|------|------|
| 区块一：主线脊柱 M1A0~M1A5 | ✅ 全部落地 |
| 区块二：玩法循环比重与节奏 | ✅ 全部落地 |
| 区块三：支线清单与串联 | 待落地 |
| 区块四：跨幕回忆回收 | 待落地 |
