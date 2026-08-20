# Git 管控说明（GitHub + Gitee）

## 身份（仅本仓库）

```powershell
cd D:\Game\Last-Mandate
git config user.name "Sakura"
git config user.email "1124114910@qq.com"
```

## 远程

| 远程名 | 平台 | 地址 |
|---|---|---|
| `origin` | GitHub | https://github.com/WSakuraM/Last-Mandate.git |
| `gitee` | Gitee | https://gitee.com/WSakuraM/last-mandate.git |

> 个人空间地址已与 GitHub 对齐为 `WSakuraM`。若再次变更，执行：  
> `git remote set-url gitee https://gitee.com/<新空间名>/last-mandate.git`

日后说「提交代码」= **本地 commit + 同时 push 到 origin 与 gitee**。

## 每日备份（本机 16:00）

Windows 计划任务：`LastMandate-DailyBackup-1600`  
脚本：[`scripts/daily_backup.ps1`](../scripts/daily_backup.ps1)

```powershell
cd D:\Game\Last-Mandate
powershell -ExecutionPolicy Bypass -File .\scripts\register_daily_backup_task.ps1
```

有改动则自动 commit（作者 Sakura）并推送两边；无改动不产生空提交。日志在 `archive/daily/`（默认不入库）。

## 日常命令

```powershell
git status
git add -A
git commit -m "说明本次改动原因"
git push origin main
git push gitee main
```

拉取以 GitHub 为主即可：

```powershell
git pull origin main
```

## 首次接入 Gitee

1. 打开 https://gitee.com/projects/new  
2. 仓库名：`Last-Mandate`  
3. **不要**勾选「使用 Readme 文件初始化仓库」  
4. 可见性自选（公开/私有）  
5. 创建后执行（把 URL 换成你的）：

```powershell
cd D:\Game\Last-Mandate
git remote add gitee https://gitee.com/<你的用户名>/Last-Mandate.git
git push -u gitee main
```

推送时按提示登录 Gitee（账号密码或私人令牌）。

## 可选：一条命令推两边

```powershell
git remote add all https://github.com/WSakuraM/Last-Mandate.git
git remote set-url --add --push all https://github.com/WSakuraM/Last-Mandate.git
git remote set-url --add --push all https://gitee.com/<你的用户名>/Last-Mandate.git
git push all main
```

仍建议保留独立的 `origin` / `gitee`，便于单独排查。
