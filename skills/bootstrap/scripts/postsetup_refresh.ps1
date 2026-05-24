# oh-my-wiki · L2 vault 리프레시 + 그래프뷰 trigger
# Usage: .\postsetup_refresh.ps1 -VaultName "_PoC_빈vault" -KeyNote "_meta/일관성카드.md"
#
# 주의: 옵시디언 CLI는 vault= 옵션이 일부 명령(open 등)과 파서 충돌함.
# 따라서 활성 vault 기준으로만 작동. 대상 vault가 활성 아니면 안내 후 종료.

param(
    [Parameter(Mandatory=$true)][string]$VaultName,
    [string]$KeyNote = "_meta/일관성카드.md"
)

$ErrorActionPreference = "Stop"

# Obsidian.com 리다이렉터 후보 — healthcheck.ps1과 동일 순서 유지
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
    Write-Output "FAIL: Obsidian.com 리다이렉터 못 찾음 (healthcheck.ps1 먼저 실행)"
    Write-Output "확인 자리: $($candidates -join ', ')"
    exit 1
}

Write-Output "[1/5] vault 등록 확인"
$vaults = & $obs vaults 2>&1 | Out-String
if ($vaults -notmatch [regex]::Escape($VaultName)) {
    Write-Output "WARN: vault '$VaultName' 미등록"
    Write-Output "해결: 옵시디언 GUI → Open folder as vault → 대상 폴더 선택"
    Write-Output "현재 등록된 vault:"
    Write-Output $vaults
    exit 2
}

Write-Output "[2/5] 활성 vault 확인"
$activeName = (& $obs vault info=name 2>&1 | Out-String).Trim()
if ($activeName -ne $VaultName) {
    Write-Output "WARN: 활성 vault는 '$activeName' — 대상은 '$VaultName'"
    Write-Output "해결: 옵시디언 GUI에서 좌측 하단 vault 스위처로 '$VaultName' 활성화 후 재실행"
    Write-Output "(옵시디언 CLI는 vault= 옵션과 open 명령이 충돌해 활성 vault 기준만 작동)"
    exit 3
}

Write-Output "[3/5] vault 리로드"
& $obs reload 2>&1

Write-Output "[4/5] 핵심 노트 열기 — $KeyNote"
$openResult = (& $obs open path=$KeyNote 2>&1 | Out-String).Trim()
if ($openResult -match "not found|File not found") {
    Write-Output "  · 첫 시도 실패 (file index sync 지연 추정), 1.5초 후 재시도"
    Start-Sleep -Milliseconds 1500
    & $obs reload 2>&1 | Out-Null
    & $obs open path=$KeyNote 2>&1
} else {
    Write-Output $openResult
}

Write-Output "[5/5] 그래프뷰 열기"
$graphResult = (& $obs command id=graph:open 2>&1 | Out-String).Trim()
if ($graphResult -match "not found|not enabled") {
    Write-Output "  · 첫 시도 실패 (graph plugin 로드 지연 추정), 1.5초 후 재시도"
    Start-Sleep -Milliseconds 1500
    & $obs command id=graph:open 2>&1
} else {
    Write-Output $graphResult
}

Write-Output "OK · oh-my-wiki 셋업 완료"
Write-Output "→ 옵시디언 GUI에서 일관성카드 + 그래프뷰 자동 열림 확인하세요"
exit 0
