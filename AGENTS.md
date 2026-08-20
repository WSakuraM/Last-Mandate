# AGENTS.md — 《末命》Last Mandate 跨机器 / 跨 Agent 接手手册

> **任何新 Agent 或新电脑：先读完本文，再改代码或设计。**  
> 人类快速入口也可从 [README.md](README.md) 进来。

---

## 0. 一句话是什么

PC Steam、简体中文、**悲剧定轨**历史叙事模拟经营游戏。玩家从信王府 2D 经营 → 登基后残酷朝堂抉择 → 破城短 3D → 煤山第一人称上吊与回忆终章。  
**无论怎么玩，结局核都是煤山**；差异在过程、代价与回忆碎片。

中文名：《末命》｜英文名：Last Mandate｜作者署名：**Sakura** \<1124114910@qq.com\>

---

## 1. 新机器 5 分钟上手

```powershell
# 任选其一（公司网慢 GitHub 时优先 Gitee）
git clone https://gitee.com/WSakuraM/last-mandate.git
# 或
git clone https://github.com/WSakuraM/Last-Mandate.git

cd last-mandate   # 或 Last-Mandate

# 本仓库身份（勿改全局，除非你自己要）
git config user.name "Sakura"
git config user.email "1124114910@qq.com"

# 若只 clone 了一个远程，把另一个也加上
git remote add origin https://github.com/WSakuraM/Last-Mandate.git   # 若缺
git remote add gitee  https://gitee.com/WSakuraM/last-mandate.git  # 若缺
git remote -v
```

然后按顺序阅读：

| 顺序 | 文件 | 目的 |
|---|---|---|
| 1 | **本文件 AGENTS.md** | 约束与地图 |
| 2 | [archive/index.md](archive/index.md) | 当前生效设计版本 |
| 3 | [archive/VERSION](archive/VERSION) | 产品版本号 |
| 4 | [docs/01_vision.md](docs/01_vision.md) | 主题与定位 |
| 5 | [docs/05_milestones.md](docs/05_milestones.md) | 做到哪、不做什么 |
| 6 | 按任务再读 story / systems / ui / tech |

Cursor 规则（克隆后自动可用）：

- [`.cursor/rules/dual-remote-push.mdc`](.cursor/rules/dual-remote-push.mdc) — 提交必须推 GitHub + Gitee  
- [`.cursor/rules/design-traceability.mdc`](.cursor/rules/design-traceability.mdc) — 设计迭代必须 `archive/` 留痕  

---

## 2. 当前状态（写代码前必看）

| 项 | 状态 |
|---|---|
| 产品版本 | **0.0.1**（M0 设计冻结） |
| 引擎工程 | **尚未创建 Godot 工程**；现阶段以文档与数据为主 |
| 预定引擎 | **Godot 4**（MIT，永久免费） |
| 平台 / 语言 | PC Steam · 简体中文 |
| 结局 | **悲剧定轨煤山**（2A）；无「真·中兴通关」 |
| 不做 | AI 诏书、大地图实时征战、开放世界 3D 北京等（见 milestones） |

下一里程碑：**M1** — 第一幕最小循环 + 夜召演出（见 `docs/05_milestones.md`）。

---

## 3. 仓库地图

```text
Last-Mandate/
├── AGENTS.md                 ← 你在这里（跨 Agent 手册）
├── README.md                 ← 人类短入口
├── docs/                     ← 工作稿（可改写）
│   ├── 01_vision.md
│   ├── 02_story_bible.md
│   ├── 03_systems.md
│   ├── 04_art_audio.md
│   ├── 05_milestones.md
│   ├── 06_memory_fragments.md
│   ├── 07_git_github.md
│   └── 08_cross_machine.md   ← 双电脑交叉开发流程
├── archive/                  ← 版本化冻结稿（SemVer，不覆盖旧版）
│   ├── VERSION / CHANGELOG.md / index.md
│   ├── vision|story|systems|ui|tech|plan|art_audio/
│   └── decisions/            ← ADR
├── data/issues/              ← 第二幕议题 JSON
├── scripts/
│   ├── daily_backup.ps1      ← 可选手动备份脚本（定时任务已取消）
│   └── register_daily_backup_task.ps1  ← 已不推荐使用
└── .cursor/rules/            ← Agent 强制约定
```

