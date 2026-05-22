# 11주차 웹 서버 관리 실습

## 1. 실습 주제
10주차에 구축한 WordPress 3-Tier 웹 서버 환경에 Portainer와 Netdata를 추가하여 Docker 컨테이너 관리 및 웹 서버 모니터링을 실습하였다.

## 2. 실습 환경
- MacBook Pro Apple Silicon
- macOS Sequoia
- zsh
- Docker Desktop 29.2.1
- Docker Compose v5.1.0
- 학번: 20201000

## 3. 기존 웹 서버 구성
- wp_nginx: Nginx 웹 서버
- wp_app: WordPress PHP-FPM
- wp_db: MySQL 8.0

## 4. 추가한 도구
- wp_portainer: Docker 컨테이너 관리 GUI
- wp_netdata: 웹 서버 및 컨테이너 모니터링 도구

## 5. Portainer 확인
접속 주소: https://localhost:9443

확인 내용:
- 컨테이너 목록 확인
- wp_nginx, wp_app, wp_db 상태 확인
- wp_nginx 상세 화면 확인
- Stats 탭에서 CPU, Memory, Network, I/O 확인
- Logs 탭에서 Nginx 실행 로그 확인

## 6. Nginx stub_status 설정
Netdata가 Nginx 상태를 수집할 수 있도록 /nginx_status를 추가하였다.

설정 내용:
location /nginx_status { stub_status on; allow all; }

동작 확인 결과:
Active connections: 1
server accepts handled requests
1 1 1
Reading: 0 Writing: 1 Waiting: 0

## 7. Netdata 확인
접속 주소: http://localhost:19999

확인 내용:
- CPU 사용률
- RAM 사용률
- Disk I/O
- Network Inbound / Outbound
- 컨테이너 및 가상 머신 상태

## 8. ApacheBench 부하 테스트
테스트 명령어: ab -n 2000 -c 50 http://localhost:8080/

주요 결과:
- Complete requests: 2000
- Failed requests: 0
- Requests per second: 206.47 [#/sec]
- Time per request: 242.161 ms
- Transfer rate: 13279.08 Kbytes/sec

## 9. 로그 확인
Nginx access.log에서 ApacheBench 요청을 확인하였다.
- GET / HTTP/1.0 200
- ApacheBench/2.3

Netdata가 Nginx 상태를 수집하는 로그도 확인하였다.
- GET /nginx_status HTTP/1.1 200
- Netdata go.d.plugin

## 10. 실습 정리
이번 실습을 통해 Portainer를 이용하여 Docker 컨테이너를 GUI로 관리하고, Netdata를 이용하여 웹 서버와 컨테이너 상태를 실시간으로 모니터링하였다.

부하 테스트 결과 총 2000개의 요청 중 실패 요청은 0개였고, 부하 테스트 이후에도 wp_nginx, wp_app, wp_db, wp_portainer, wp_netdata 컨테이너가 정상 실행 상태를 유지하였다.

Mac Docker Desktop 환경에서는 /nginx_status 접근 IP가 Linux/WSL 환경과 다르게 동작할 수 있어 실습용으로 allow all 설정을 적용하였다.
