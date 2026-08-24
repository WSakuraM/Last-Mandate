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
git clone git@gitee.com:WSakuraM/last-mandate.git
# 或
git clone git@github.com:WSakuraM/Last-Mandate.git

cd last-mandate   # 或 Last-Mandate

# 本仓库身份（勿改全局，除非你自己要）
git config user.name "Sakura"
git config user.email "1124114910@qq.com"

# 若只 clone 了一个远程，把另一个也加上
git remote add origin git@github.com:WSakuraM/Last-Mandate.git   # 若缺
git remote add gitee  git@gitee.com:WSakuraM/last-mandate.git  # 若缺
git remote -v

# ⚠️ 本仓库只走 SSH（22 端口），勿用 https。WorkBuddy 沙箱出不了 https/443，
# 必须 SSH + 公钥。公钥已加到 GitHub/Gitee；私钥在 D:\GameTool\.ssh_keys\id_ed25519
# （仓库级 core.sshCommand 已指向，详见 §5）。
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
| 7.5 | [docs/KEY_DECISIONS.md](docs/KEY_DECISIONS.md) | **关键决策与"为什么"**（冻结→解冻、建模替换、锁底4、令牌安全） |
| 7.6 | 本文件 §3.5 | **改 M1 代码前必读**：25 脚本职责 + EventBus 信号 + 回忆碎片键 + RES_MAP |

Cursor 规则（克隆后自动可用）：

- [`.cursor/rules/dual-remote-push.mdc`](.cursor/rules/dual-remote-push.mdc) — 提交必须推 GitHub + Gitee  
- [`.cursor/rules/design-traceability.mdc`](.cursor/rules/design-traceability.mdc) — 设计迭代必须 `archive/` 留痕  

---

## 2. 当前状态（写代码前必看）

| 项 | 状态 |
|---|---|
| 产品版本 | **0.1.0（3D 重制）** 蓝图 + **M1 3D 俯视切片**（`game/`）· 总纲见 [`docs/REMAKE_BLUEPRINT.md`](docs/REMAKE_BLUEPRINT.md) |
| 第一幕进度 | **四区块全部落地**（主线 M1A0~M1A5 / 玩法循环 / 支线 6/12 / 跨幕回忆回收），本地提交 `caf07a0`；代码地图见 §3.5 |
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

## 3.5 第一幕（M1）代码地图（实际落地架构）

> 本段描述 [`game/scripts/`](game/scripts) 下 **25 个已落地 .gd** 的真实职责。**改 M1 前先读对应文件**，勿重造已有系统。详见 [`docs/KEY_DECISIONS.md`](docs/KEY_DECISIONS.md)。

### 脚本职责总表

**自动加载 / 管理器（managers/）**

| 文件 | 职责 |
|---|---|
| `managers/EventBus.gd` | 全局事件总线（autoload），解耦 世界↔UI↔系统。信号见下 |
| `managers/ResourceManager.gd` | 五资源（treasury/people/border_army/court_order/emperor_heart）+ **私囊 private_purse** + **气数 mandate_decay（锁底 4.0，不可清零）** |
| `managers/IssueManager.gd` | 议题池 + 回忆碎片管理；`RES_MAP` 翻译议题 JSON 键→资源键；`draw_montage(8)`（Ⅲ类严格优先）/ `draw_blood_edict_faces(3)` |
| `managers/SaveManager.gd` | 全量存档（五资源+回忆+旗标+私囊） |

**入口 / 玩家 / 相机**

| 文件 | 职责 |
|---|---|
| `main/Main.gd` | 场景装配入口 |
| `player/Player.gd` | 玩家移动/交互 |
| `camera/TopDownCamera.gd` | 3D 俯视相机 |

**世界事件（world/）**

