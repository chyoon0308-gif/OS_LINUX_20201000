# 6주차 실습: 프로세스 관리 - 2

- 실습 일시: 2026-04-10
- 작성자: 20201000

## 1. 실습 목표
- 프로세스 스케줄링 이해 (CFS, nice, PCB)
- 프로세스 우선순위 제어 (nice, ulimit)
- Docker 컨테이너 CPU 제한 실습

## 2. 주요 실습 내용

### 프로세스 우선순위 확인
- `ps -al` : PRI, NI 값 확인
- `nice -n 15 sleep 300` : 우선순위 낮추기

### ulimit 프로세스 제한
- `ulimit -u 30` : 프로세스 30개로 제한
- fork failed 에러 직접 체험

### Docker CPU 제한
- 12코어 기준 25%씩 분배
- stress-nginx : 코어 0-2 (3코어)
- my-web-proxy : 코어 3-5 (3코어)
- ab 부하 테스트 : 10,000 요청 실패 0개, 13,536 req/sec
