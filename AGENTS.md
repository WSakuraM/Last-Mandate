# AGENTS.md — 《末命》Last Mandate 跨机器 / 跨 Agent 接手手册

> **任何新 Agent 或新电脑：先读完本文，再改代码或设计。**  
> 人类快速入口也可从 [README.md](README.md) 进来。

---

## 0. 一句话是什么

PC Steam、简体中文、**悲剧定轨**历史叙事**3D 俯视角模拟经营**游戏。玩家从**信王府 3D 俯视经营** → 登基后残酷朝堂抉择 → 破城短 3D → 煤山第一人称上吊与回忆终章。  
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
| 1.5 | [docs/REMAKE_BLUEPRINT.md](docs/REMAKE_BLUEPRINT.md) | **3D 重制总纲（单一事实源）** |
| 2 | [docs/story/00_剧本总览.md](docs/story/00_剧本总览.md) | 剧本细稿总览（重制中） |
| 3 | [archive/index.md](archive/index.md) | 当前生效设计版本 |
| 4 | [archive/VERSION](archive/VERSION) | 产品版本号 |
| 5 | [docs/01_定位愿景.md](docs/01_定位愿景.md) | 主题与定位 |
| 5b | [docs/09_M1经营设计.md](docs/09_M1经营设计.md) | M1 经营/货币/小故事（改玩法必读） |
| 6 | [docs/story/11_剧情总流程.md](docs/story/11_剧情总流程.md) | 剧情总流程与跨度（讲故事一张图） |
| 7 | [docs/05_里程碑.md](docs/05_里程碑.md) | 做到哪、不做什么 |

Cursor 规则（克隆后自动可用）：

- [`.cursor/rules/dual-remote-push.mdc`](.cursor/rules/dual-remote-push.mdc) — 提交必须推 GitHub + Gitee  
- [`.cursor/rules/design-traceability.mdc`](.cursor/rules/design-traceability.mdc) — 设计迭代必须 `archive/` 留痕  

---

## 2. 当前状态（写代码前必看）

| 项 | 状态 |
|---|---|
| 产品版本 | **0.1.0（3D 重制）** 蓝图 + **M1 3D 俯视切片**（`game/`）· 总纲见 [`docs/REMAKE_BLUEPRINT.md`](docs/REMAKE_BLUEPRINT.md) |
| 剧本入口 | [`docs/story/00_剧本总览.md`](docs/story/00_剧本总览.md)（重制中） |
| 美术 | **3D 风格化低模明末**（暗调厚涂/版画质感；土褐·赭石·褪青·暗金；雾气暗角） |
| 引擎工程 | **已建**：用 Godot 4.7 打开 [`game/`](game/)（3D 工程；旧 2D 切片归档 `game/_legacy_2d/`） |
| 预定引擎 | **Godot 4**（MIT，永久免费） |
| 平台 / 语言 | PC Steam · 简体中文 |
| 结局 | **悲剧定轨煤山第一人称**（含回忆蒙太奇）；无「真·中兴通关」 |
| 不做 | AI 诏书、纯 2D 呈现、大地图实时征战、开放世界 3D 北京、次世代写实人脸（见 milestones） |

下一里程碑：**M1** — 第一幕最小循环 + 夜召演出（见 `docs/05_里程碑.md`）。

---

## 3. 仓库地图

```text
Last-Mandate/
├── AGENTS.md                 ← 你在这里（跨 Agent 手册）
├── README.md                 ← 人类短入口
├── docs/                     ← 工作稿（可改写；中文文件名）
│   ├── 文档索引.md           ← 本目录索引
│   ├── DAILY_LOG.md          ← 每日工作日志（单文件按日改）
│   ├── REMAKE_BLUEPRINT.md   ← **3D 重制总纲（单一事实源）**
│   ├── 01_定位愿景.md
│   ├── 02_故事圣经.md         ← 重制中
│   ├── 03_数值系统.md         ← 已重制（3D 俯视）
│   ├── 04_美术音频.md         ← 重制中（3D 低模明末）
│   ├── 05_里程碑.md
│   ├── 06_回忆碎片.md         ← 重制中（人民疾苦权重）
│   ├── 07_Git双远程.md
│   ├── 08_双机交叉开发.md   ← 双电脑交叉开发流程
│   ├── 09_M1经营设计.md      ← 已重制（3D 俯视）
│   ├── UI_3D_spec.md         ← 新建（3D 俯视 UI/UX 规范）
│   ├── art_characters.md     ← 新建（人物建模规范，重制中）
│   └── story/                ← 剧本细稿（重制中）
├── archive/                  ← 版本化冻结稿（SemVer，不覆盖旧版）
│   ├── VERSION / CHANGELOG.md / index.md
│   ├── vision|story|systems|ui|tech|plan|art_audio/
│   └── decisions/            ← ADR
├── data/issues/              ← 第二幕议题 JSON
├── game/                     ← **Godot 4 3D 工程**（新）；`game/_legacy_2d/` 为旧 2D 切片归档
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
2. **三幕变奏**：暖经营（**3D 俯视**） → 残酷朝堂 → 短 3D / 煤山第一人称。  
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

**开工前必须 pull，收工必须 push 两边**，否则另一台会丢改动或冲突。详见 [docs/08_双机交叉开发.md](docs/08_双机交叉开发.md)。

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
- 不确定范围 → 先读 `docs/05_里程碑.md` 的「不做清单」

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
| 改剧情 / 场次 | `docs/02_故事圣经.md` + `archive/story/*` + `docs/06_回忆碎片.md` |
| 改数值 / 议题 | `docs/03_数值系统.md` + `docs/09_M1经营设计.md` + `data/issues/` |
| 改 UI | `archive/ui/ui_*.md` + `docs/04_美术音频.md` |
| 开 Godot / M1 | `archive/tech/tech_*.md` + `docs/05_里程碑.md` M1 |
| 只同步双机 | `docs/08_双机交叉开发.md` |

---

## 9. 对外链接

- GitHub：https://github.com/WSakuraM/Last-Mandate  
- Gitee：https://gitee.com/WSakuraM/last-mandate  

历史声明：历史戏说；悲剧命运为设计选择。
