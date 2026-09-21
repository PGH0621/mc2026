<#
    마이크로컨트롤러응용 2026 - Windows 환경 점검 스크립트

    실행:  powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1

    이 스크립트는 "빌드까지 실제로 되는지"를 확인합니다.
    보드를 연결하지 않아도 5번까지는 통과해야 정상입니다.
#>

$ErrorActionPreference = 'Continue'

# 콘솔 한글 깨짐 방지 (영문 Windows / cp437 환경 대응)
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
$fail = 0

function Check($name, [scriptblock]$body) {
    Write-Host "`n--- $name ---" -ForegroundColor Cyan
    try { & $body } catch { Write-Host "  실패: $_" -ForegroundColor Red; $script:fail++ }
}

# pio 실행 파일 찾기 (PATH -> PlatformIO Core 디렉터리 순)
function Get-PioPath {
    $c = Get-Command pio -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $core = if ($env:PLATFORMIO_CORE_DIR) { $env:PLATFORMIO_CORE_DIR } else { Join-Path $env:USERPROFILE '.platformio' }
    $p = Join-Path $core 'penv\Scripts\pio.exe'
    if (Test-Path $p) { return $p }
    return $null
}

Write-Host "=======================================================" -ForegroundColor White
Write-Host " 환경 점검 (Windows)" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor White

$pio = Get-PioPath
if (-not $pio) {
    Write-Host "`nPlatformIO Core 를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "VS Code 에서 이 폴더를 열고, 우측 하단 설치 알림이 끝난 뒤 다시 실행하세요."
    exit 1
}
Write-Host "PlatformIO Core 경로: $pio"

Check "1. PlatformIO 버전" { & $pio --version }
Check "2. 시스템 정보"      { & $pio system info }

Check "3. 프로젝트 설정 확인" {
    $ini = Join-Path (Split-Path $PSScriptRoot -Parent) 'platformio.ini'
    if (-not (Test-Path $ini)) { throw "platformio.ini 를 찾을 수 없습니다. 저장소 루트에서 실행하세요." }
    Select-String -Path $ini -Pattern '^(platform|board|framework)\s*=' | ForEach-Object { "  " + $_.Line.Trim() }
}

Check "4. 빌드 테스트 (최초 실행은 툴체인 내려받느라 5~10분)" {
    Push-Location (Split-Path $PSScriptRoot -Parent)
    & $pio run -e uno
    $code = $LASTEXITCODE
    Pop-Location
    if ($code -ne 0) { throw "빌드 실패 (exit $code)" }
    Write-Host "  빌드 성공" -ForegroundColor Green
}

Check "5. 설치된 패키지 버전 (모든 학생이 동일해야 함)" {
    Push-Location (Split-Path $PSScriptRoot -Parent)
    & $pio pkg list -e uno
    Pop-Location
}

Check "6. 연결된 보드 확인" {
    & $pio device list
    Write-Host "  위 목록에 COMx 가 안 보이면: USB 케이블이 '충전 전용'인지, 드라이버가 필요한지 확인하세요." -ForegroundColor Yellow
}

Write-Host "`n=======================================================" -ForegroundColor White
if ($fail -eq 0) {
    Write-Host " 점검 통과 - 수업 준비 완료" -ForegroundColor Green
} else {
    Write-Host " 실패한 항목 $fail 개 - docs\TROUBLESHOOTING.md 를 확인하세요" -ForegroundColor Red
}
Write-Host "=======================================================" -ForegroundColor White
exit $fail
