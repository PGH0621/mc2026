# macOS 설치 상세 안내

> 이 문서는 **macOS 전용** 절차만 다룹니다.
> 공통 사용법(빌드·업로드·단축키·라이브러리)은 [../README.md](../README.md) 를 보세요.

대상: macOS 12 (Monterey) 이상 / Intel · Apple Silicon(M1~M4) 공통

---

## 1. 설치 전 확인

### 1-1. 디스크 여유 공간
**최소 2 GB**, 권장 5 GB.
PlatformIO 는 AVR 툴체인을 `~/.platformio` 에 약 400 MB 내려받습니다.

확인: 터미널에서
```bash
df -h ~
```

### 1-2. 프로젝트를 둘 폴더
- 권장: `~/dev/mc2026`
- 비권장: `~/Desktop/마이크로컨트롤러 응용/...` (한글·공백 경로)
- **iCloud Drive 안에 두지 마세요.** `~/Desktop`, `~/Documents` 가 iCloud 동기화 대상으로
  설정된 경우, 빌드 중 파일이 "최적화"되어 사라진 것처럼 보이는 문제가 생깁니다.

확인:
```bash
ls ~/Library/Mobile\ Documents/com~apple~CloudDocs 2>/dev/null && echo "iCloud Drive 사용 중"
```

### 1-3. 아키텍처 확인
```bash
uname -m
```
- `arm64` → Apple Silicon
- `x86_64` → Intel

두 경우 모두 지원되며, PlatformIO 가 알아서 맞는 툴체인을 받습니다.
**Rosetta 를 켤 필요 없습니다.**

---

## 2. 자동 설치

```bash
cd ~/dev/mc2026
bash scripts/setup-macos.sh
```

Homebrew 가 없으면 스크립트가 설치 명령을 안내하고 멈춥니다.
안내된 명령을 실행한 뒤 스크립트를 다시 돌리세요.

---

## 3. 수동 설치

### 3-1. Xcode Command Line Tools (git 포함)
```bash
xcode-select --install
```
창이 뜨면 **설치**를 누릅니다. 이미 설치되어 있으면 오류 메시지가 나오는데, 무시해도 됩니다.

### 3-2. Homebrew (선택이지만 권장)
<https://brew.sh> 의 설치 명령을 복사해 실행합니다.

설치가 끝나면 터미널이 아래 같은 줄을 알려줍니다. **반드시 그대로 실행**해야
`brew` 명령이 인식됩니다.

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

> Apple Silicon 은 `/opt/homebrew`, Intel 은 `/usr/local` 입니다.
> 터미널이 알려준 경로를 그대로 쓰세요.

### 3-3. Visual Studio Code
```bash
brew install --cask visual-studio-code
```
또는 <https://code.visualstudio.com/> 에서 내려받아 **응용 프로그램** 폴더로 드래그.

### 3-4. `code` 터미널 명령 등록
VS Code 를 열고:
1. `Cmd + Shift + P`
2. `Shell Command: Install 'code' command in PATH` 실행

터미널을 새로 열고 확인:
```bash
code --version
```

### 3-5. PlatformIO IDE 확장
VS Code → 좌측 확장 아이콘 → `PlatformIO IDE` 검색 → Install
- 만든이가 **PlatformIO** 인지 확인하세요.
- `C/C++` 확장이 같이 깔립니다. 정상입니다.

설치 후 VS Code 를 완전히 종료(`Cmd + Q`)했다가 다시 열고,
`File > Open Folder` 로 `mc2026` 폴더를 엽니다.
우측 하단 "PlatformIO Core 설치 중" 알림이 끝날 때까지 기다립니다 (5~10분).

### 구형 Arduino 확장이 이미 있다면
```bash
code --uninstall-extension vsciot-vscode.vscode-arduino
```

---

## 4. 시리얼 포트: `cu.` 와 `tty.` 의 차이

macOS 는 같은 장치를 두 이름으로 보여줍니다.

```
/dev/cu.usbserial-1420     ← 이것을 쓰세요
/dev/tty.usbserial-1420    ← 쓰지 마세요
```

| | 용도 | 아두이노에서 |
|---|---|---|
| `cu.*` | call-out. 바로 열림 | **정상 동작** |
| `tty.*` | call-in. DCD 신호를 기다림 | **멈춰버림** |

`tty.` 를 지정하면 업로드나 모니터가 아무 반응 없이 멈춘 것처럼 보입니다.
PlatformIO 는 자동 선택 시 `cu.` 를 고르므로, 보통은 신경 쓸 필요가 없습니다.

### 연결된 포트 확인
```bash
ls /dev/cu.*
```

| 보이는 이름 | 보드 |
|---|---|
| `/dev/cu.usbmodem14101` | 정품 Arduino Uno R3 |
| `/dev/cu.usbserial-1420` | CH340 호환 보드 |
| `/dev/cu.wchusbserial-1420` | CH340 (WCH 드라이버 설치됨) |
| `/dev/cu.SLAB_USBtoUART` | CP2102 호환 보드 |
| `/dev/cu.Bluetooth-Incoming-Port` | 블루투스. **보드 아님, 무시** |

---

## 5. 드라이버

| 보드 | 드라이버 |
|---|---|
| 정품 Arduino Uno R3 | **불필요** |
| CH340 호환 보드 | macOS 11 이상은 **내장 드라이버로 대부분 인식됨** |
| CP2102 호환 보드 | 보통 불필요 |

### CH340 이 인식 안 될 때
보드를 꽂고 `ls /dev/cu.*` 에 아무것도 안 늘어난다면:

1. **먼저 케이블을 의심하세요.** 충전 전용 케이블이 가장 흔한 원인입니다.
   다른 케이블로 바꿔 보세요.
2. USB 허브를 거치지 말고 Mac 본체에 직접 꽂아 보세요.
3. 그래도 안 되면 WCH 공식 드라이버를 설치합니다:
   <https://www.wch-ic.com/downloads/CH34XSER_MAC_ZIP.html>

> **주의**: macOS 내장 드라이버와 WCH 드라이버가 **동시에 있으면 충돌**합니다.
> 내장 드라이버로 잘 되고 있다면 WCH 드라이버를 설치하지 마세요.
> 이미 설치해서 문제가 생겼다면 WCH 드라이버를 제거하고 재부팅하세요.

---

## 6. 보안 경고 (Gatekeeper)

앱이나 드라이버 실행 시 "확인되지 않은 개발자" 경고가 뜨면:

**시스템 설정 → 개인정보 보호 및 보안 → 보안** 항목 맨 아래의
`"..."이(가) 차단되었습니다` 옆 **"그래도 열기"** 를 누릅니다.

VS Code 와 PlatformIO 자체는 정상 서명되어 있어 이 과정이 필요 없습니다.
주로 서드파티 USB 드라이버에서 발생합니다.

---

## 7. 여기까지 했는데 안 될 때

[TROUBLESHOOTING.md](TROUBLESHOOTING.md) 에서 **증상**으로 찾으세요.
