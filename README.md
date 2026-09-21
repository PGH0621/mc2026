# 마이크로컨트롤러응용 (2026) — VS Code 개발환경

Arduino IDE 대신 **VS Code + PlatformIO** 로 실습합니다.
Windows 와 macOS 가 **완전히 동일한 컴파일러·코어 버전**을 쓰도록 구성되어 있습니다.

| 항목 | 내용 |
|---|---|
| 대상 보드 | Arduino Uno R3 (ATmega328P, 16 MHz) |
| 편집기 | Visual Studio Code |
| 빌드 시스템 | PlatformIO Core (VS Code 확장에 내장) |
| 툴체인 | avr-gcc 5.4.0 계열 (`platformio.ini` 에 버전 고정) |
| 지원 OS | Windows 10/11, macOS 12 이상 (Intel / Apple Silicon 모두) |

---

## 1. 빠른 시작 (약 15분)

### 준비물
- 인터넷 연결 (최초 1회 약 400 MB 다운로드)
- **여유 디스크 공간 2 GB 이상**
- Arduino Uno 보드 + **데이터 전송용** USB-B 케이블
  - 충전 전용 케이블은 인식되지 않습니다. 이게 실습 중 1번 문제입니다.

### 1단계 — 저장소 내려받기

```bash
git clone <저장소 주소> mc2026
cd mc2026
```

> **Windows 주의**: 폴더 경로에 한글·공백이 없는 곳에 두세요. `C:\dev\mc2026` 권장.
> 바탕화면(`Desktop`)은 OneDrive 동기화와 충돌하는 경우가 있습니다.

### 2단계 — 설치 스크립트 실행

OS에 맞는 것 **하나만** 실행합니다.

**Windows** (PowerShell)
```bash
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
```

**macOS** (터미널)
```bash
bash scripts/setup-macos.sh
```

스크립트는 VS Code / Git / PlatformIO 확장을 설치하며, **아무것도 지우지 않습니다.**
이미 설치된 항목은 건너뜁니다.

### 3단계 — VS Code 로 폴더 열고 점검

1. VS Code 를 완전히 종료했다가, **이 폴더(`mc2026`)를 폴더째로** 엽니다.
   - 파일 하나만 여는 게 아니라 `File > Open Folder` 로 폴더를 열어야 합니다.
2. 우측 하단에 "PlatformIO Core 설치 중" 알림이 뜹니다. **끝날 때까지 기다립니다** (최초 5~10분).
3. 설치가 끝나면 점검 스크립트를 실행합니다.

**Windows**
```bash
powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
```

**macOS**
```bash
bash scripts/doctor.sh
```

마지막 줄에 `점검 통과` 가 나오면 준비 완료입니다.

상세 절차와 스크린샷 수준의 안내는 OS별 문서를 보세요.
- Windows → [docs/SETUP-Windows.md](docs/SETUP-Windows.md)
- macOS → [docs/SETUP-macOS.md](docs/SETUP-macOS.md)

---

## 2. 빌드 / 업로드 / 시리얼 모니터

**두 OS의 조작 방법은 완전히 같습니다.** VS Code 맨 아래 파란 상태 표시줄을 쓰세요.

| 아이콘 | 이름 | 하는 일 |
|---|---|---|
| ✓ (체크) | Build | 컴파일만 함. 보드 없어도 됨 |
| → (오른쪽 화살표) | Upload | 컴파일 + 보드에 쓰기 |
| 🗑 (휴지통) | Clean | 빌드 캐시 삭제. 이상할 때 |
| 🔌 (플러그) | Serial Monitor | 시리얼 출력 보기 (종료: `Ctrl + C`) |

아이콘 위에 마우스를 올리면 이름이 뜹니다.
헷갈리면 **명령 팔레트**가 가장 확실합니다.

- Windows: `Ctrl + Shift + P` → `PlatformIO: Upload`
- macOS: `Cmd + Shift + P` → `PlatformIO: Upload`

> 단축키(`Ctrl+Alt+B` 등)도 있지만 OS·버전에 따라 다를 수 있으니,
> 수업에서는 **상태 표시줄 아이콘**을 기준으로 설명합니다.

### 첫 동작 확인

`src/main.cpp` 를 업로드하면:
- 보드의 `L` LED 가 1초 주기로 점멸
- 시리얼 모니터에 1초마다 `[tick N] uptime = N s` 출력
- 모니터에 글자를 입력하고 Enter → 그대로 되돌아옴

세 가지가 모두 되면 컴파일·업로드·통신이 전부 정상입니다.

---

## 3. 폴더 구조

```
mc2026/
├── platformio.ini      ← 툴체인 버전이 고정된 핵심 파일. 함부로 고치지 말 것
├── src/                ← 실습 코드를 작성하는 곳
│   └── main.cpp
├── include/            ← 공용 헤더(.h)
├── lib/                ← 직접 만든 라이브러리
├── .vscode/            ← 편집기 설정 (팀 공용, 커밋됨)
├── scripts/            ← 설치·점검 스크립트
├── docs/               ← 설치 안내 / 문제 해결
└── .pio/               ← 빌드 산출물. 자동 생성되며 git 에 올라가지 않음
```

---

## 4. 라이브러리 추가하는 법

라이브러리를 **폴더에 복사하지 마세요.** `platformio.ini` 의 `lib_deps` 에
**버전까지** 적으면 두 OS가 같은 버전을 자동으로 내려받습니다.

```ini
[env:uno]
board = uno
lib_deps =
	adafruit/Adafruit SSD1306@2.5.13
	paulstoffregen/OneWire@2.3.8
```

라이브러리 이름은 <https://registry.platformio.org/> 에서 검색합니다.
버전 번호(`@2.5.13`)를 빼면 학생마다 다른 버전이 깔려 "제 PC에선 되는데요" 상황이 생깁니다.

---

## 5. 왜 Arduino IDE 가 아니라 PlatformIO 인가

| | Arduino IDE | PlatformIO |
|---|---|---|
| 버전 고정 | 각자 설치한 버전 사용 | `platformio.ini` 로 프로젝트 단위 고정 |
| 라이브러리 | 전역 설치, 충돌 잦음 | 프로젝트별 격리 |
| 자동완성 | 약함 | VS Code C/C++ 수준 |
| Git 연동 | 별도 | 편집기에 내장 |
| OS 차이 | 설정이 각자 다름 | 설정 파일이 저장소에 포함 |

핵심은 **`platformio.ini` 한 파일이 저장소에 들어 있다는 것**입니다.
누가 어떤 OS에서 clone 하든 같은 컴파일러, 같은 코어, 같은 라이브러리 버전을 씁니다.

---

## 6. 문제가 생기면

1. 먼저 [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) 에서 **증상**으로 찾아보세요.
2. 그래도 안 되면 조교에게 문의할 때 아래를 **그대로 복사**해서 보내주세요.
   - 사용 OS와 버전
   - `doctor` 스크립트 실행 결과 전체
   - VS Code 하단 터미널의 빨간 오류 메시지 전체 (일부 말고 전체)
