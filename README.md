⏱️ UART + Stopwatch Project

UART 통신을 통해 외부 입력으로 Stopwatch를 제어할 수 있는 FPGA 기반 프로젝트
개발자: 윤종민, 권혁진

📌 프로젝트 개요

목적
UART와 Stopwatch를 연결하여, 버튼/스위치뿐만 아니라 외부 입력(RX, TX)으로도 제어 가능하게 설계

동작 원리
외부 입력(rx, tx) → control unit → Stopwatch 신호 전달 → 버튼/스위치와 동일한 제어 수행

🏗️ 시스템 구성
하드웨어 스펙

16 User Switches

16 User LEDs

5 User Pushbuttons

4-digit 7-Segment Display

Block Diagram
<img width="1205" height="439" alt="image" src="https://github.com/user-attachments/assets/0a1905c4-ec68-4ab9-a60f-c69020b50780" />


구성 요소:

UART Controller

Baudrate Generator

UART TX / RX

Control Unit (CU)

입력 해석 및 Stopwatch 제어 신호 생성

Stopwatch

시간 증가/감소, 선택, 출력 표시 (FND + LED)

⚙️ 주요 동작
1. UART Controller

FSM-TX

IDLE → START → DATA(bit 전송) → STOP

FSM-RX

IDLE → START 감지 → DATA 수신 → STOP

2. Control Unit (CU)

rx_done 신호 감지 → 버튼/스위치 입력 해석 → Stopwatch 제어

입력 해석 예시

'M' (0x4D) 입력 시 → i_sw[0] 토글

ESC 입력 시 → Reset

버튼 입력 시 → Up / Down 반영

3. Stopwatch

선택된 영역(msec, sec, min, hour) 제어

버튼 동작

btnL: 분 선택

btnD: 값 내림

btnU: 값 올림

Debouncing 적용: 버튼 노이즈 방지

🔎 Simulation & 동작 검증

UART RX: 12 baud_tick 이후 수신 시작, rx_done 신호 발생

UART TX: rx_done 1 tick 후 전송 시작 → Stop bit로 종료

FND/LED 동작:

LED 패턴 (00001, 00010 등)으로 시간 단위 표시

FND 값 즉시 변화 확인

🐞 Trouble Shooting

이슈 1: sw0 ON 상태에서 외부 입력 무반응

원인: Debounce가 UART, Stopwatch에서 중복 적용됨

해결: Debounce 처리 수정

이슈 2: UART → Stopwatch 와이어링 누락

해결: 파형 분석 후 배선 보강

📝 배운 점

**일관성 있는 네이밍(xdc, module, 변수)**의 중요성 체감

확장성을 고려해 명확하고 구분이 잘 되는 이름을 사용하는 습관 필요

UART와 Stopwatch 통합 과정에서 디버깅 능력 강화