**工作稿 vs 冻结稿：** `docs/` 可迭代；有意义定稿复制到 `archive/{品类}/{品类}_0.Y.Z.md`，更新 `archive/index.md` 与 `CHANGELOG.md`。

版本号：**SemVer `MAJOR.MINOR.PATCH`**，发售前 MAJOR=0，MINOR 对齐 M0–M6。说明见 [archive/README.md](archive/README.md)。

---

## 4. 玩法与叙事硬约束（勿改方向）

1. **悲剧定轨**：可延缓气数，不可清零 `MandateDecay`；无胜利 UI。  
2. **三幕变奏**：暖经营 → 残酷朝堂 → 短 3D / 煤山第一人称。  
3. **统一存档灵魂**：Traits、关系、MemoryFragments 跨幕保留。  
4. **王承恩**为情感锚；血诏默认「勿伤我百姓」。  
5. **不依赖大模型**做玩法核心（脚本事件 + 数值）。

核心资源仅 5 条：国库、民心、边军、朝堂秩序、君心。

---

## 5. Git：双远程与交叉开发

| 远程 | URL |
|---|---|
| `origin`（GitHub） | https://github.com/WSakuraM/Last-Mandate.git |
| `gitee` | https://gitee.com/WSakuraM/last-mandate.git |

用户说「提交代码」⇒ `commit` + **两边都 push**。禁止未经要求的 `push --force` 到 main。

### 公司电脑 ↔ 家里电脑

**开工前必须 pull，收工必须 push 两边**，否则另一台会丢改动或冲突。详见 [docs/08_cross_machine.md](docs/08_cross_machine.md)。

简版：

```powershell
git pull origin main
# …开发…
git add -A
git commit -m "说明为什么改"
git push origin main
git push gitee main
```

网络到不了 GitHub 时：先 `git push gitee main`，回家再补 `git push origin main`（并如实告知用户哪边失败）。

---

## 6. 备份说明

**每日 16:00 计划任务已取消**（原名 `LastMandate-DailyBackup-1600`）。  

请在收工或用户说「提交代码」时：`commit` + `push origin` + `push gitee`。  
`scripts/daily_backup.ps1` 仅作可选手动工具，**不要再注册定时任务**，除非用户重新要求。

---

## 7. Agent 行为清单（Do / Don’t）

### Do

- 改设计 → 更新 `docs/`，重要定稿写入 `archive/` 新版本号  
- 改议题 → 维护 `data/issues/*.json` 与 README 索引  
- 提交 → 双远程；作者 Sakura / 上述邮箱  
- 不确定范围 → 先读 `docs/05_milestones.md` 的「不做清单」

### Don’t

- 上 Unreal/Unity 替换引擎（除非用户明确改决策）  
- 做 AI 原生诏书、真通关中兴、清空气数  
- 覆盖 `archive` 旧版文件  
- 只推一个远程就报「已备份」  
- 在未建 Godot 工程前空谈大规模 3D 实现细节而不落文档  

---

## 8. 建议阅读深度（按任务）

| 任务 | 必读 |
|---|---|
| 改剧情 / 场次 | `docs/02_story_bible.md` + `archive/story/*` + `docs/06_memory_fragments.md` |
| 改数值 / 议题 | `docs/03_systems.md` + `data/issues/` |
| 改 UI | `archive/ui/ui_*.md` + `docs/04_art_audio.md` |
| 开 Godot / M1 | `archive/tech/tech_*.md` + `docs/05_milestones.md` M1 |
| 只同步双机 | `docs/08_cross_machine.md` |

---

## 9. 对外链接

- GitHub：https://github.com/WSakuraM/Last-Mandate  
- Gitee：https://gitee.com/WSakuraM/last-mandate  

历史声明：历史戏说；悲剧命运为设计选择。