| 文件 | 职责 |
|---|---|
| `world/Act1Director.gd` | 第一幕导演：时序 tick、按天触发(15/30/40/50/60/75/105)、装配所有事件实例、监听 narration 浮字 |
| `world/CourtPlot.gd` | 菜畦状态机（fallow→tilled→sown→grown→harvest）；首次播种 emit `first_sow`；种收写回忆钩 |
| `world/ChengEnNPC.gd` | 王承恩随侍 NPC |
| `world/AenSeedEvent.gd` | M1A3 阿恩递种夜谈（监听 `first_sow`） |
| `world/QiuShuiLetterEvent.gd` | M1A4 秋穗家书三选（day≥50） |
| `world/ShenLiuStoryline.gd` | 沈柳鸳鸯线第一幕三拍(day15/40/105) |
| `world/ZhouShiGarden.gd` | 周氏"人不是折子"(day≈30) |
| `world/EunuchFruitEvent.gd` | 中使借果二选(day≈60) |
| `world/CalamityEvent.gd` | 蝗旱涝三选(day≈75)，设 drought flag |
| `world/RefugeeVignette.gd` | 流民 vignette（MF_A1_VIGNETTE_* 家族） |
| `world/WellEvent.gd` | 井边打水事件 |
| `world/MeishanDirector.gd` | 煤山终章四阶段（雪夜独白→血诏脸谱→回忆蒙太奇→渐黑） |

**UI（ui/）**

| 文件 | 职责 |
|---|---|
| `ui/HUD.gd` | 顶栏：五资源 + **天命条**（颜色梯度 + 锁底标记 + ≥70 提示"你救不了这座江山"） |
| `ui/DecisionPanel.gd` | 议题决策面板 |
| `ui/Act1Closure.gd` | 第一幕收束画面 + `SaveManager.save_state()` 全量存档 + 8 条回忆着色 |
| `ui/PrivatePurseTutorial.gd` | M1A1 吴伯私囊教程（4 步银两归类） |
| `ui/DailyVignette.gd` | 夜间池空时的日常小事件填充 |

**工具（不运行时加载）**

| 文件 | 职责 |
|---|---|
| `tools/gen_placeholders.gd` | 占位灰盒生成器（SceneTree 脚本，仅生成用；含 `_set_owner_recursive` 修复 `PackedScene.pack()` 丢子节点） |

### EventBus 信号契约（managers/EventBus.gd，全局）

```
interact_prompt(text)     # 交互提示
interact_hide()           # 隐藏提示
open_issue(data)          # 打开议题
meishan_begin()           # 进入煤山终章
first_sow()               # 首次播种 → 驱动 M1A3 阿恩递种
narration(text)           # 收获旁白浮字（旱象/丰收）
```

其他模块信号：`IssueManager.issue_presented / issue_resolved / memory_added`；`ResourceManager.resources_changed / mandate_changed / day_passed / game_over`；`DecisionPanel.choice_made`；`PrivatePurseTutorial.tutorial_completed`；`ShenLiuStoryline.beat_completed`；`QiuShuiLetterEvent.letter_resolved`；`EunuchFruitEvent.fruit_resolved`；`DailyVignette.dismissed`。

### 回忆碎片键清单（MF_*，终章蒙太奇回收）

| 键 | 权重 | 支柱 | 来源 |
|---|---|---|---|
| MF_A1_PURSE_TUTORIAL | 3 | Ⅰ | 私囊教程 |
| MF_A1_AEN_PROMISE | 9(must) | Ⅰ | 阿恩递种 |
| MF_A1_LAST_SOW | 8 | Ⅰ | 末次播种 |
| MF_A1_BOUNTY_SHARE | 4 | Ⅰ | 丰收分邻 |
| MF_A1_WELL | 4 | Ⅰ | 井边打水 |
| MF_LOVERS_SUGAR | 6 | Ⅰ | 沈柳定情 |
| MF_A1_SHEN_GUARD | 5 | Ⅰ | 沈柳守门 |
| MF_A1_ZHOU_NOT_MEMORIAL | 5 | Ⅰ | 周氏园中 |
| MF_A1_QIUSHUI_LEND | 7 | Ⅰ | 秋穗借粮 |
| MF_A1_QIUSHUI_TOKEN | 4 | Ⅰ | 秋穗象征 |
| MF_A1_QIUSHUI_REFUSE | 3 | Ⅰ | 秋穗婉拒 |
| MF_A1_DROUGHT_HARVEST | 6 | Ⅲ | 旱象减产 |
| MF_A1_LOCUST | 7 | Ⅲ | 蝗灾 |
| MF_A1_EUNUCH_FRUIT | 7 | Ⅲ | 中使借果 |
| MF_A1_VIGNETTE_* | — | Ⅲ | 流民 vignette 家族 |

支柱：Ⅰ信王个人 / Ⅱ朝堂国事 / Ⅲ人民疾苦。蒙太奇 `draw_montage(8)` 严格优先填满 8 个Ⅲ类名额。

