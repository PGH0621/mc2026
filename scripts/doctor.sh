#!/usr/bin/env bash
#
# 마이크로컨트롤러응용 2026 - macOS 환경 점검 스크립트
#
# 실행:  bash scripts/doctor.sh
#
# "빌드까지 실제로 되는지"를 확인합니다.
# 보드를 연결하지 않아도 5번까지는 통과해야 정상입니다.

set -u
C_CYAN='\033[36m'; C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'; C_OFF='\033[0m'
FAIL=0
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

section() { printf "\n${C_CYAN}--- %s ---${C_OFF}\n" "$1"; }
fail()    { printf "  ${C_RED}실패: %s${C_OFF}\n" "$1"; FAIL=$((FAIL+1)); }

# pio 실행 파일 찾기
find_pio() {
  if command -v pio >/dev/null 2>&1; then command -v pio; return; fi
  local core="${PLATFORMIO_CORE_DIR:-$HOME/.platformio}"
  if [ -x "$core/penv/bin/pio" ]; then echo "$core/penv/bin/pio"; return; fi
  echo ""
}

echo "======================================================="
echo " 환경 점검 (macOS)"
echo "======================================================="

PIO="$(find_pio)"
if [ -z "$PIO" ]; then
  printf "${C_RED}PlatformIO Core 를 찾을 수 없습니다.${C_OFF}\n"
  echo "VS Code 에서 이 폴더를 열고, 우측 하단 설치 알림이 끝난 뒤 다시 실행하세요."
  exit 1
fi
echo "PlatformIO Core 경로: $PIO"

section "1. PlatformIO 버전"
"$PIO" --version || fail "pio 실행 불가"

section "2. 시스템 정보"
"$PIO" system info || fail "system info 실패"

section "3. 프로젝트 설정 확인"
if [ ! -f "$ROOT/platformio.ini" ]; then
  fail "platformio.ini 없음"
else
  grep -E '^(platform|board|framework)[[:space:]]*=' "$ROOT/platformio.ini" | sed 's/^/  /'
fi

section "4. 빌드 테스트 (최초 실행은 툴체인 내려받느라 5~10분)"
if (cd "$ROOT" && "$PIO" run -e uno); then
  printf "  ${C_GREEN}빌드 성공${C_OFF}\n"
else
  fail "빌드 실패"
fi

section "5. 설치된 패키지 버전 (모든 학생이 동일해야 함)"
(cd "$ROOT" && "$PIO" pkg list -e uno) || fail "pkg list 실패"

section "6. 연결된 보드 확인"
"$PIO" device list
printf "  ${C_YELLOW}위 목록에 /dev/cu.* 가 안 보이면: USB 케이블이 '충전 전용'인지 확인하세요.${C_OFF}\n"

echo ""
echo "======================================================="
if [ "$FAIL" -eq 0 ]; then
  printf "${C_GREEN} 점검 통과 - 수업 준비 완료${C_OFF}\n"
else
  printf "${C_RED} 실패한 항목 %s 개 - docs/TROUBLESHOOTING.md 를 확인하세요${C_OFF}\n" "$FAIL"
fi
echo "======================================================="
exit "$FAIL"
