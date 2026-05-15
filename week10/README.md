# 10주차 웹 서버 구축운영 실습

## 1. 실습 주제

Docker Compose를 이용하여 Nginx, WordPress(PHP-FPM), MySQL 8.0 기반의 3-Tier 웹 서버를 구축하였다.

## 2. 실습 환경

- 컴퓨터: MacBook Pro Apple Silicon
- OS: macOS Sequoia
- Shell: zsh
- Docker Desktop: 29.2.1
- Docker Compose: v5.1.0
- 학번: 20201000

## 3. 3-Tier 구조

Client Browser -> Nginx(:8080) -> WordPress PHP-FPM(:9000) -> MySQL(:3306)

## 4. Mac 환경에서 수정한 점

수업 자료는 Linux/WSL 환경을 기준으로 작성되어 있었기 때문에 Mac 환경에 맞게 일부 명령어와 경로를 수정하였다.

| 수업 자료 기준 | Mac 환경 적용 |
|---|---|
| script -t=t.txt -af 로그파일 | script -a 로그파일 |
| /mnt/mysql_data | ./mysql_data |
| Linux LVM Bind Mount | Mac 로컬 Bind Mount |
| sudo nano | nano |

## 5. 생성한 주요 파일

- wordpress/compose.db.yaml
- wordpress/compose.wordpress.yaml
- wordpress/compose.nginx.yaml
- wordpress/nginx/default.conf
- wordpress/setup_docker.sh
- 2026_20201000_week10_log.txt

## 6. 실행 결과

DB, WordPress, Nginx 컨테이너가 모두 정상 실행되었다.

- wp_db: mysql:8.0, healthy
- wp_app: wordpress:php8.2-fpm, 9000/tcp
- wp_nginx: nginx:alpine, 8080->80/tcp

웹 응답 확인 결과는 다음과 같다.

- curl http://localhost:8080
- 결과: 302

이후 브라우저에서 WordPress 설치 마법사를 실행하였고, 관리자 로그인 및 메인 화면 접속까지 확인하였다.

## 7. 로그 확인

Nginx access.log에서 다음 접속 기록을 확인하였다.

- GET / HTTP/1.1 200
- GET /wp-admin/ HTTP/1.1 200

error.log에는 favicon.ico 파일이 없다는 기록이 있었으나, 사이트 동작에는 영향을 주지 않는 단순 파일 요청 오류로 판단하였다.

## 8. 자동화 스크립트

setup_docker.sh를 작성하여 다음 과정을 자동화하였다.

1. 설정 파일 확인
2. MySQL 데이터 폴더 확인
3. 기존 서비스 정리
4. DB + WordPress + Nginx 전체 실행
5. 컨테이너 상태 확인

## 9. 실습 정리

이번 실습을 통해 Nginx, WordPress PHP-FPM, MySQL을 Docker Compose로 분리하여 구성하는 3-Tier 웹 서버 구조를 구축하였다.

Nginx는 외부 요청을 받고, PHP 요청은 WordPress PHP-FPM 컨테이너로 전달하며, WordPress는 MySQL 컨테이너와 통신하여 데이터를 저장한다.

Mac 환경에서는 Linux의 LVM 경로를 그대로 사용할 수 없기 때문에 MySQL 저장소를 로컬 Bind Mount 방식인 ./mysql_data로 변경하여 실습을 진행하였다.
