# 문제 해결 (증상별)

> 증상으로 찾으세요. 설치 절차 자체는
> [SETUP-Windows.md](SETUP-Windows.md) / [SETUP-macOS.md](SETUP-macOS.md) 에 있습니다.

조교에게 문의할 때는 **오류 메시지 전체**를 복사해서 보내주세요.
"빌드가 안 돼요" 만으로는 원인을 좁힐 수 없습니다.

---

## A. 설치 단계

### A-1. "PlatformIO Core 설치 중" 이 30분 넘게 끝나지 않음
| 원인 | 확인 / 해결 |
|---|---|
| 디스크 부족 | 여유 2 GB 이상 확보 후 VS Code 재시작 |
| 백신 차단 (Win) | `.platformio` 폴더를 백신 예외에 추가 |
| 학교 네트워크 차단 | 휴대폰 핫스팟으로 바꿔 재시도 |
| 계정 경로 한글 (Win) | `PLATFORMIO_CORE_DIR` 설정 → [SETUP-Windows.md](SETUP-Windows.md) §1-3 |

그래도 안 되면 Core 폴더를 지우고 처음부터 받게 합니다.
- Windows: `C:\Users\<계정>\.platformio` 폴더 삭제
- macOS: `rm -rf ~/.platformio`

> 이 폴더는 언제든 다시 만들어지는 캐시입니다. 작성한 코드는 들어 있지 않습니다.

### A-2. 터미널에서 `pio: command not found`
PlatformIO Core 는 `PATH` 에 자동 등록되지 않습니다. 정상입니다.

- 평소에는 **VS Code 상태 표시줄 아이콘**을 쓰세요.
- 굳이 터미널에서 쓰려면 VS Code 안의 `PlatformIO Core CLI` 터미널을 여세요.
  (명령 팔레트 → `PlatformIO: New Terminal`)
- 저장소의 `doctor` 스크립트는 `pio` 위치를 알아서 찾으므로 그냥 실행하면 됩니다.

### A-4. `'&&' 토큰은 이 버전에서 올바른 문 구분 기호가 아닙니다` (Windows)

Windows PowerShell 5.1 은 `&&` 를 지원하지 않습니다. (PowerShell 7 부터 지원)
인터넷이나 macOS용 안내에서 복사한 명령을 붙여넣으면 이 오류가 납니다.

```
git add -A && git commit -m "메시지"
```

해결: **두 줄로 나눠서 한 번에 하나씩** 실행하세요.

```
git add -A
git commit -m "메시지"
```

앞 명령이 성공했을 때만 다음을 실행하고 싶다면:

```
git add -A; if ($?) { git commit -m "메시지" }
```

> 이 저장소 문서의 명령은 모두 한 줄씩 실행하도록 작성되어 있습니다.
> 여러 줄이 한 블록에 있으면 **한 줄씩** 복사해 실행하세요.

### A-3. `code` 명령이 없다고 나옴
- Windows: VS Code 재설치 시 **"PATH에 추가"** 를 체크. 또는 터미널을 새로 열기
- macOS: VS Code → `Cmd+Shift+P` → `Shell Command: Install 'code' command in PATH`

---

## B. 빌드(컴파일) 실패

### B-1. `avr-gcc: No such file or directory` / 툴체인을 못 찾음
거의 항상 **경로에 한글이 있어서** 입니다.

- Windows: [SETUP-Windows.md](SETUP-Windows.md) §1-2, §1-3
- macOS: 프로젝트를 `~/dev/mc2026` 로 옮기고 다시 시도

### B-2. `#include <Arduino.h>` 에 빨간 줄이 뜨는데 빌드는 성공함
IntelliSense 인덱스 문제입니다. **빌드가 성공했다면 코드는 정상입니다.**

명령 팔레트 → `PlatformIO: Rebuild IntelliSense Index` 실행 후 VS Code 재시작.

### B-3. 빌드는 되는데 이상하게 동작 / 예전 코드가 실행됨
빌드 캐시 문제. 상태 표시줄 **휴지통(Clean)** 아이콘을 누른 뒤 다시 빌드하세요.

### B-4. `region 'text' overflowed` / `data section exceeds`
Uno 의 용량을 초과했습니다. (플래시 32 KB, SRAM 2 KB)

- 문자열을 `Serial.println("...")` 대신 `Serial.println(F("..."))` 로 감싸면
  SRAM 대신 플래시에 저장되어 램을 크게 아낍니다.
- 큰 배열을 `const` + `PROGMEM` 으로 옮기세요.

---

## C. 업로드 실패

### C-1. `avrdude: stk500_recv(): programmer is not responding`
가장 흔한 실패입니다. 위에서부터 순서대로 확인하세요.

1. **시리얼 모니터가 켜져 있지 않은가?**
   모니터가 포트를 잡고 있으면 업로드가 실패합니다.
   모니터 터미널에서 `Ctrl + C` 로 끄고 다시 업로드하세요. → **1순위 원인**
