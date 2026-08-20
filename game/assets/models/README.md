# 模型库 models（运行时）

英文文件夹名不变；中文说明见 [`docs/文件夹说明.md`](../../docs/文件夹说明.md)。

| 子目录 | 中文 | 内容 |
|---|---|---|
| `materials/` | 材料 | 菜药鱼等物品图 |
| `vegetation/` | 植被 | 畦、灌木、树草 |
| `creatures/` | 动物 | 蝶蛙猫狗鸟虫 |
| `characters/` | 人物服饰 | NPC / 玩家立绘或精灵 |
| `props/` | 道具设施 | 锄网井摊仓灶棚 |
| `ui/` | 界面 | 可选 UI 图 |

放入 PNG 后，代码用：

```gdscript
AssetBank.load_texture("characters", "aen.png")
```

暂无程序绘制时，本目录可为空（仅有 `.gitkeep`）。
