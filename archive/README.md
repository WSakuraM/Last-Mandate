# 《末命》设计留痕 Archive

本目录存放**可追溯、可迭代**的设计与计划资产。日常可改写的工作稿仍在 [`docs/`](../docs/)；每次有意义的迭代在此**冻结一版**，永不覆盖旧版。

## 版本号规范（定案）

参考独立游戏 / Steam 常见做法，采用 **语义化版本 SemVer**：`MAJOR.MINOR.PATCH`

| 段 | 含义（本作） | 示例 |
|---|---|---|
| **MAJOR** | 正式发售起跳；发售前固定为 `0` | `1.0.0` = 1.0 发售 |
| **MINOR** | 对应开发里程碑 M0–M6（见 `docs/05_milestones.md`） | `0.1.0` = 进入/完成 M1 垂直切片级冻结 |
| **PATCH** | 同里程碑内的设计修订（剧本大改、UI 改版、技术方案替换等） | `0.0.1` → `0.0.2` |

### 里程碑映射

| SemVer 前缀 | 里程碑 | 含义 |
|---|---|---|
| `0.0.x` | M0 | 文档 / 设计冻结期 |
| `0.1.x` | M1 | 第一幕垂直切片 |
| `0.2.x` | M2 | 皇权原型 |
| `0.3.x` | M3 | 定轨验证 |
| `0.4.x` | M4 | 3D 短关 |
| `0.5.x` | M5 | 终章 |
| `0.6.x` | M6 | 打磨上架 |
| `1.0.0` | 发售 | 正式版 |

展示名可写：`0.0.1 (M0 · Design Freeze)`，文件名只用数字：`story_0.0.1.md`。

> 不用单独的 `v1/v2/v3` 当主版本号（易与「第几幕」混淆）；需要口语时可说「第 2 稿」，文件仍落盘为下一个 PATCH。

## 目录结构

```text
archive/
  README.md                 ← 本说明
  CHANGELOG.md              ← 产品向更新日志（Keep a Changelog）
  VERSION                   ← 当前产品版本指针（单行）
  index.md                  ← 各品类「当前生效版」索引
  vision/                   ← 定位与主题
  story/                    ← 剧本 / 故事圣经
  systems/                  ← 玩法与数值方案
  ui/                       ← UI / UX 设计
  tech/                     ← 技术方案（引擎、架构）
  plan/                     ← 项目计划 / 里程碑
  art_audio/                ← 美术音频圣经
  decisions/                ← ADR 决策记录（重要选择）
  daily/                    ← 定时备份运行日志（可选）
```

## 迭代时怎么留痕

1. 在 `docs/` 或对应工作区改内容。  
2. 把**完整定稿**复制到本目录对应品类，文件名：`{品类}_{版本}.md`（如 `ui_0.0.2.md`）。  
3. 更新 [`index.md`](index.md) 的「当前生效」指针。  
4. 在 [`CHANGELOG.md`](CHANGELOG.md) 写一条（中文，面向「这版改了什么」）。  
5. 若是不可逆重大决策，在 `decisions/` 加一条 ADR。

Agent 规则见 [`.cursor/rules/design-traceability.mdc`](../.cursor/rules/design-traceability.mdc)。

## 每日备份

每天 **16:00（本机本地时区）** 由 Windows 计划任务运行 [`scripts/daily_backup.ps1`](../scripts/daily_backup.ps1)：若有未提交改动则自动 commit，并推送到 **GitHub + Gitee**。
