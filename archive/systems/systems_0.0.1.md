# 《末命》系统与数值设计 v0

> 引擎无关设计文档；落地时以 JSON/资源表导入 Godot。  
> 原则：五资源封顶；个人可调；**MandateDecay 不可清零**。

---

## 一、全局存档结构（逻辑模型）

```text
SaveGame
├── meta: version, playtime, act (1|2|3), seed
├── traits: { diligence, mercy, suspicion, thrift, ... }  // 0–3 或布尔
├── resources: { treasury, popular, frontier, court, resolve }
├── mandate_decay: float 0–100
├── rebel_pressure: float 0–100
├── relations: { wang_cheng_en, wei, ministers... }
├── memory_fragments: [ { id, weight, tags[], act, choice_label } ]
├── act1: farm/workshop/inventory/year/season
└── flags: string[]  // 剧情开关
```

统一原则：换幕后只换场景与输入，**不换** `memory_fragments` 与 `traits`。

---

## 二、第一幕经营系统

### 时间

- 一年 = 春夏秋冬 4 季；每季若干行动日（建议 **6–8 行动点/季**）。
- 默认 3 年；可在设置中缩为 2 年（跳过 Y3 日常，保留夜召）。

### 资源（幕内）

| 资源 | 说明 |
|---|---|
| 铜钱/银 | 售卖、贿赂、援助 |
| 体力 | 每日行动限制 |
| 作物库存 | 菜、药、鱼、酒、布 |
| 人心（府内） | 下人态度；映射承恩好感与 Traits |

### 地块与作坊

| 设施 | 深度 | 备注 |
|---|---|---|
| 菜圃 | 深 | 主循环 |
| 药圃 | 中 | 旱时更值钱 |
| 鱼塘 | 浅 | 稳定小收入 |
| 酒作坊 | 深 | 秋解锁向 |
| 纺作坊 | 深 | 需银启动 |

**冻结**：首发不做陶作坊。

### 轻危机（教会取舍）

旱、涝、虚账、争水、中使索贿、近村求赈 —— 每项写入可选 MemoryFragment。

### 结算 → 第二幕

```text
StartingTreasuryBonus = clamp(银钱换算, 0, +15)
mercy += 赈济/分粮次数贡献
suspicion += 严查/拒贿次数贡献
thrift += 低消费高储蓄
wang_cheng_en_bond = 阿恩事件完成数
```

具体系数见文末「调参表」。

---

## 三、第二幕五资源

全部建议显示为 **0–100** 整数；UI 用色带（绿/黄/红）。

| ID | 中文 | 低时后果 | 高时观感 |
|---|---|---|---|
| `treasury` | 内帑/国库 | 禁发大议、边军哗变风险 | 「尚有钱可烧」 |
| `popular` | 民心 | 流民↑、MandateDecay↑ | 短暂安稳 |
| `frontier` | 边军战力 | 边警灾难、破城提前 | 耗饷 |
| `court` | 朝堂秩序 | 议而不决、政令打折 | 派系僵持亦会损 |
| `resolve` | 君心（执念/急躁） | 过低：无行动力 | **过高**：强制换相、误杀忠谏风险 |

### 每旬循环

```text
1. 展示国势与季节危机预告
2. 抽 1–3 张当朝议题（阶段权重表）
3. 玩家批红（每题一选）
4. 应用 delta；人物关系更新；写 MemoryFragment
5. 被动结算：粮饷消耗、MandateDecay 自然增长、rebel_pressure
6. 检查进入 B6 / 第三幕条件
```

### 自然消耗（每旬）

| 项 | 草案 |
|---|---|
| treasury | -1 ~ -3（视 frontier 编制） |
| popular | frontier 高加派时额外 -1 |
| resolve | 若本旬处理议题 ≥3：+1 |

---

## 四、MandateDecay（气数）— 定轨核心

### 定义

隐藏进度 `mandate_decay ∈ [0, 100]`。  
玩家可见为模糊文案（「气数」「天意」「漏船」），**不显示精确百分比**（或仅在调试开）。

