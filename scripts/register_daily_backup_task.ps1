# 注册每日 16:00 备份计划任务（当前用户，本机本地时区）

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ScriptPath = Join-Path $RepoRoot "scripts\daily_backup.ps1"
$TaskName = "LastMandate-DailyBackup-1600"

if (-not (Test-Path $ScriptPath)) {
    throw "Backup script not found: $ScriptPath"
}

$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($null -ne $existing) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Removed existing task: $TaskName"
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 16:00
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Last Mandate daily git backup to GitHub + Gitee at 16:00" | Out-Null

Write-Host "OK: Scheduled task created: $TaskName"
Write-Host "Runs daily at 16:00 (local timezone)"
Write-Host "Script: $ScriptPath"
Get-ScheduledTask -TaskName $TaskName | Format-List TaskName, State
Get-ScheduledTaskInfo -TaskName $TaskName | Format-List NextRunTime, LastRunTime, LastTaskResult
