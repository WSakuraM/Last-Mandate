# Git / GitHub 管控说明

## 已完成（本地）

- 仓库已 `git init`，默认分支 `main`
- 首次提交作者：**Sakura \<1124114910@qq.com\>**
- 已添加适合 Godot 的 `.gitignore`

## 本仓库建议的本地身份（只影响本项目）

在项目根目录执行（不要改全局配置，除非你自己想改）：

```powershell
git config user.name "Sakura"
git config user.email "1124114910@qq.com"
```

之后在本仓库的普通 `git commit` 都会用上述署名。

## 推到 GitHub（需你完成一次账号侧操作）

1. 打开 https://github.com/new  
2. Repository name 建议：`Last-Mandate`（或 `LastMandate`）  
3. 选 **Private** 或 Public（按你意愿）  
4. **不要**勾选 “Add a README”（本地已有内容）  
5. 创建后，把页面上的仓库地址发我，或自己执行：

```powershell
cd D:\Game\Last-Mandate
git remote add origin https://github.com/<你的用户名>/Last-Mandate.git
git push -u origin main
```

若使用 SSH：

```powershell
git remote add origin git@github.com:<你的用户名>/Last-Mandate.git
git push -u origin main
```

## 日常管控常用命令

```powershell
git status
git add -A
git commit -m "说明本次改动原因"
git push
git pull
```

## 可选：安装 GitHub CLI

安装后可用 `gh repo create` 一键建库并推送：

- https://cli.github.com/
- 或 `winget install GitHub.cli`

安装并 `gh auth login` 后告诉我，我可以帮你创建远程仓库并完成首次推送。
