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
$script:PioSearched = @()

function Get-PioPath {
    $c = Get-Command pio -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }

    $roots = @()
    # 1) 현재 프로세스의 환경변수
    if ($env:PLATFORMIO_CORE_DIR) { $roots += $env:PLATFORMIO_CORE_DIR }
    # 2) 등록만 되고 현재 프로세스에는 안 보이는 경우
    foreach ($scope in 'User', 'Machine') {
        $v = [Environment]::GetEnvironmentVariable('PLATFORMIO_CORE_DIR', $scope)
        if ($v) { $roots += $v }
    }
    # 3) 기본 위치
    $roots += (Join-Path $env:USERPROFILE '.platformio')
    # 4) 계정 이름에 한글 등 비ASCII 문자가 있으면 PlatformIO 가 스스로
    #    드라이브 루트로 옮겨 설치한다. (예: C:\Users\박근호 -> C:\.platformio)
    $roots += (Join-Path $env:SystemDrive '\.platformio')
    # 5) 예전 버전 설치 스크립트가 쓰던 위치
    $roots += (Join-Path $env:SystemDrive 'pio-core')

    # 실행 파일 이름은 버전에 따라 pio.exe 또는 platformio.exe 다.
    $exeNames = @('pio.exe', 'platformio.exe')

    $script:PioSearched = @()
    foreach ($r in ($roots | Where-Object { $_ } | Select-Object -Unique)) {
        foreach ($exe in $exeNames) {
            $p = Join-Path $r (Join-Path 'penv\Scripts' $exe)
            $script:PioSearched += $p
            if (Test-Path $p) { return $p }
        }
    }
    return $null
}

Write-Host "=======================================================" -ForegroundColor White
Write-Host " 환경 점검 (Windows)" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor White

$pio = Get-PioPath
if (-not $pio) {
    Write-Host "`nPlatformIO Core 를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "찾아본 위치:" -ForegroundColor Yellow
    foreach ($p in $script:PioSearched) { Write-Host "  $p" }
    Write-Host ""
    Write-Host "대부분 아직 설치가 안 끝난 경우입니다. 순서대로 확인하세요:" -ForegroundColor Yellow
    Write-Host "  1) VS Code 로 이 폴더를 '폴더째' 열었는가"
    Write-Host "  2) 우측 하단 'PlatformIO Core 설치 중' 알림이 끝났는가 (최초 5~10분)"
    Write-Host "  3) 이 PowerShell 창을 새로 열고 다시 실행했는가"
    Write-Host ""
    Write-Host "VS Code 에서는 빌드가 되는데 여기서만 못 찾는다면," -ForegroundColor Yellow
    Write-Host "PlatformIO 터미널(Ctrl+Shift+P > PlatformIO: New Terminal)에서" -ForegroundColor Yellow
    Write-Host "  pio system info" -ForegroundColor Cyan
    Write-Host "를 실행해 'PlatformIO Core Directory' 를 확인한 뒤, 그 값으로 다시 실행하세요:" -ForegroundColor Yellow
    Write-Host "  `$env:PLATFORMIO_CORE_DIR='<그 경로>'; .\scripts\doctor.ps1" -ForegroundColor Cyan
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