### 增长（每旬结算后）

```text
base = 0.35                          # 结构性崩溃：再优秀也涨
base += (popular < 30) ? 0.4 : 0
base += (treasury < 20) ? 0.3 : 0
base += (frontier < 25) ? 0.25 : 0
base += (court < 25) ? 0.2 : 0
base += (resolve > 70) ? 0.35 : 0   # 急躁惩罚
base += stage_bonus                  # B4+0.15, B5+0.3
mandate_decay += base
# 延缓手段：优秀批红可 mandate_decay -= 0.1~0.5（单旬），但净增长长期仍为正
```

### 清零禁止

任何选项不得 `mandate_decay = 0`。  
单旬最大减免 **0.5**；且 `base` 始终 ≥ 0.2。

### 流贼进逼 `rebel_pressure`

```text
每旬 += 0.3
若曾裁驿：+0.15/旬（永久修正）
若多次严剿流民：短期 -0.2，随后 +0.4/旬（反弹）
若开仓赈灾：-0.2（有限次数）
```

### 进入第三幕条件

```text
(mandate_decay >= 85 AND rebel_pressure >= 70)
OR (mandate_decay >= 95)
OR (rebel_pressure >= 95)
OR (强制剧情旗 ACT2_FORCE_FALL)
```

触发后播放 B6，再进 3A。

---

## 五、议题系统

### 议题卡片字段

```json
{
  "id": "ISSUE_WEI_ZHONGXIAN",
  "title": "魏忠贤案",
  "stage": ["B1"],
  "weight": 100,
  "once": true,
  "summary": "阉党首恶伏阙，清流请诛。",
  "choices": [
    {
      "id": "kill",
      "label": "赐死抄家",
      "deltas": { "popular": 8, "court": -5, "resolve": 5 },
      "flags_add": ["wei_dead"],
      "memory": "MF_A2_WEI_KILL",
      "memory_weight": 8
    }
  ]
}
```

### 阶段抽取权重（示意）

| 阶段 | 高权重簇 |
|---|---|
| B1 | 魏忠贤、厂卫善后 |
| B2 | 换相、清吏 |
| B3 | 督师、辽饷 |
| B4 | 裁驿、赈灾、流民 |
| B5 | 换相循环、边警、蝗旱、抗税 |

随机议题从 `data/issues/` 读取；`once: true` 的主线题必插入。

---

## 六、第三幕系统（短关）

### 资源简化

- **小队人数**（开场被旁白夸大为五千，实际 8–12）  
- **火把/弹药**有限  
- **时间压力条**（鼓噪逼近煤山窗口）

### 失败

战斗失败 ≠ Game Over：切入「力竭抬至山下」表象，仍进 3B。

### 终章

- 血诏：枚举句，默认「勿伤我百姓」。  
- 回忆：见 `docs/06_memory_fragments.md`。

---

## 七、调参表 v0（可调）

| 参数 | 初值 | 说明 |
|---|---|---|
| `DECAY_BASE` | 0.35 | 每旬气数底涨 |
| `DECAY_RELIEF_CAP` | 0.5 | 单旬最大减免 |
| `ACT3_DECAY_TH` | 85 | 与流贼双条件阈值 |
| `ACT3_DECAY_HARD` | 95 | 单条件硬进 |
| `ACT3_REBEL_TH` | 70 | 双条件流贼阈值 |
| `ACT1_YEARS_DEFAULT` | 3 | 王府年数 |
| `ACT3_TARGET_MIN` | 30 | 分钟，设计目标 |
| `ACT3_TARGET_MAX` | 90 | 分钟 |

平衡口诀：**让玩家觉得自己很努力，统计上仍在 B5 中后期坠入 B6。**

---

## 八、不做清单（系统向）

- 大地图实时征战  
- AI 自然语言诏书  
- 超过 5 条主资源  
- 可清空的 MandateDecay  
- 「中兴胜利」结算画面  

详见 `docs/05_milestones.md`。
