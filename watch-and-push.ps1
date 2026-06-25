$git = "C:\Users\PC\AppData\Local\GitHubDesktop\app-3.5.12\resources\app\git\cmd\git.exe"
$repoPath = "C:\Users\PC\dinner-recommend"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.Filter = "*.html"
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

Write-Host "감시 시작: $repoPath" -ForegroundColor Cyan
Write-Host "파일이 수정되면 자동으로 GitHub에 푸시됩니다. 종료: Ctrl+C" -ForegroundColor Yellow

$lastPush = [datetime]::MinValue

while ($true) {
    $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 1000)

    if (-not $result.TimedOut) {
        # 1초 안에 연속 저장 시 중복 푸시 방지
        if (([datetime]::Now - $lastPush).TotalSeconds -lt 2) { continue }
        $lastPush = [datetime]::Now

        $changedFile = $result.Name
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        Write-Host ""
        Write-Host "[$timestamp] 변경 감지: $changedFile" -ForegroundColor Green

        Set-Location $repoPath
        & $git add .
        & $git commit -m "Update $changedFile ($timestamp)"
        & $git push

        Write-Host "푸시 완료!" -ForegroundColor Cyan
    }
}
