# CLAUDE.md — 给 Claude Code 的接手入口

本项目是《末命》Last Mandate：Godot 4 3D 俯视角、简体中文、**悲剧定轨**历史叙事模拟经营游戏（崇祯朱由检）。

## 第一步（必做）

**先读 [`AGENTS.md`](AGENTS.md)** —— 它是跨 Agent 接手手册，包含：

- 项目定位、硬约束（悲剧定轨、气数锁底 4 不可清零、五资源、三幕结构）
- 仓库地图与当前进度
- Git 双远程（GitHub + Gitee）push 规则
- Agent 行为 Do/Don't
- **第一幕（M1）代码地图**（25 个 .gd 脚本职责 + EventBus 信号 + 回忆碎片键 + 议题 RES_MAP）

## 其他必读顺序

见 AGENTS.md §1。涉及设计迭代须留痕到 `docs/` 与 `archive/`（SemVer，不覆盖旧版，详见 AGENTS.md §7）。

## 关键决策与"为什么"

见 [`docs/05_关键决策.md`](docs/05_关键决策.md)（冻结→解冻、建模同名替换、锁底 4、令牌安全等）。

## 提交纪律

提交后必须 `git push origin main` 与 `git push gitee main`（两边都要推，禁止只推一个就报"已备份"）。
