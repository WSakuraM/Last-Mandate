# ADR-0002 · 每日 16:00 本机双远程备份

- 状态：Accepted
- 日期：2026-08-20
- 决策者：Sakura

## 背景

个人开发易长时间未提交，本地资产有丢失风险；需同时备份 GitHub 与 Gitee。

## 决策

使用 **Windows 计划任务**（本机本地时区 16:00）运行 `scripts/daily_backup.ps1`：检测工作区改动 → 自动 commit（作者 Sakura）→ `git push origin` 与 `git push gitee`。

选用本机任务而非云端 Agent：云端无法可靠覆盖「仅在本机工作区」的防丢失场景，本机任务直接操作当前仓库最稳妥。

## 后果

- 无改动时脚本静默成功，不产生空提交
- 任一远程失败写入 `archive/daily/` 日志，分别尝试两端推送
