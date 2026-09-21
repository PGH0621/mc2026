# Windows 설치 상세 안내

> 이 문서는 **Windows 전용** 절차만 다룹니다.
> 공통 사용법(빌드·업로드·단축키·라이브러리)은 [../README.md](../README.md) 를 보세요.

대상: Windows 10 (21H2 이상) / Windows 11

---

## 1. 설치 전 확인 (여기서 걸러야 나중에 안 고생합니다)

### 1-1. 디스크 여유 공간
`C:` 드라이브에 **최소 2 GB**, 권장 5 GB.
PlatformIO 는 AVR 툴체인을 `C:\Users\<계정>\.platformio` 에 약 400 MB 내려받습니다.

확인: `Win + E` → 내 PC → C: 드라이브 여유 용량

### 1-2. 프로젝트를 둘 폴더
다음 조건을 **모두** 만족하는 위치에 두세요.

| 조건 | 이유 |
|---|---|
| 경로에 한글 없음 | avr-gcc 가 비ASCII 경로를 못 읽습니다 |
| 경로에 공백 없음 | 일부 빌드 스크립트가 따옴표 처리를 안 합니다 |
| OneDrive 밖 | 동기화 중 파일 잠김 → 빌드 실패 |

- 권장: `C:\dev\mc2026`
- 비권장: `C:\Users\홍길동\바탕 화면\마이크로컨트롤러\...`

> **바탕화면 주의**: 요즘 Windows 는 `바탕 화면`·`문서` 폴더가 기본으로
> OneDrive 에 동기화됩니다. 경로가 `C:\Users\<계정>\OneDrive\...` 로 나온다면 옮기세요.

### 1-3. 계정 이름이 한글인 경우
`C:\Users\홍길동` 처럼 계정 폴더가 한글이면, 프로젝트를 다른 데 둬도
PlatformIO **툴체인 자체가** 한글 경로에 설치되어 빌드가 실패합니다.

설치 스크립트가 이를 감지해 자동으로 우회 설정을 넣습니다.
수동으로 하려면 (PowerShell):

```bash
[Environment]::SetEnvironmentVariable('PLATFORMIO_CORE_DIR','C:\pio-core','User')
```

설정 후 **VS Code 를 완전히 종료했다가** 다시 켜야 적용됩니다.

---

## 2. 자동 설치

저장소 폴더에서 PowerShell 을 열고:

```bash
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
```

> `-ExecutionPolicy Bypass` 는 **이 명령 한 번에만** 적용되며,
> 시스템의 스크립트 실행 정책을 영구히 바꾸지 않습니다.
> 학교 PC 정책을 건드리지 않으므로 안전합니다.

`이 시스템에서 스크립트를 실행할 수 없으므로...` 오류가 나면
위 명령을 **정확히 그대로** 썼는지 확인하세요. (`.\` 포함)

---

## 3. 수동 설치 (winget 이 없거나 스크립트가 실패할 때)

1. **Git** — <https://git-scm.com/download/win>
   설치 중 옵션은 전부 기본값으로 두면 됩니다.
2. **Visual Studio Code** — <https://code.visualstudio.com/>
   설치 화면에서 **"PATH에 추가"** 체크박스를 반드시 켜세요.
   (이게 꺼져 있으면 터미널에서 `code` 명령이 안 먹습니다)
3. **PlatformIO IDE 확장**
   VS Code → 좌측 확장 아이콘(네모 4개) → `PlatformIO IDE` 검색 → Install
   - 만든이가 **PlatformIO** 인지 확인하세요. 비슷한 이름의 다른 확장이 있습니다.
   - 설치하면 `C/C++` 확장이 같이 깔립니다. 정상입니다.
4. VS Code 를 완전히 종료 후 재실행 → `File > Open Folder` 로 `mc2026` 폴더 열기
5. 우측 하단 "PlatformIO Core 설치 중" 알림이 끝날 때까지 대기 (5~10분)

### 구형 Arduino 확장이 이미 있다면
`Arduino` (만든이: Microsoft) 확장은 PlatformIO 와 충돌합니다. 제거하세요.

```bash
code --uninstall-extension vsciot-vscode.vscode-arduino
```

---

## 4. 드라이버 (보드가 인식 안 될 때만)

| 보드 | USB 칩 | 드라이버 |
|---|---|---|
| 정품 Arduino Uno R3 | ATmega16U2 | **불필요** (Windows 기본 지원) |
| 호환 보드 (저가형) | CH340 / CH341 | 필요할 수 있음 |
| 일부 호환 보드 | CP2102 | 필요할 수 있음 |

### 확인 방법
1. 보드를 USB 로 연결
2. `Win + X` → **장치 관리자**
3. **포트(COM & LPT)** 항목을 폅니다.
   - `USB-SERIAL CH340 (COM3)` 처럼 보이면 → 정상, 드라이버 불필요
   - **기타 장치**에 `USB2.0-Serial` 이 노란 느낌표와 함께 보이면 → 드라이버 필요

### CH340 드라이버 설치
제조사 WCH 공식 페이지에서 내려받습니다: <https://www.wch-ic.com/downloads/CH341SER_EXE.html>

1. 내려받은 `CH341SER.EXE` 실행
2. **INSTALL** 버튼 클릭
3. 보드를 뽑았다 다시 꽂기
4. 장치 관리자에서 `포트(COM & LPT)` 아래로 옮겨졌는지 확인

> 드라이버는 출처가 분명한 제조사 사이트에서만 받으세요.
> 검색 결과 상단의 블로그 첨부파일은 사용하지 마세요.

---

## 5. COM 포트 번호 확인

```bash
powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
```

6번 항목에 `COM3`, `COM7` 같은 포트가 나옵니다.
보통은 PlatformIO 가 자동으로 찾으므로 번호를 적을 필요가 없습니다.

자동 인식이 실패할 때만 `platformio.ini` 에서 아래 두 줄의 주석을 풀고 본인 번호로 고칩니다.

```ini
upload_port = COM3
monitor_port = COM3
```

> 이 수정은 **본인 PC에서만** 필요한 것이므로 git 에 커밋하지 마세요.
> 커밋하면 다른 학생 환경이 깨집니다.

---

## 6. 백신 / 방화벽

일부 백신(특히 알약, V3, 회사 지정 백신)이 다음을 차단합니다.

| 차단 대상 | 증상 |
|---|---|
| `avr-gcc.exe` | 빌드가 중간에 멈추거나 "파일을 찾을 수 없음" |
| `avrdude.exe` | 업로드 시 `permission denied` |
| `.platformio` 폴더 쓰기 | Core 설치가 끝나지 않고 반복됨 |

해결: 백신의 **예외(제외) 목록**에 아래 두 경로를 추가합니다.
- `C:\Users\<계정>\.platformio` (또는 `C:\pio-core`)
- 프로젝트 폴더 (`C:\dev\mc2026`)

---

## 7. 여기까지 했는데 안 될 때

[TROUBLESHOOTING.md](TROUBLESHOOTING.md) 에서 **증상**으로 찾으세요.
