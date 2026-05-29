# 12주차 웹 서버 보안 및 취약점 점검 실습

## 1. 실습 주제

10주차에 구축한 WordPress 3-Tier 웹 서버 환경에 HTTPS 보안 설정을 적용하고, Lynis와 Trivy를 이용하여 시스템 및 컨테이너 이미지 보안 점검을 수행하였다.

## 2. 실습 환경

- MacBook Pro Apple Silicon
- macOS Sequoia
- zsh
- Docker Desktop 29.2.1
- Docker Compose v5.1.0
- Lynis 3.1.6
- Trivy 0.70.0
- 학번: 20201000

## 3. 기존 웹 서버 구성

- wp_nginx: Nginx 웹 서버
- wp_app: WordPress PHP-FPM
- wp_db: MySQL 8.0

## 4. HTTPS 적용

자체 서명 인증서를 생성하여 Nginx에 HTTPS 설정을 적용하였다.

생성된 인증서 파일:

- nginx/certs/nginx-selfsigned.crt
- nginx/certs/nginx-selfsigned.key

Nginx 설정에는 443 SSL 서버 블록을 추가하고, HTTP 8080 요청은 HTTPS 8443으로 리다이렉트되도록 설정하였다.

## 5. Nginx 보안 헤더 설정

HTTPS 응답에 다음 보안 헤더가 적용되었다.

- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Strict-Transport-Security: max-age=31536000; includeSubDomains
- Referrer-Policy: strict-origin-when-cross-origin

## 6. HTTPS 및 TLS 확인

HTTPS 접속 확인 결과 `https://localhost:8443`에서 WordPress 페이지가 정상 표시되었다.

확인 결과:

- HTTP 8080 → HTTPS 8443 리다이렉트 확인
- HTTPS 응답 코드: 200 OK
- TLS 1.2 차단 확인
- TLS 1.3 연결 확인
- 자체 서명 인증서 유효기간 확인

TLS 1.3 확인 결과:

- Protocol: TLSv1.3
- Cipher: TLS_AES_256_GCM_SHA384
- Verify return code: 18 self-signed certificate

## 7. Lynis 보안 감사 결과

Lynis를 이용하여 시스템 보안 감사를 수행하였다.

실행 명령어:

```bash
sudo lynis audit system --quick

주요 결과:

Lynis version: 3.1.6
Warnings: 1
Suggestions: 19
Hardening index: 63

주요 Warning:

NETW-2705: Couldn't find 2 responsive nameservers

해석:

Lynis 감사 결과 시스템 보안 강화 지수는 63으로 확인되었다. 실습 환경은 macOS Docker Desktop 기반이므로 Linux 서버와 일부 점검 항목이 다르게 나타날 수 있다. 1개의 Warning과 19개의 Suggestion이 확인되었으며, 이는 시스템 보안 강화를 위해 추가 점검이 필요한 항목으로 볼 수 있다.

8. Trivy 컨테이너 이미지 취약점 스캔 결과

Trivy를 이용하여 실습 환경에서 사용하는 주요 컨테이너 이미지를 스캔하였다.

스캔 대상:

nginx:alpine
wordpress:php8.2-fpm
mysql:8.0
nginx:alpine
Total: 42
UNKNOWN: 0
LOW: 4
MEDIUM: 24
HIGH: 12
CRITICAL: 2
wordpress:php8.2-fpm
Total: 1387
UNKNOWN: 138
LOW: 713
MEDIUM: 422
HIGH: 101
CRITICAL: 13
mysql:8.0
Total: 33
UNKNOWN: 0
LOW: 1
MEDIUM: 6
HIGH: 25
CRITICAL: 1

해석:

WordPress 이미지에서 가장 많은 취약점이 확인되었으며, Nginx와 MySQL 이미지에서도 HIGH 및 CRITICAL 등급 취약점이 일부 확인되었다. 이는 컨테이너 이미지 사용 시 최신 이미지 사용, 패키지 업데이트, 불필요한 패키지 제거, 이미지 경량화가 필요함을 보여준다.

9. 최종 컨테이너 상태

최종적으로 다음 컨테이너가 정상 실행 중임을 확인하였다.

wp_nginx
wp_app
wp_db
wp_portainer
wp_netdata

Nginx 컨테이너는 8080번 포트와 8443번 포트를 모두 사용하였다.

8080 → 80/tcp
8443 → 443/tcp
10. 실습 정리

이번 실습에서는 WordPress 3-Tier 웹 서버 환경에 HTTPS를 적용하고, 보안 헤더와 TLS 설정을 확인하였다. 또한 Lynis를 통해 시스템 보안 상태를 점검하고, Trivy를 통해 컨테이너 이미지 취약점을 분석하였다.

실습 결과 HTTPS 접속, HTTP to HTTPS 리다이렉트, TLS 1.3 적용, 보안 헤더 적용이 모두 정상적으로 확인되었다. 또한 보안 감사 및 이미지 취약점 스캔 결과를 통해 운영 환경에서는 지속적인 보안 점검과 이미지 업데이트가 필요함을 확인하였다.
