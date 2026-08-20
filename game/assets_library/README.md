# 《末命》素材 / 模型库管理说明

## 本目录是**可商用素材总库**的管理中心；游戏运行时真正引用的资源在 `game/assets/`。

**中文文件夹对照**：见仓库 [`docs/文件夹说明.md`](../../docs/文件夹说明.md)。

## 目录约定

```text
game/
  assets_library/           ← 素材库（管理、许可、原始包）【中文：第三方素材仓库】
    README.md
    MANIFEST.csv
    licenses/               ← 许可证
    vendor/                 ← 第三方原始包
    staging/                ← zip 暂存
  assets/                   ← Godot 实际使用
    models/                 ← 【模型库】材料/植被/动物/人物/道具
    audio/                  ← 【声音库】动效/天气/环境/音乐/对话
    sprites/                ← 旧试验精灵（可逐步迁到 models/）
    tiles/                  ← 旧地砖
    ui/
```

## 准入规则（防侵权）

**只收录**下列之一：

| 许可 | 可否商用 | 备注 |
|---|---|---|
| **CC0** | 是 | 首选；归因非强制但建议记来源 |
| 作者声明 Public Domain | 是 | 需留存声明截图/链接 |
| 明确写「免费商用、可改、可进 Steam」的自有授权 | 是 | 全文保存到 licenses/ |

**禁止入库**：来路不明网盘包、仅「免费下载」未写商用、CC-BY 若你不想署名也先别用（可用但必须署名）、AI 素材许可不清、翻录影视/他作。

## 工作流

1. 下载 zip → `staging/`  
2. 解压到 `vendor/<来源>/<包名>/`，并复制许可到 `licenses/`  
3. 挑选需要的 PNG 复制/裁切到 `game/assets/...`  
4. 在 `MANIFEST.csv` 登记一行  
5. 场景只引用 `res://assets/...`，**不要**直接引用 `vendor/` 大包（避免工程膨胀与误用）

## 当前阶段策略

- 画面目标：**非像素**、对标热门 2D 成品（柔和/手绘卡通），**不用像素作主风格**。  
- M1 已先用柔和卡通程序绘制保证可读；回家按 [`NEXT_STEPS.md`](NEXT_STEPS.md) 接入 Great Farm / Hand-Drawn Tileset 等可商用包。  
- `MANIFEST` 用 `status=placeholder|final` 区分临时与定稿。

## Godot 路径

编辑器：`D:\GameTool\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`  
工程：`D:\Game\Last-Mandate\game`
