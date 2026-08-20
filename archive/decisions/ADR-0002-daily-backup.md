# ADR-0002 · 每日 16:00 本机双远程备份

- 状态：**Superseded（已废止）** — 2026-08-20 用户取消计划任务 `LastMandate-DailyBackup-1600`
- 原接受日期：2026-08-20
- 决策者：Sakura

## 原决策（历史）

曾使用 Windows 计划任务每天 16:00 运行 `scripts/daily_backup.ps1` 自动 commit 并推送 GitHub + Gitee。

## 废止说明

用户明确取消该定时任务，不再自动每日备份。备份改为：**手动提交 / 说「提交代码」时双远程推送**。  
脚本文件可保留在 `scripts/` 备查，**默认不再注册计划任务**。
