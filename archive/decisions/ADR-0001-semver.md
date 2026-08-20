# ADR-0001 · 采用 SemVer 作为设计/产品版本号

- 状态：Accepted
- 日期：2026-08-20
- 决策者：Sakura

## 背景

需要为 UI、剧本、计划等资产留痕；口语「v1/v2」易与三幕结构混淆。

## 决策

采用 `MAJOR.MINOR.PATCH`，发售前 MAJOR=0，MINOR 对齐里程碑 M0–M6，PATCH 为同里程碑修订。

## 后果

- 文件名：`{品类}_{0.Y.Z}.md`
- 更新日志写在 `archive/CHANGELOG.md`
- 不覆盖旧版文件
