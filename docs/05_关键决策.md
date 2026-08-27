# 关键决策与过程记录（跨 Agent 可移植）

> 本文件从 WorkBuddy 私有记忆（`.workbuddy/memory/`）移植而来，确保**任何 Agent 工具**（Cursor / Claude Code / Trae / Codex / CodeBuddy）都能读到"为什么这么定"，切换 Agent 不丢上下文。
> 配合根目录 [`AGENTS.md`](AGENTS.md) §3.5（M1 代码地图）使用。

---

## 1. 代码冻结 → 解冻（2026-08-22 → 08-23）

- **08-22**：用户明确"在玩法设计 / 主线 / 支线剧情正式敲定之前，禁止改动 `game/` 下任何代码与资源"。期间只做设计讨论与文档。
- **08-23**：用户连续明确指令"从 M1A1 开始写玩法""先 M1A2 再 M1A3""继续"（M1A4 / 区块二 / 区块三 / 区块四），**视为解冻**，四区块全部落地（本地提交 `caf07a0`）。
- **含义**：设计文档 [`docs/story/13_设计敲定记录.md`](story/13_设计敲定记录.md) 已标注"冻结期已结束，可明确指令解冻后按待落地清单实现"。**任何 Agent 在用户未明确推翻前，按已敲定设计继续实现即可，无需重新冻结。**

---

## 2. 占位建模可同名替换（不改代码）

- `game/` 下 12 个 `.tscn` 为程序化占位灰盒。后续换 AI 精模：**覆盖同名文件即换，不改代码**。
- 约束：菜畦 `plot_01~06` 须保留 `Soil` / `Crops` 节点名（`CourtPlot` 状态机按名引用）。
- 生成器：[`game/scripts/tools/gen_placeholders.gd`](../game/scripts/tools/gen_placeholders.gd)（SceneTree 脚本，含 `_set_owner_recursive` 修复 `PackedScene.pack()` 丢失子节点）。

---

## 3. 气数锁底 4.0（不可清零）

- `ResourceManager.mandate_decay` 永不低于 4.0。无"真·中兴通关"结局。HUD 显示"天命" + 锁底标记"▎锁底 4 · 不可清零"。
- 终章蒙太奇 `IssueManager.draw_montage(8)` 严格优先填满 Ⅲ类（人民疾苦）名额，剩余补 Ⅰ/Ⅱ 类。

---

## 4. 私囊（private_purse）字段

- 为用户个人银两，与天下官银区分。M1A1 教程写入；QiuShui / Eunuch 事件消耗。
- `ResourceManager` 与 `Act1Closure.save_state()` 均纳入存档。

---

## 5. Git 双远程与令牌安全

- 远程：`origin`（GitHub `https://github.com/WSakuraM/Last-Mandate.git`）+ `gitee`（`https://gitee.com/WSakuraM/last-mandate.git`）。提交须两边都 push。
- ⚠️ **曾于聊天明文泄露 GitHub PAT 与 Gitee 令牌 → 已提醒用户撤销。** 新 Agent **不要在聊天 / 代码 / 配置中写入明文令牌**；用 credential helper 或让用户提供一次性注入（推完不留痕）。
- 当前本地领先远程（caf07a0 等提交待 push），需用户在已登录终端执行 `git push origin main && git push gitee main`。

---

## 6. Godot 4.7 严格类型注意

- `var x := <Variant 返回>` 推断失败 → 显式 `: Type =` 或 `Type(...)` cast（如 `:= bool(...)`、`var cal: Dictionary =`）。
- 本机 Godot 二进制可用于 headless 校验（见 AGENTS.md / WorkBuddy `godot-headless-validate` 技能）。

---

## 7. 当前进度（截至 2026-08-23）

- 第一幕四区块全部落地（caf07a0，本地领先远程，待用户 push）。
- 未推：caf07a0 等本地提交需 `git push origin main && git push gitee main`。
- 后续方向：补第二幕朝堂 / 终章煤山建模、换 AI 精模替换占位灰盒、按敲定记录写第二幕代码、Godot 实跑完整第一幕 150 天流程。
