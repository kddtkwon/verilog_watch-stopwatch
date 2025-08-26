⏱️ UART + Stopwatch Project

FPGA 기반 UART ↔ Stopwatch 연동
외부 입력(RX/TX)으로 Stopwatch를 제어할 수 있는 Verilog 프로젝트
개발자: 윤종민 · 권혁진

📌 프로젝트 개요

🔹 목적
UART와 Stopwatch를 연결하여, 버튼/스위치뿐 아니라 UART 입력으로도 제어 가능하게 제작

🔹 동작 흐름

[UART RX/TX 입력] → [Control Unit] → [Stopwatch]  


버튼/스위치 제어와 동일하게 동작하도록 설계

🏗️ 시스템 구성
📟 하드웨어 스펙

🔘 16 User Switches

💡 16 User LEDs

🔳 5 User Pushbuttons

⏲️ 4-digit 7-Segment Display

📐 Block Diagram
<p align="center"> <img src="doc/block_diagram.png" width="600" alt="Block Diagram"/> </p>

구성 모듈:

UART Controller: Baudrate Generator, TX, RX

Control Unit (CU): 수신 데이터 → Stopwatch 제어 신호 변환

Stopwatch: msec/sec/min/hour 단위 시간 관리

⚙️ 동작 원리
1️⃣ UART Controller

TX FSM
IDLE → START → DATA(bits) → STOP

RX FSM
IDLE → START 감지 → DATA 수신 → STOP

2️⃣ Control Unit (CU)

rx_done = 1 → 수신 데이터 해석 → Stopwatch 제어

입력 매핑 예시

입력 값	동작
'M' (0x4D)	i_sw[0] 토글
ESC	Reset
버튼 코드	Up/Down 반영
3️⃣ Stopwatch

선택된 단위(msec, sec, min, hour) 제어

버튼 기능

btnL: 분 선택

btnD: 값 감소

btnU: 값 증가

Debouncing 적용 → 노이즈 무시

🔎 Simulation & 검증

UART RX: 12 baud_tick 후 수신 시작 → rx_done 발생

UART TX: rx_done 이후 1 tick에서 전송 시작 → Stop bit로 종료

FND/LED 출력

LED: 00001 (msec/sec), 00010 (min/hour)

FND: 값 실시간 변화 확인

<p align="center"> <img src="doc/sim_waveform.png" width="700" alt="Simulation Waveform"/> </p>
🐞 Trouble Shooting
문제	원인	해결
sw0 ON 시 외부 입력 무반응	UART와 Stopwatch에서 Debounce 중복 적용	Debounce 처리 수정
UART 값 전달 불가	와이어링 누락	파형 검증 후 배선 보강
📝 배운 점

**일관된 네이밍(xdc, 모듈, 변수)**의 중요성

혼동 없는 명확한 이름 설계 습관 필요

UART ↔ Stopwatch 통합 과정에서 디버깅 능력 강화
