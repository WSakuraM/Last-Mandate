# 支线水墨下线动画（0.0.5 补丁）

> 品类：美术演出 · 冻结于 2026-08-21  
> 相对产品版本：**0.0.5** 附加演出层（主视觉仍为风格 C 赛璐璐）

## 决策

- 主场景仍用风格 C；**仅在支线角色「最后下线 / 弧线收束」时**插入宣纸水墨短片。
- 气质参考《凡人修仙传》水墨插页：墨晕、消散、留白，不作日常 UI。

## 内容

- 10 角色 × 3 帧：`eunuch` / `gate_child` / `weaver` / `gate_soldier` / `relief` / `qiushui` / `lin_sheng` / `zhou` / `shen` / `liu`
- 路径：`game/assets/models/characters/ink_farewell/{id}/01–03.png`
- 播放：`InkFarewell` autoload；flag `ink_farewell_{id}` 防重复

## 触发

| 类型 | 角色 | 时机 |
|---|---|---|
| 离场 | 中使、门童、织妇、老兵、流民、秋穗、林生 | vignette / 危机 / 邸报结束后 |
| 定格留府 | 周氏、沈戍、柳筝 | 首次园语 / 鸳鸯糖戏后 |

## 与风格 C 的关系

水墨为**叙事Punctuation**，不替换赛璐璐日常美术。
