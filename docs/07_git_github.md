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
| `gitee` | Gitee | https://gitee.com/ChenZheng521/last-mandate.git |

> 若你在 Gitee 将「个人空间地址」改为 `Sakura`（或其它），仓库 URL 会变，需执行：  
> `git remote set-url gitee https://gitee.com/<新空间名>/last-mandate.git`

日后说「提交代码」= **本地 commit + 同时 push 到 origin 与 gitee**。

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
