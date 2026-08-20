# UI / UX · 0.0.3 · 风格 C 木框

> 对齐画面定案 C（赛璐璐）。完整气质仍见 `ui_0.0.1.md`；水墨主视觉补丁见 `ui_0.0.2.md`（已被风格 C 覆盖方向）。

## 定案（2026-08-21）

一幕 HUD / 对白用 **暖纸黄底 + 深木描边**，少胶囊、少紫霓虹。

| 控件 | 样式 |
|---|---|
| 私囊资源条 | `StyleC.wood_panel` 厚木框 + 轻阴影 |
| 目标 / 时钟 | `slim_panel` 细木条 |
| 对白底栏 | `dialogue_panel` 厚边纸色 |
| 抉择按钮 | 木底，悬停硃红描边 |
| Toast | `toast_panel` 居中木牌 |
| 底栏 Tip | `tip_panel` |
| 对白立绘位 | `portrait_frame` + 角色色块（有 PNG 后可换贴图） |

实现：`game/scripts/act1/style_c.gd`、`game/scripts/ui/hud_dialogue.gd`。
