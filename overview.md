# M1A4 秋穗家书三选——实现概览

## 完成内容

按设计敲定记录区块一待落地清单第 4 项，实现 M1A4 秋穗家书三选——中段天灾段仁慈抉择。

### 新建文件
- `game/scripts/world/QiuShuiLetterEvent.gd` — 秋穗家书三选事件，total_day>=50 由 Act1Director 触发

### 修改文件
- `game/scripts/world/Act1Director.gd` — 日间循环加 elif 分支触发秋穗家书 + 创建实例
- `game/scripts/ui/Act1Closure.gd` — 存档新增 `kind_likely` 字段 + 收束画面〔仁慈〕Trait 显示
- `docs/story/13_设计敲定记录.md` — M1A4 状态：待落地 → 已落地
- `docs/story/12_剧情走向总图.md` — 秋穗家书状态：未落地 → 已落地

## 三选机制

| 选择 | 私囊消耗 | 民心 | 旗标 | 回忆碎片 | 权重 |
|------|---------|------|------|---------|------|
| 借粮（动私囊） | -15 兩 | +5 | kind_likely=true | MF_A1_QIUSHUI_LEND | 7 |
| 象征性给 | -3 兩 | +2 | — | MF_A1_QIUSHUI_TOKEN | 4 |
| 婉拒 | 0 | -3 | — | MF_A1_QIUSHUI_REFUSE | 3 |

- 借粮 = 仁慈路径：私囊代价大（直接影响 M2 国库初值），但获得 kind_likely Traits 软化 M2 开仓台词 + 民心大增
- 象征性给 = 中间路径：小代价小回报
- 婉拒 = 自保路径：无代价但民心下降

## 触发条件

日间循环 tick 中：`not _qiushui_done and total_day >= 50` → `_start_qiushui_letter()`
- total_day=50 对应 day=51，51%7=2（非夜召日），无冲突
- 触发后锁住世界（night_council_active=true），完成后解锁

## 存档

ACT1_END 存档现在包含：`act` + `resources`(五资源+私囊) + `memories` + `flags` + `private_purse` + `grain_seed` + `kind_likely`

## 校验
- Godot 4.7.2 headless 校验：0 报错
- 本地提交：`aeff89f`（6 files, +294/-34 行）

## 待办
- 推送至 GitHub + Gitee 双远程（需用户在已登录终端执行 `git push origin main`）
- 主线脊柱六节点全部落地完成：M1A0~M1A5 全绿
