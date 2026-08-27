# 议题卡索引 v0

本目录为**设计参考**；Godot 运行时读取 `game/data/issues/`（须同步维护）。

---

## 第二幕 · B 系列（24 张）

达到全案「25–40 张」可运行下限；可按 `_schema.json` 追加至 40。

| ID | 标题 | 阶段 | once |
|---|---|---|---|
| ISSUE_WEI_ZHONGXIAN | 魏忠贤案 | B1 | yes |
| ISSUE_DONGCHANG_AFTERMATH | 厂卫善后 | B1/B2 | yes |
| ISSUE_CLEAR_FACTION | 清流请诛余党 | B1/B2 | no |
| ISSUE_REPLACE_CHANCELLOR | 更易阁臣 | B2/B5 | no |
| ISSUE_MINISTER_IMPEACH | 言官交章 | B2/B5 | no |
| ISSUE_CAPITAL_GRAIN | 京仓储粮 | B2/B4 | no |
| ISSUE_SALT_MONOPOLY | 盐引整顿 | B2/B3 | no |
| ISSUE_YUAN_SUPERVISOR | 督师入对 | B3 | yes |
| ISSUE_LIAO_TAX | 辽饷加派 | B3/B4 | no |
| ISSUE_YUAN_FATE | 督师生死 | B3/B5 | yes |
| ISSUE_BORDER_ALARM | 边警入口 | B3/B5 | no |
| ISSUE_ARMY_MUTINY | 缺饷哗变 | B3/B5 | no |
| ISSUE_SPY_LIAO | 反间与疑 | B3/B5 | no |
| ISSUE_CUT_YI | 裁撤驿递 | B4 | yes |
| ISSUE_RELIEF_FAMINE | 旱蝗赈灾 | B4/B5 | no |
| ISSUE_JIANGNAN_TAX_RIOT | 江南抗税 | B4/B5 | no |
| ISSUE_LOCUST | 飞蝗蔽日 | B4/B5 | no |
| ISSUE_REFUGEE_CAMP | 京畿流民营 | B4/B5 | no |
| ISSUE_RUMOR_REBEL | 驿卒起事传闻 | B4/B5 | yes |
| ISSUE_FLOOD_YELLOW | 河决告急 | B4/B5 | no |
| ISSUE_PRIVATE_TREASURY | 内帑救急 | B3–B5 | no |
| ISSUE_READING_MEMORIALS | 彻夜批红 | B2/B5 | no |
| ISSUE_WINTER_SURVIVE | 又撑过一冬 | B3–B5 | no |
| ISSUE_PRINCESS_ESCAPE | 后宫安危 | B6 | yes |

---

## 第一幕 · A1 系列（15 张，在 `game/data/issues/`）

| order | ID | 标题 | unlock_day |
|---|---|---|---|
| 1 | ISSUE_A1_CHENGEN | 承恩夜话 | 1 |
| 2 | ISSUE_A1_NIGHT_STUDY | 书房夜读 | 10 |
| 3 | ISSUE_A1_FRUGAL | 戒奢省用 | 15 |
| 4 | ISSUE_A1_OLD_SERVANT | 老仆病殁 | 35 |
| 5 | ISSUE_A1_NEW_YEAR | 府中岁时 | 45 |
| 6 | ISSUE_A1_DROUGHT | 旱象初显 | 55 |
| 7 | ISSUE_A1_RELIEF_REFUGEE | 府门外流民 | 65 |
| 8 | ISSUE_A1_WELL_CHILD | 水井童殇 | 80 |
| 9 | ISSUE_A1_NEIGHBOR_FAMINE | 邻县告饥 | 90 |
| 10 | ISSUE_A1_BITTER_COLD | 冬日奇寒 | 105 |
| 11 | ISSUE_A1_BORDER_INTEL | 边关谍报 | 110 |
| 12 | ISSUE_A1_LIAO_TAX | 辽饷苗头 | 120 |
| 13 | ISSUE_A1_COURT_RIVALRY | 朝臣倾轧 | 130 |
| 14 | ISSUE_A1_REBEL_SPARK | 流寇初现 | 138 |
| 15 | ISSUE_A1_EVE_OF_ACCESSION | 入继前夜 | 145 |

机制：按 `order` 升序 + `unlock_day` 分段解锁 + 线性消耗（各演 1 次）。详见 `docs/15_M1经营设计.md` §4b。

---

数值均为 v0 草案，以 `docs/08_数值系统.md` 调参表为准做平衡迭代。
