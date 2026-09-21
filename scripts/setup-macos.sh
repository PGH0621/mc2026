#!/usr/bin/env bash
#
# 마이크로컨트롤러응용 2026 - macOS 개발환경 설치 스크립트
#
# 실행 방법 (터미널에서):
#     cd <이 저장소 폴더>
#     bash scripts/setup-macos.sh
#
# 하는 일:
#     1. 디스크 여유 공간 확인
#     2. Homebrew 확인 (없으면 설치 명령 안내)
#     3. Git / VS Code 설치 (이미 있으면 건너뜀)
#     4. VS Code 에 PlatformIO IDE 확장 설치
#     5. USB-시리얼 드라이버 및 포트 이름 안내
#
# ※ 이 스크립트는 아무것도 삭제하지 않습니다.

set -u

C_CYAN='\033[36m'; C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'; C_OFF='\033[0m'
step() { printf "\n${C_CYAN}[단계] %s${C_OFF}\n" "$1"; }
ok()   { printf "  ${C_GREEN}OK  ${C_OFF} %s\n" "$1"; }
warn() { printf "  ${C_YELLOW}주의${C_OFF} %s\n" "$1"; }
err()  { printf "  ${C_RED}실패${C_OFF} %s\n" "$1"; }

echo "======================================================="
echo " 마이크로컨트롤러응용 2026 - macOS 환경 설치"
echo "======================================================="

# --- 0. 아키텍처 확인 ----------------------------------------------------
ARCH="$(uname -m)"
step "Mac 종류 확인"
if [ "$ARCH" = "arm64" ]; then
  ok "Apple Silicon (M1/M2/M3/M4) 입니다."
else
  ok "Intel Mac 입니다."
fi
echo "  macOS 버전: $(sw_vers -productVersion 2>/dev/null || echo '확인 불가')"

# --- 1. 디스크 여유 공간 -------------------------------------------------
step "디스크 여유 공간 확인"
FREE_GB=$(df -g / 2>/dev/null | awk 'NR==2 {print $4}')
if [ -n "${FREE_GB:-}" ]; then
  echo "  / 여유: ${FREE_GB} GB"
  if [ "$FREE_GB" -lt 2 ]; then
    err "여유 공간이 2GB 미만입니다. 툴체인(약 400MB~1GB) 설치가 실패할 수 있습니다."
    exit 1
  elif [ "$FREE_GB" -lt 5 ]; then
    warn "여유 공간이 빠듯합니다."
  else
    ok "충분합니다."
  fi
fi

# --- 2. Homebrew ---------------------------------------------------------
step "Homebrew 확인"
if command -v brew >/dev/null 2>&1; then
  ok "Homebrew 사용 가능 ($(brew --version | head -1))"
  HAS_BREW=1
else
  HAS_BREW=0
  warn "Homebrew 가 없습니다. 아래 명령을 직접 복사해서 실행한 뒤, 이 스크립트를 다시 실행하세요."
  echo ""
  echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo ""
  warn "설치 후 터미널이 안내하는 'eval \$(...shellenv)' 줄도 그대로 실행해야 brew 명령이 잡힙니다."
fi

# --- 3. Git / VS Code ----------------------------------------------------
step "Git 확인"
if command -v git >/dev/null 2>&1; then
  ok "Git 이미 설치됨 ($(git --version))"
else
  if [ "$HAS_BREW" = "1" ]; then
    echo "  Git 설치 중..."
    brew install git && ok "Git 설치 완료" || err "Git 설치 실패"
  else
    warn "Xcode Command Line Tools 를 설치하면 git 이 함께 들어옵니다: xcode-select --install"
  fi
fi

step "Visual Studio Code 확인"
if [ -d "/Applications/Visual Studio Code.app" ]; then
  ok "VS Code 이미 설치됨"
else
  if [ "$HAS_BREW" = "1" ]; then
    echo "  VS Code 설치 중..."
    brew install --cask visual-studio-code && ok "VS Code 설치 완료" || err "VS Code 설치 실패"
  else
    warn "https://code.visualstudio.com 에서 직접 내려받아 응용 프로그램 폴더로 옮기세요."
  fi
fi

# --- 4. code 명령 등록 ---------------------------------------------------
step "'code' 터미널 명령 확인"
if command -v code >/dev/null 2>&1; then
  ok "code 명령 사용 가능"
else
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  if [ -d "$CODE_BIN" ]; then
    warn "code 명령이 PATH 에 없습니다. VS Code 를 열고"
    warn "  Cmd+Shift+P -> 'Shell Command: Install code command in PATH' 를 실행하세요."
    export PATH="$PATH:$CODE_BIN"
    ok "이번 실행에 한해 임시로 PATH 에 추가했습니다."
  else
    err "VS Code 를 찾을 수 없습니다."
  fi
fi

# --- 5. PlatformIO 확장 --------------------------------------------------
step "VS Code 확장 설치 (PlatformIO IDE)"
if command -v code >/dev/null 2>&1; then
  INSTALLED="$(code --list-extensions 2>/dev/null || true)"
  if echo "$INSTALLED" | grep -qi 'platformio.platformio-ide'; then
    ok "PlatformIO IDE 가 이미 설치되어 있습니다."
  else
    code --install-extension platformio.platformio-ide --force && ok "PlatformIO IDE 설치 요청 완료"
  fi
  if echo "$INSTALLED" | grep -qi 'vsciot-vscode.vscode-arduino'; then
    warn "구형 'Arduino' 확장이 설치되어 있습니다. PlatformIO 와 충돌하므로 제거를 권장합니다:"
    warn "  code --uninstall-extension vsciot-vscode.vscode-arduino"
  fi
else
  err "code 명령을 찾을 수 없어 확장 설치를 건너뜁니다."
fi

# --- 6. USB 드라이버 / 포트 안내 -----------------------------------------
step "USB-시리얼 포트 안내"
echo "  정품 Arduino Uno R3 : 드라이버 불필요. 포트는 /dev/cu.usbmodem* 로 보입니다."
echo "  중국산 호환 보드     : CH340 칩. macOS 11 이상은 내장 드라이버로 대부분 인식되며"
echo "                         /dev/cu.usbserial* 또는 /dev/cu.wchusbserial* 로 보입니다."
echo ""
echo "  ※ 반드시 tty. 가 아니라 cu. 로 시작하는 포트를 사용하세요."
echo "     (tty. 는 DCD 신호를 기다리며 멈춰버립니다)"
echo ""
echo "  현재 연결된 시리얼 장치:"
ls /dev/cu.* 2>/dev/null | sed 's/^/    /' || echo "    (없음 - 보드를 USB 로 연결한 뒤 다시 확인)"

echo ""
echo "======================================================="
echo " 설치 스크립트 종료"
echo "======================================================="
echo "다음 단계:"
echo "  1) VS Code 를 완전히 종료했다가 이 폴더를 다시 엽니다."
echo "  2) 우측 하단 'PlatformIO Core 설치 중' 알림이 끝날 때까지 기다립니다 (최초 5~10분)."
echo "  3) 아래 점검 스크립트를 실행합니다:"
printf "       ${C_CYAN}bash scripts/doctor.sh${C_OFF}\n"
