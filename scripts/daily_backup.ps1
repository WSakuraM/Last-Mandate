# Last-Mandate daily backup
# Runs at 16:00 local time via Windows Task Scheduler.
# Commits dirty worktree (if any) and pushes to GitHub + Gitee.

$ErrorActionPreference = "Continue"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

$LogDir = Join-Path $RepoRoot "archive\daily"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogFile = Join-Path $LogDir "backup_$Stamp.log"

function Write-Log([string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

Write-Log "=== daily backup start ==="
Write-Log "repo: $RepoRoot"

try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Log "ERROR: not a git repository"
        exit 1
    }

    git add -A
    $status = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($status)) {
        Write-Log "No local changes. Still ensuring remotes are up to date."
    }
    else {
        $date = Get-Date -Format "yyyy-MM-dd"
        $msg = "chore(backup): daily snapshot $date"
        Write-Log "Committing changes..."
        git -c user.name="Sakura" -c user.email="1124114910@qq.com" commit -m $msg
        if ($LASTEXITCODE -ne 0) {
            Write-Log "ERROR: commit failed (exit $LASTEXITCODE)"
        }
        else {
            Write-Log "Commit OK: $msg"
        }
    }

    $originOk = $false
    $giteeOk = $false

    Write-Log "Pushing origin (GitHub)..."
    git push origin main 2>&1 | ForEach-Object { Write-Log "origin: $_" }
    if ($LASTEXITCODE -eq 0) { $originOk = $true; Write-Log "origin push OK" }
    else { Write-Log "ERROR: origin push failed (exit $LASTEXITCODE)" }

    Write-Log "Pushing gitee..."
    git push gitee main 2>&1 | ForEach-Object { Write-Log "gitee: $_" }
    if ($LASTEXITCODE -eq 0) { $giteeOk = $true; Write-Log "gitee push OK" }
    else { Write-Log "ERROR: gitee push failed (exit $LASTEXITCODE)" }

    # If log itself is new after commit, leave it for next run (avoid loop complexity).
    Write-Log "=== daily backup end (origin=$originOk gitee=$giteeOk) ==="

    if (-not $originOk -or -not $giteeOk) { exit 2 }
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
