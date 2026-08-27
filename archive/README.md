# 设计留痕 Archive

本目录存放**可追溯、可迭代**的设计与计划资产。日常可改写的工作稿仍在 [`docs/`](../docs/)。

## 版本规则

见 [`README.md`](README.md)（SemVer）。冻结后：

1. 新版本**新增文件**，不覆盖旧版 `{品类}_{MAJOR.MINOR.PATCH}.md`  
2. 更新 [`index.md`](index.md) 当前指针  
3. 在 [`CHANGELOG.md`](CHANGELOG.md) 追加条目  
4. 不可逆决策写 `decisions/ADR-*.md`

Agent 规则见 [`.cursor/rules/design-traceability.mdc`](../.cursor/rules/design-traceability.mdc)。

## 每日备份

**已取消** Windows 计划任务。请靠收工时双推 GitHub + Gitee；可选 `scripts/daily_backup.ps1`。