### 议题 RES_MAP（IssueManager.gd）

```
议题 JSON 键 → 资源键
treasury→treasury, popular→people, frontier→border_army,
court→court_order, resolve→emperor_heart, mandate_decay→mandate_decay
```

议题数据须放在 Godot 工程内 `game/data/issues/` 才能被 `res://` 读取（仓库根 `data/issues/` 仅作设计参考）。

### 关键历史决策（必读，避免重蹈）

- **冻结→解冻**：2026-08-22 用户冻结 `game/` 代码（玩法/主线/支线敲定前禁改）；2026-08-23 用户明确指令"从 M1A1 开始写玩法"等，**解冻并落地四区块**（caf07a0）。详见 [`docs/KEY_DECISIONS.md`](docs/KEY_DECISIONS.md)。在用户未明确推翻前，按已敲定设计继续实现即可。
- **建模可替换**：`game/` 下 12 个占位 `.tscn` 为灰盒，**按同名文件覆盖即换精模、不改代码**；菜畦需保留 `Soil`/`Crops` 节点名。
- **气数锁底 4.0**：`mandate_decay` 永不低于 4，无"真·中兴通关"。
- **Godot 4.7 严格类型**：`var x := <Variant返回>` 推断失败处需 `: Type =` 或 `Type(...)` 显式注解（如 `:= bool(...)`、`var cal: Dictionary =`）。

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

| 远程 | URL（**仅 SSH，勿用 https**） |
|---|---|
| `origin`（GitHub，已配双 pushurl） | git@github.com:WSakuraM/Last-Mandate.git |
| `gitee` | git@gitee.com:WSakuraM/last-mandate.git |

> ⚠️ **只走 SSH（22 端口）**。WorkBuddy 沙箱出不了 https/443，https + token 方案在其内部必败。
> 公钥已加到 GitHub/Gitee；私钥 `D:\GameTool\.ssh_keys\id_ed25519`，仓库级 `core.sshCommand` 已指向它。
> 本机有网可用 SSH 或 token 自行推，但**沙箱内自动化只认 SSH**。

用户说「提交代码」⇒ `commit` + 一条 **`git push origin main` 即自动双推**（origin 已配 GitHub+Gitee 双 pushurl）。禁止未经要求的 `push --force` 到 main。

### 公司电脑 ↔ 家里电脑

**开工前必须 pull，收工必须 push 两边**，否则另一台会丢改动或冲突。详见 [docs/08_双机交叉开发.md](docs/08_双机交叉开发.md)。

简版（SSH，一条 push 双推）：

```powershell
git pull origin main
# …开发…
git add -A
git commit -m "说明为什么改"
git push origin main     # 自动同时推 GitHub + Gitee
```

网络到不了 GitHub 时：先 `git push gitee main`，回家再补 `git push origin main`（并如实告知用户哪边失败）。

---

## 6. 备份说明

**每日 16:00 计划任务已取消**（原名 `LastMandate-DailyBackup-1600`）。  

请在收工或用户说「提交代码」时：`commit` + 一条 `git push origin main`（已自动双推 GitHub+Gitee，走 SSH）。  
`scripts/daily_backup.ps1` 仅作可选手动工具，**不要再注册定时任务**，除非用户重新要求。

---

## 7. Agent 行为清单（Do / Don’t）

### Do

- 改设计 → 更新 `docs/`，重要定稿写入 `archive/` 新版本号  
- 改议题 → 维护 `data/issues/*.json` 与 README 索引  
- 提交 → 双远程；作者 Sakura / 上述邮箱  
- 不确定范围 → 先读 `docs/05_里程碑.md` 的「不做清单」  
- 改 M1 玩法/代码 → **先读 [`game/scripts/`](game/scripts) 现有 25 个 .gd**（代码地图见 §3.5），勿重造已存在的系统或偏离命名约定

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
| **接手 / 改 M1 代码** | **本文件 §3.5 + [`docs/KEY_DECISIONS.md`](docs/KEY_DECISIONS.md)** |
| 只同步双机 | `docs/08_双机交叉开发.md` |

---

## 9. 对外链接

- GitHub：https://github.com/WSakuraM/Last-Mandate  
- Gitee：https://gitee.com/WSakuraM/last-mandate  

历史声明：历史戏说；悲剧命运为设计选择。
