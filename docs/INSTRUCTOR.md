# 조교 운영 메모

> 학생용 문서가 아닙니다. 수업 운영에 필요한 내용만 정리했습니다.
> 학생 안내는 [../README.md](../README.md) 와 `docs/SETUP-*.md` 가 원본입니다.
> **같은 내용을 여기에 복사하지 마세요.** 고칠 때 한쪽만 고쳐져 어긋납니다.

---

## 1. 첫 수업 전 체크리스트

- [ ] 빈 PC(또는 새 사용자 계정)에서 `git clone` → `setup` → `doctor` 를 **실제로** 한 번 돌려본다
- [ ] Windows 와 macOS **양쪽에서** 돌려본다 (한쪽만 확인하면 반드시 사고가 납니다)
- [ ] 강의 첫 주 공지에 **"여유 공간 2 GB, 데이터 전송용 USB 케이블"** 을 굵게 적는다
- [ ] 실습실 네트워크에서 `registry.platformio.org`, `dl.registry.platformio.org`,
      `github.com` 이 열리는지 확인한다 (차단되면 §4 오프라인 배포)
- [ ] 여분 USB 케이블을 몇 개 챙긴다 — 매 학기 **1순위 장애 원인**입니다

---

## 2. 툴체인 버전 고정 관리

현재 `platformio.ini` 에 고정된 버전
(2026-09-21 Windows 에서 `pio run` / `pio check` 실제 통과 확인):

| 패키지 | 버전 | 역할 |
|---|---|---|
| `platform` atmelavr | 5.3.0 | AVR 플랫폼 정의 |
| `framework-arduino-avr` | 5.4.0 | Arduino 코어 |
| `toolchain-atmelavr` | 3.70300.220127 | avr-gcc / binutils |
| `tool-avrdude` | 1.80100.0 | 업로드 도구 |

### 학기 시작 전 갱신할 때

1. 최신 버전 확인:
   ```bash
   curl -s https://api.registry.platformio.org/v3/packages/platformio/platform/atmelavr | python -c "import sys,json;print(json.load(sys.stdin)['version']['name'])"
   ```
2. `platformio.ini` 수정
3. 로컬에서 캐시를 비우고 깨끗하게 재현되는지 확인:
   ```bash
   pio pkg uninstall -e uno --platform atmelavr
   pio run -e uno
   pio pkg list -e uno
   ```
4. **학기 중에는 절대 올리지 마세요.** 중간에 바꾸면 이미 clone 한 학생과
   새로 받은 학생의 환경이 갈립니다.

### 학생 환경이 같은지 확인하는 법
`doctor` 5번 항목(`pio pkg list -e uno`) 출력을 비교하면 됩니다.
버전이 하나라도 다르면 `platformio.ini` 를 임의로 고쳤거나 clone 이 오래된 것입니다.

---

## 3. 주차별 코드 관리 방식

기본 저장소는 `src/main.cpp` 하나만 둔 **단일 실습** 구조입니다.
주차가 쌓이면 아래처럼 주차별 환경으로 나누는 것을 권합니다.

```
src/
  w03_led/main.cpp
  w04_serial/main.cpp
  w05_interrupt/main.cpp
```

```ini
[platformio]
default_envs = w03_led

[env:w03_led]
board = uno
build_src_filter = +<w03_led/>

[env:w04_serial]
board = uno
build_src_filter = +<w04_serial/>
```

- `build_src_filter` 로 해당 주차 폴더만 컴파일합니다.
  (안 쓰면 `main()` 이 여러 개라 링크 오류가 납니다)
- 학생은 VS Code 하단 상태 표시줄의 **환경 선택기**에서 주차를 고릅니다.
  (`Default (mc2026)` 라고 쓰인 부분을 클릭)
- `default_envs` 를 그 주차로 바꿔 두면 학생이 고를 필요가 없어 실수가 줄어듭니다.

### 대안: 주차별 브랜치
태그/브랜치로 나누는 방법도 있지만, 학생이 `git checkout` 을 잘못해
과제를 날리는 사고가 매년 나옵니다. **환경 분리 쪽을 권합니다.**

---

## 4. 네트워크 차단 / 오프라인 실습실 대비

실습실에서 외부 다운로드가 막혀 있다면, 미리 받아 둔 Core 폴더를 배포합니다.

1. 인터넷 되는 PC에서 `doctor` 를 끝까지 돌려 툴체인을 모두 받습니다.
2. 폴더를 통째로 압축합니다.
   - Windows: `C:\Users\<계정>\.platformio`
   - macOS: `~/.platformio`
3. 실습실 PC의 같은 위치에 풉니다.
4. `doctor` 를 돌려 **다운로드 없이** 빌드가 끝나는지 확인합니다.

> 이 방식은 **같은 OS 사이에서만** 통합니다.
> Windows 에서 받은 폴더를 Mac 에 넣으면 동작하지 않습니다. 각각 만들어야 합니다.

---

## 5. 과제 제출

권장: 학생별 저장소(fork 또는 GitHub Classroom) + PR.
채점 시 최소 확인 항목:

```bash
pio run -e <해당주차>     # 컴파일되는가
pio check -e <해당주차>   # cppcheck 경고 (platformio.ini 에 설정됨)
```

`build_src_flags` 로 `-Wall -Wextra` 가 학생 코드에만 걸려 있으므로,
경고 개수를 채점에 반영하기 쉽습니다.
`.clang-format` 이 있어 저장 시 자동 정렬되므로 스타일 편차도 줄어듭니다.

---

## 6. 매 학기 반복되는 학생 실수 Top 5

1. **충전 전용 USB 케이블** — 압도적 1위. 보드가 아예 안 보임
2. **시리얼 모니터를 켜 둔 채 업로드** — `stk500_recv()` 오류의 대부분
3. **폴더 하나만 열지 않고 파일만 열기** — PlatformIO 가 프로젝트를 인식 못 함
4. **경로에 한글** (Windows 계정 이름 포함) — 툴체인이 경로를 못 읽음
5. **`platformio.ini` 를 임의로 수정** — 특히 `upload_port` 를 커밋해서 남의 환경을 깸

첫 주에 이 5개를 미리 말해 두면 문의량이 눈에 띄게 줄어듭니다.