2. **케이블이 충전 전용은 아닌가?** 다른 케이블로 교체
3. 보드의 리셋 버튼을 누른 직후 업로드
4. USB 허브를 빼고 본체에 직접 연결
5. 다른 프로그램(Arduino IDE, PuTTY, CoolTerm)이 포트를 쓰고 있지 않은지 확인
6. `platformio.ini` 의 `board` 가 `uno` 가 맞는지 확인

### C-2. `Could not find a board on the selected port` / 포트가 안 잡힘
```bash
# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
# macOS
bash scripts/doctor.sh
```
6번 항목에 포트가 안 보이면 **보드가 OS에 인식조차 안 된 상태**입니다.
드라이버 절을 보세요.
- Windows → [SETUP-Windows.md](SETUP-Windows.md) §4
- macOS → [SETUP-macOS.md](SETUP-macOS.md) §5

> **포트가 여러 개 보이는 경우**: 블루투스가 켜져 있으면 보드가 없어도
> `COM3`, `COM4` (Windows) 나 `/dev/cu.Bluetooth-Incoming-Port` (macOS) 같은
> **가상 포트**가 목록에 나옵니다. 이건 보드가 아닙니다.
> 구분하는 가장 쉬운 방법은 **보드를 뽑고 한 번, 꽂고 한 번** 실행해서
> 새로 생긴 포트를 찾는 것입니다.
> 드물게 PlatformIO 자동 인식이 블루투스 포트를 잘못 고르기도 하는데,
> 그럴 때만 `platformio.ini` 에 `upload_port` 를 직접 지정하세요.

### C-3. (macOS) 업로드가 아무 메시지 없이 멈춤
`/dev/tty.*` 포트를 지정했을 가능성이 큽니다. `/dev/cu.*` 로 바꾸세요.
자세한 내용은 [SETUP-macOS.md](SETUP-macOS.md) §4.

### C-4. (Windows) `access is denied` / `permission denied`
- 시리얼 모니터나 다른 터미널 프로그램을 모두 닫으세요.
- 백신이 `avrdude.exe` 를 막고 있을 수 있습니다. 예외 등록.

---

## D. 시리얼 모니터

### D-1. 글자가 `?????` 나 `??????` 로 깨져서 나옴
**보드레이트 불일치**입니다. 두 숫자가 같아야 합니다.

| 위치 | 값 |
|---|---|
| `platformio.ini` 의 `monitor_speed` | 9600 |
| 코드의 `Serial.begin(...)` | 9600 |

이 저장소는 둘 다 `9600` 으로 맞춰 두었습니다. 한쪽만 고치면 깨집니다.

### D-2. 아무것도 안 나옴
1. **업로드한 코드에 출력 기능이 있는지 먼저 확인.**
   기본 `src/main.cpp` 는 빈 뼈대라 아무것도 출력하지 않습니다. 정상입니다.
2. 업로드가 실제로 성공했는지 확인 (터미널에 `SUCCESS`)
3. 코드에 `Serial.begin()` 이 있는지 확인
4. 모니터를 껐다 켜거나, 보드의 리셋 버튼을 누르기

> 동작을 눈으로 확인하고 싶다면 `examples/00_env_check.cpp` 를
> `src/main.cpp` 에 덮어쓰고 업로드하세요. LED 점멸과 시리얼 출력이 모두 나옵니다.

### D-3. 모니터를 끄는 법
모니터 터미널을 클릭하고 `Ctrl + C`. (macOS 도 `Cmd` 가 아니라 `Ctrl` 입니다)

### D-4. `could not open port` / `Resource busy`
모니터가 이미 다른 탭에서 열려 있습니다.
VS Code 아래쪽 터미널 목록에서 기존 모니터 탭을 찾아 `Ctrl + C` 로 종료하세요.

---

## E. Git / 협업

### E-1. clone 했는데 파일 전체가 수정됨으로 표시됨
줄바꿈(CRLF/LF) 문제입니다. 이 저장소의 `.gitattributes` 가 막아주지만,
이미 꼬였다면:
```bash
git rm --cached -r .
git reset --hard
```

### E-2. `.vscode` 나 `.pio` 가 커밋되려고 함
`.pio/` 와 자동 생성 파일들은 `.gitignore` 에 있습니다.
그래도 올라오려 한다면 이미 추적 중인 것이니:
```bash
git rm -r --cached .pio
git commit -m "chore: stop tracking build output"
```

### E-3. `platformio.ini` 에 내 COM 포트를 적었더니 다른 사람이 안 됨
`upload_port` / `monitor_port` 는 **PC마다 다릅니다. 커밋하지 마세요.**
해당 줄을 다시 주석 처리하고 커밋하세요.

---

## F. 그래도 안 될 때 — 조교에게 보낼 정보

아래를 **전부** 복사해서 보내주세요.

1. OS 와 버전 (예: Windows 11 23H2 / macOS 14.5 Apple Silicon)
2. `doctor` 스크립트 실행 결과 **전체**
3. 실패한 명령의 오류 메시지 **전체** (앞 3줄만 말고 끝까지)
4. 프로젝트 폴더의 전체 경로
5. 보드 종류 (정품 / 호환)
