# 声音库 audio（运行时）

英文文件夹名不变；中文说明见 [`docs/文件夹说明.md`](../../docs/文件夹说明.md)。

| 子目录 | 中文 | 内容 | 来源 |
|---|---|---|---|
| `sfx/ui/` | 界面 | click、toast | Kenney CC0 |
| `sfx/interact/` | 互动 | plant / harvest / sell / forage / fish | Kenney RPG CC0 |
| `weather/` | 天气 | rain / wind / snow（优先 `.ogg`） | OGA CC0 |
| `ambient/` | 场景环境 | yard_day | OGA CC0 |
| `music/` | 音乐 | manor_soft | Kenney Jingles CC0 |
| `dialogue/` | 对话提示 | blip | Kenney CC0 |

播放：

```gdscript
Sfx.play("plant")
```

署名见 `assets_library/licenses/CREDITS_STYLE_C.md`。
