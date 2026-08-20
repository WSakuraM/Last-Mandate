# 双电脑交叉开发（公司 ↔ 家里）

适用于：两台电脑来回改同一仓库，另一台用另一个 Agent 继续干。

## 原则

1. **Git 是唯一真相**；不要靠 U 盘拷 `.godot` 缓存或未提交文件当同步。  
2. **开工先拉，收工双推**（GitHub + Gitee）。  
3. 尽量在同一台机子上把一段工作做完再切换，减少半成品冲突。  
4. 新 Agent 先读根目录 [`AGENTS.md`](../AGENTS.md)。

## 推荐远程策略

| 场景 | 建议 |
|---|---|
| 两边网络都正常 | `pull origin` → 开发 → `push origin` + `push gitee` |
| 公司访问 GitHub 不稳 | 以 **Gitee 为主同步**：`pull gitee` / `push gitee`，回家再补推 GitHub |
| 只 clone 了一个地址 | 把另一个 `git remote add` 上（见 AGENTS.md） |

## 标准一日流程

### A 电脑收工

```powershell
cd <仓库路径>
git status
git add -A
git commit -m "说明改动原因（写为什么）"
git push origin main
git push gitee main
```

确认网页上 commit 已出现，再关机/离开。

### B 电脑开工

```powershell
cd <仓库路径>
git fetch --all
git pull origin main
# 若 origin 失败：
git pull gitee main

git log -3 --oneline
```

打开 Cursor，让 Agent 读 `AGENTS.md`，说明「从上一台接续什么任务」。

## 冲突时

```powershell
git status
# 打开冲突文件，保留正确内容后：
git add -A
git commit -m "resolve: merge conflict from cross-machine sync"
git push origin main
git push gitee main
```

不要 `push --force` 到 `main`，除非你非常清楚在丢谁的提交。

## 每日 16:00 备份

- 是 **Windows 计划任务**，绑定「注册过任务的那台电脑」。  
- **公司与家里需要各自注册一次**（若两边都想自动备份）：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\register_daily_backup_task.ps1
```

- 若某台电脑 16:00 关机，则该台不会备份；靠你收工时的手动双推更重要。

## 检查清单（切换电脑前）

- [ ] 本地无未提交改动，或已 commit  
- [ ] `origin` 与 `gitee` 都已 push 成功（或已知晓哪边失败）  
- [ ] 重要设计已写入 `archive/`（若本轮有定稿）  
- [ ] 另一台开工会先 `pull`
