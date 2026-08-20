# 技术方案 · 0.0.1 (M0 · Design Freeze)

> 冻结日期：2026-08-20

## 引擎

- **Godot 4**（MIT，永久免费）
- 一、二幕：2D Tilemap + 精灵
- 三幕：短 3D + 终章第一人称
- 统一存档：Traits / 五资源 / MandateDecay / MemoryFragments

## 仓库布局

| 路径 | 用途 |
|---|---|
| `docs/` | 工作稿（可迭代改写） |
| `archive/` | 版本化冻结稿 |
| `data/issues/` | 议题 JSON |
| `scripts/` | 工具脚本（含每日备份） |
| `.cursor/rules/` | Agent 约定 |

## 远程

- GitHub `origin`：https://github.com/WSakuraM/Last-Mandate.git
- Gitee `gitee`：https://gitee.com/WSakuraM/last-mandate.git
- 提交署名：Sakura \<1124114910@qq.com\>

## 备份

- 本机计划任务每天 16:00 运行 `scripts/daily_backup.ps1`
- 有改动则 commit，并 `push origin` + `push gitee`

## 下一版预期（0.1.0 / M1）

- Godot 工程初始化
- 第一幕最小循环场景树与存档 Resource 结构
