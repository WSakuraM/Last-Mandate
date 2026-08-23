# M1A2 + M1A3 实现概览

## 完成内容

按设计敲定记录区块一待落地清单第 2、3 项，连续实现 M1A2（菜畦最后播种回忆钩）与 M1A3（阿恩递种夜谈）。

### 新建文件
- `game/scripts/world/AenSeedEvent.gd` — 阿恩递种夜谈事件，监听 EventBus.first_sow 信号触发

### 修改文件
- `game/scripts/world/CourtPlot.gd` — tend() 新增 `_check_sow_hooks()`：首次播种 emit 信号 + 后期播种写回忆
- `game/scripts/managers/EventBus.gd` — 新增 `first_sow()` 信号
- `game/scripts/world/Act1Director.gd` — 创建 AenSeedEvent 实例
- `game/scripts/ui/Act1Closure.gd` — 存档新增 `grain_seed` 显式字段
- `docs/story/13_设计敲定记录.md` — M1A2/M1A3 状态：待落地 → 已落地
- `docs/story/12_剧情走向总图.md` — 阿恩夜谈/最后播种状态：未落地/待接 → 已落地

## M1A2：菜畦最后播种回忆钩

CourtPlot.gd 的 `tend()` 在 fallow→tilled（播种）时调用 `_check_sow_hooks()`：
- **首次播种**（任意菜畦）：设 `first_sow_done` flag，emit `EventBus.first_sow`（驱动 M1A3）
- **后期播种**（total_day >= 120，约第一幕最后 30 天）：写 `MF_A1_LAST_SOW` 回忆碎片（weight=8, pillar=Ⅰ，文本"你或许看不见收成"），终章蒙太奇对照空畦/日出

## M1A3：阿恩递种夜谈

AenSeedEvent.gd 监听 `EventBus.first_sow` 信号，触发一次性叙事卡：
- 阿恩（王承恩）夜色中递上谷种布袋
- 夜谈一句承诺：「王爷，有朝一日……您若到了那高处，别忘了园子里的人。」
- 写入 `MF_A1_AEN_PROMISE` 回忆碎片（weight=9, must, pillar=Ⅰ）
- 设 `aen_seed_given` flag（跨幕谷种道具标记，存档 flags + grain_seed 显式字段）

## 触发链

```
玩家靠近菜圃按 E → CourtPlot.tend() → fallow→tilled
  ├─ 首次？ → EventBus.first_sow.emit() → AenSeedEvent 弹出夜谈卡
  └─ 后期(total_day>=120)？ → IssueManager.add_memory(MF_A1_LAST_SOW)
```

## 校验
- Godot 4.7.2 headless 校验：0 报错，0 警告
- 本地提交：`b850731`（8 files, +162 行）

## 待办
- 推送至 GitHub + Gitee 双远程（需用户在已登录终端执行 `git push origin main`）
- 后续 M1A4（秋穗家书三选议题，中段天灾段触发）
