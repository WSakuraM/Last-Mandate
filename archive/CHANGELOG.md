# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 风格，版本号见 [archive/README.md](README.md)。

格式：`Added` / `Changed` / `Fixed` / `Removed` / `Docs`。

---

## [Unreleased]

### Added

- 风格 C **正式木框 UI**：资源条 / 目标 / 时钟 / 对白 / Toast / Tip / 抉择按钮；对白旁立绘色槽。见 `archive/ui/ui_0.0.3.md`。
- **支线水墨下线动画**（10 角色 × 3 帧）+ `InkFarewell` 播放器。见 `archive/art_audio/ink_farewell_0.0.5.md`。

### Changed

- 取消 Windows 计划任务 `LastMandate-DailyBackup-1600`；不再每日 16:00 自动备份。

---

## [0.0.5] - 2026-08-20

### Docs

- 画面定案 **风格 C 赛璐璐**：`docs/画面风格定案_C.md` → `archive/art_audio/art_style_C_0.0.5.md`。

### Added

- Kenney Interface / RPG Audio（CC0）入库并挂到 `assets/audio/*.ogg`。
- OpenGameArt CC0 粮袋/农舍图入 `models/`。
- 程序绘制改为赛璐璐描边平涂（地表/角色/菜畦/灌木）。

### Note

- itch Great Farm / Hand-Drawn 仍因公司网超时未下到；回家下载后挂接。

---

## [0.0.4] - 2026-08-20

### Docs

- 工作稿中文命名：`docs/`、`docs/story/`（`game/` 程序路径仍英文）。
- 天气/天灾/活物设计：`docs/10_天气天灾与活物.md` → `archive/systems/weather_life_0.0.4.md`。

### Added

- M1：四季、晴雨雪风、旱蝗暴雨涝、日气力、活物与植被轻动。

---

## [0.0.3] - 2026-08-20

### Docs

- 冻结 **M1 模拟经营设计**：经营对象、浅升级、货币（私囊铜钱）、王爷亲耕理由、时局 vignette。
- 系统工作稿同步：一幕账本三分、可采灌木、升级浅树；明确不做矿洞/大地图。
- 新增 vignette 索引 `docs/story/08_时局小故事.md`。
- **后妃情爱线**：周皇后、田贵妃、袁贵妃写入剧本；`docs/story/09_后妃线.md` → `archive/story/consorts_0.0.3.md`。
- **苦命鸳鸯**：沈戍×柳筝三幕虐恋；`docs/story/10_护卫鸳鸯.md` → `archive/story/guard_lovers_0.0.3.md`。
- 剧情总流程图与七种跨度：`docs/story/11_剧情总流程.md` → `archive/story/plot_flow_0.0.3.md`
### Added

- `docs/09_M1经营设计.md` → archive `plan/plan_0.0.2.md`
- `archive/systems/systems_0.0.2.md`

---

## [0.0.2] - 2026-08-20

### Docs

- 剧本细稿包 `docs/story/`：世界观/人物关系/大小节点流程图、三幕场景与对白。
- 确认美术方向：水墨勾边 2D。
- 朱由检人物史实补完（【史】【民】【虚】标注）。
- 主题升华：尽责加速清算。

### Added

- 虚构阁臣三原型（周怀清/高算/马可立）与谷种母题。
- 跨电脑手册 AGENTS.md（既有）继续有效。

---

## [0.0.1] - 2026-08-20

### Docs

- M0 设计冻结：定位、故事圣经、系统、议题 JSON、回忆碎片、美术音频、里程碑。
- 建立 `archive/` 留痕体系与 SemVer 规范。
- 配置 GitHub + Gitee 双远程；每日 16:00 本地备份脚本。

### Added

- 议题卡可运行子集（24 张）与 schema。
- Cursor 规则：双远程推送、设计留痕。
