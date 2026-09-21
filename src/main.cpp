/**
 * 실습 01 - LED Blink
 *
 * 목표: Arduino 프로그램의 기본 구조(setup / loop)를 이해하고
 *       디지털 출력으로 LED를 제어한다.
 *
 * 회로: 아두이노 보드에 내장된 LED 사용 (13번 핀). 추가 배선 불필요.
 */

#include <Arduino.h>

// ── 설정값 ────────────────────────────────────────────────
// 이 두 숫자를 바꿔가며 동작이 어떻게 달라지는지 관찰하세요.
const int LED_PIN  = 13;    // 내장 LED 가 연결된 핀 번호
const int ON_TIME  = 500;   // 켜져 있는 시간 [ms]
const int OFF_TIME = 500;   // 꺼져 있는 시간 [ms]

// ── setup() : 전원이 켜질 때 딱 한 번 실행 ────────────────
void setup() {
  // 13번 핀을 "출력"으로 쓰겠다고 선언한다.
  // 이 선언이 없으면 digitalWrite 를 해도 전압이 제대로 나오지 않는다.
  pinMode(LED_PIN, OUTPUT);
}

// ── loop() : setup() 이 끝난 뒤 무한 반복 ─────────────────
void loop() {
  digitalWrite(LED_PIN, HIGH);  // 5V 출력 → LED 켜짐
  delay(ON_TIME);               // ON_TIME 밀리초 동안 멈춤

  digitalWrite(LED_PIN, LOW);   // 0V 출력 → LED 꺼짐
  delay(OFF_TIME);              // OFF_TIME 밀리초 동안 멈춤
}

/*
 * ── 확인 문제 ──────────────────────────────────────────────
 * 1. ON_TIME 을 100, OFF_TIME 을 900 으로 바꾸면 어떻게 보이는가?
 * 2. 둘 다 50 으로 바꾸면? 둘 다 5 로 바꾸면?
 *    (사람 눈이 깜빡임을 구분하지 못하는 경계를 찾아보세요)
 * 3. setup() 안의 pinMode 줄을 지우면 어떻게 되는가?
 *
 * ── 참고 ──────────────────────────────────────────────────
 * delay() 는 그 시간 동안 CPU 를 완전히 묶어둔다.
 * 버튼 입력을 동시에 받으려면 delay() 로는 불가능하다.
 * 해결 방법(millis 사용)은 examples/00_env_check.cpp 를 참고.
 */
