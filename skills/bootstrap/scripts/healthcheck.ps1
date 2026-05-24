# oh-my-wiki · L2 헬스체크
# Obsidian.com 리다이렉터 존재 + CLI 토글 ON 확인
# Exit codes: 0=OK, 1=binary missing, 2=CLI toggle OFF, 3=other

$ErrorActionPreference = "Stop"

$candidates = @(
    "C:\Program Files\Obsidian\Obsidian.com",
    "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.com",
    "$env:LOCALAPPDATA\Obsidian\Obsidian.com"
)

$obs = $null
foreach ($c in $candidates) {
    if (Test-Path $c) { $obs = $c; break }
}

if (-not $obs) {
    Write-Output "FAIL: Obsidian.com 리다이렉터 못 찾음"
    Write-Output "확인 자리: $($candidates -join ', ')"
    Write-Output "해결: 옵시디언 인스톨러 1.12.7+ 재설치 (Microsoft Store 버전 ✗)"
    exit 1
}

$result = & $obs version 2>&1 | Out-String

if ($result -match "not enabled") {
    Write-Output "FAIL: CLI 토글 OFF"
    Write-Output "해결: 옵시디언 앱 실행 → Settings → General → Advanced → 'Command line interface' ON"
    exit 2
}

if ($result -notmatch "1\.\d+\.\d+") {
    Write-Output "WARN: 버전 파싱 실패"
    Write-Output $result
    exit 3
}

Write-Output "OK: $($result.Trim())"
Write-Output "OBSIDIAN_BINARY=$obs"
exit 0
