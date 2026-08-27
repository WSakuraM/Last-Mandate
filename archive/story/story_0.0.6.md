# 剧本连贯性优化 0.0.6

> 冻结于 2026-08-24 · 品类：story  
> 工作稿：`docs/story/14_剧情连贯性审查与优化.md`

## 摘要

对 M1 主线/支线做连贯性审计，修复 **M1A5 夜召入继缺失**、**M1A4 门控**、回忆柱/ID 漂移，并重写故事圣经、第一幕剧本、时局小故事落地表。

## 关键决策

1. **M1A5 两段式**：`AccessionEvent` 演出 → `Act1Closure` 统计（先戏后表）  
2. **M1A4 门控**：须 `aen_seed_given` 或 `first_sow_done`  
3. **秋穗回忆**：统一 pillar Ⅲ  
4. **MF_LOVERS_SUGAR**：权重 9（与 must-if 情感锚对齐）  
5. **08 时局小故事**：诚实区分 3D 已落地 / 2D 待迁

## 代码触点

- 新增 `game/scripts/world/AccessionEvent.gd`  
- 改 `Act1Director.gd`、`QiuShuiLetterEvent.gd`、`ShenLiuStoryline.gd`、`Act1Closure.gd`

— Sakura
