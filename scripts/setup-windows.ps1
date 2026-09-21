<#
    마이크로컨트롤러응용 2026 - Windows 개발환경 설치 스크립트

    실행 방법 (PowerShell 에서):
        cd <이 저장소 폴더>
        powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1

    이 스크립트가 하는 일:
        1. 디스크 여유 공간 확인
        2. winget 으로 Git / VS Code 설치 (이미 있으면 건너뜀)
        3. VS Code 에 PlatformIO IDE 확장 설치
        4. 한글 사용자 계정일 경우 PLATFORMIO_CORE_DIR 우회 설정
        5. CH340 드라이버 필요 여부 안내

    ※ 이 스크립트는 아무것도 삭제하지 않습니다.
#>

$ErrorActionPreference = 'Stop'

# 콘솔 한글 깨짐 방지 (영문 Windows / cp437 환경 대응)
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

function Write-Step($msg) { Write-Host "`n[단계] $msg" -ForegroundColor Cyan }
function Write-Ok  ($msg) { Write-Host "  OK   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  주의 $msg" -ForegroundColor Yellow }
function Write-Err ($msg) { Write-Host "  실패 $msg" -ForegroundColor Red }

Write-Host "=======================================================" -ForegroundColor White
Write-Host " 마이크로컨트롤러응용 2026 - Windows 환경 설치" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor White

# --- 1. 디스크 여유 공간 -------------------------------------------------
Write-Step "디스크 여유 공간 확인"
$sysDrive = $env:SystemDrive
$free = (Get-PSDrive -Name $sysDrive.TrimEnd(':')).Free / 1GB
Write-Host ("  {0} 드라이브 여유: {1:N1} GB" -f $sysDrive, $free)
if ($free -lt 2) {
    Write-Err "여유 공간이 2GB 미만입니다. PlatformIO 툴체인(약 400MB~1GB) 설치가 실패할 수 있습니다."
    Write-Warn "불필요한 파일을 정리한 뒤 다시 실행하세요."
    exit 1
} elseif ($free -lt 5) {
    Write-Warn "여유 공간이 빠듯합니다. 설치 중 실패하면 공간을 확보하고 재시도하세요."
} else {
    Write-Ok "충분합니다."
}

# --- 2. winget 확인 ------------------------------------------------------
Write-Step "winget(앱 설치 도구) 확인"
$hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
if ($hasWinget) {
    Write-Ok "winget 사용 가능"
} else {
    Write-Warn "winget 이 없습니다. Microsoft Store 에서 '앱 설치 관리자(App Installer)'를 설치하거나,"
    Write-Warn "docs\SETUP-Windows.md 의 '수동 설치' 절차를 따르세요."
}

function Install-IfMissing($cmdName, $wingetId, $label) {
    if (Get-Command $cmdName -ErrorAction SilentlyContinue) {
        Write-Ok "$label 이(가) 이미 설치되어 있습니다."
        return
    }
    if (-not $hasWinget) { Write-Warn "$label 을(를) 수동으로 설치하세요."; return }
    Write-Host "  $label 설치 중... (몇 분 걸릴 수 있습니다)"
    winget install --id $wingetId -e --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) { Write-Ok "$label 설치 완료" } else { Write-Err "$label 설치 실패 (코드 $LASTEXITCODE)" }
}

# --- 3. Git / VS Code ----------------------------------------------------
Write-Step "Git 설치 확인"
Install-IfMissing 'git' 'Git.Git' 'Git'

Write-Step "Visual Studio Code 설치 확인"
Install-IfMissing 'code' 'Microsoft.VisualStudioCode' 'VS Code'

# PATH 갱신 (방금 설치했다면 현재 세션에 반영)
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path','User')

# --- 4. 한글 계정 우회 ---------------------------------------------------
Write-Step "사용자 계정 경로 점검"
$profilePath = $env:USERPROFILE
$isAscii = $profilePath -match '^[\x20-\x7E]+$'
if ($isAscii) {
    Write-Ok "계정 경로에 한글/특수문자가 없습니다. ($profilePath)"
} else {
    Write-Warn "계정 경로에 한글이 포함되어 있습니다: $profilePath"
    Write-Warn "이 상태로는 AVR 컴파일러가 경로를 찾지 못해 빌드가 실패합니다."
    $coreDir = Join-Path $env:SystemDrive 'pio-core'
    New-Item -ItemType Directory -Force -Path $coreDir | Out-Null
    [Environment]::SetEnvironmentVariable('PLATFORMIO_CORE_DIR', $coreDir, 'User')
    $env:PLATFORMIO_CORE_DIR = $coreDir
    Write-Ok "PLATFORMIO_CORE_DIR 을 $coreDir 로 설정했습니다."
    Write-Warn "설정을 적용하려면 VS Code 를 완전히 종료 후 다시 실행하세요."
}

# --- 5. PlatformIO 확장 --------------------------------------------------
Write-Step "VS Code 확장 설치 (PlatformIO IDE)"
if (Get-Command code -ErrorAction SilentlyContinue) {
    $installed = (code --list-extensions) -join "`n"
    if ($installed -match 'platformio.platformio-ide') {
        Write-Ok "PlatformIO IDE 가 이미 설치되어 있습니다."
    } else {
        code --install-extension platformio.platformio-ide --force
        Write-Ok "PlatformIO IDE 설치 요청 완료"
    }
    if ($installed -match 'vsciot-vscode.vscode-arduino') {
        Write-Warn "구형 'Arduino' 확장이 설치되어 있습니다. PlatformIO 와 충돌하므로 제거를 권장합니다:"
        Write-Warn "  code --uninstall-extension vsciot-vscode.vscode-arduino"
    }
} else {
    Write-Err "code 명령을 찾을 수 없습니다. VS Code 설치 후 터미널을 새로 열고 다시 실행하세요."
}

# --- 6. USB 드라이버 안내 ------------------------------------------------
Write-Step "USB-시리얼 드라이버 안내"
Write-Host "  정품 Arduino Uno R3  : 드라이버 불필요 (ATmega16U2 내장)"
Write-Host "  중국산 호환 보드      : CH340 드라이버 필요할 수 있음"
Write-Host "    -> 보드를 꽂고 장치 관리자에서 '알 수 없는 장치'로 뜨면 설치"
Write-Host "    -> 설치 링크와 절차: docs\SETUP-Windows.md 의 '4. 드라이버' 참고"

Write-Host "`n=======================================================" -ForegroundColor White
Write-Host " 설치 스크립트 종료" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor White
Write-Host "다음 단계:"
Write-Host "  1) VS Code 를 완전히 종료했다가 이 폴더를 다시 엽니다."
Write-Host "  2) 우측 하단 'PlatformIO Core 설치 중' 알림이 끝날 때까지 기다립니다 (최초 5~10분)."
Write-Host "  3) 아래 점검 스크립트를 실행합니다:"
Write-Host "       powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1" -ForegroundColor Cyan
