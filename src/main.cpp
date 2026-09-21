/**
 * 마이크로컨트롤러응용 2026 - 환경 점검용 예제 (Week 00)
 *
 * 목적: 개발환경이 올바르게 구성되었는지 3가지를 한 번에 확인한다.
 *   1) 컴파일       - 빌드가 성공하는가
 *   2) 업로드       - 보드에 실제로 써지는가 (LED 깜빡임으로 확인)
 *   3) 시리얼 통신  - 모니터에 글자가 보이는가
 *
 * 대상 보드: Arduino Uno R3 (ATmega328P @ 16MHz)
 *
 * 사용법 (Windows / macOS 동일):
 *   VS Code 맨 아래 파란 상태 표시줄의 아이콘을 사용합니다.
 *     체크(v) 모양   -> Build   (컴파일만)
 *     화살표(->) 모양 -> Upload  (컴파일 + 보드에 쓰기)
 *     플러그 모양     -> Serial Monitor  (종료는 Ctrl + C)
 *   아이콘이 헷갈리면 마우스를 올려 이름을 확인하거나,
 *   명령 팔레트(Ctrl+Shift+P / Cmd+Shift+P)에서 "PlatformIO: Upload" 를 검색하세요.
 *
 * 기대 결과:
 *   - 보드 위 L 표시 LED 가 1초 주기로 점멸
 *   - 시리얼 모니터에 1초마다 경과 시간이 출력
 *   - 모니터에 아무 글자나 입력 + Enter -> 그대로 되돌아옴(에코)
 */

#include <Arduino.h>

static const uint8_t  LED_PIN       = LED_BUILTIN;  // Uno 기준 13번 핀
static const uint32_t BLINK_PERIOD  = 1000UL;       // [ms] 점멸 주기
static const uint32_t SERIAL_BAUD   = 9600UL;       // platformio.ini 의 monitor_speed 와 반드시 일치

static uint32_t g_lastToggleMs = 0;
static bool     g_ledOn        = false;
static uint32_t g_tickCount    = 0;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  Serial.begin(SERIAL_BAUD);
  while (!Serial) {
    ; // Uno 에서는 즉시 통과. (Leonardo/Micro 계열 호환을 위해 남겨둠)
  }

  Serial.println();
  Serial.println(F("========================================"));
  Serial.println(F(" MCU Application 2026 - Environment OK"));
  Serial.print  (F(" Board  : "));
  Serial.println(F("Arduino Uno R3 (ATmega328P)"));
  Serial.print  (F(" Build  : "));
  Serial.print  (F(__DATE__));
  Serial.print  (F(" "));
  Serial.println(F(__TIME__));
  Serial.println(F("========================================"));
  Serial.println(F("아무 글자나 입력하고 Enter 를 눌러보세요."));
}

void loop() {
  // ---- 1) 논블로킹 LED 점멸 --------------------------------
  // delay() 를 쓰지 않는 이유: delay 동안에는 시리얼 입력을 받을 수 없다.
  const uint32_t now = millis();
  if (now - g_lastToggleMs >= BLINK_PERIOD) {
    g_lastToggleMs = now;
    g_ledOn = !g_ledOn;
    digitalWrite(LED_PIN, g_ledOn ? HIGH : LOW);

    if (g_ledOn) {
      g_tickCount++;
      Serial.print(F("[tick "));
      Serial.print(g_tickCount);
      Serial.print(F("] uptime = "));
      Serial.print(now / 1000UL);
      Serial.println(F(" s"));
    }
  }

  // ---- 2) 시리얼 에코 --------------------------------------
  if (Serial.available() > 0) {
    const String line = Serial.readStringUntil('\n');
    Serial.print(F("  <- echo: "));
    Serial.println(line);
  }
}
