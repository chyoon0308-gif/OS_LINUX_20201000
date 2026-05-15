#!/bin/bash

# 1. 실습 디렉토리 이동
PROJECT_DIR="$HOME/linux/week10/wordpress"
cd "$PROJECT_DIR" || { echo "디렉토리를 찾을 수 없습니다."; exit 1; }

# 2. 필수 설정 파일 확인
echo "=== 설정 파일 체크 ==="
if [ ! -f ".env" ] || [ ! -f "./nginx/default.conf" ]; then
  echo "[오류] .env 또는 nginx/default.conf 파일이 누락되었습니다."
  exit 1
fi

if [ ! -f "compose.db.yaml" ] || [ ! -f "compose.wordpress.yaml" ] || [ ! -f "compose.nginx.yaml" ]; then
  echo "[오류] compose yaml 파일 중 일부가 누락되었습니다."
  exit 1
fi

# 3. MySQL 데이터 폴더 확인
echo "=== MySQL 데이터 폴더 확인 ==="
mkdir -p ./mysql_data
ls -ld ./mysql_data

# 4. 기존 서비스 정리
echo "=== 기존 서비스 정리 ==="
docker compose \
  -f compose.db.yaml \
  -f compose.wordpress.yaml \
  -f compose.nginx.yaml \
  down

# 5. 3-Tier 아키텍처 실행
echo "=== 3-Tier 아키텍처 실행 시작 ==="
docker compose \
  -f compose.db.yaml \
  -f compose.wordpress.yaml \
  -f compose.nginx.yaml \
  up -d

# 6. 최종 상태 확인
echo "=== 서비스 전체 상태 확인 ==="
docker compose \
  -f compose.db.yaml \
  -f compose.wordpress.yaml \
  -f compose.nginx.yaml \
  ps

echo "=== 접속 주소 ==="
echo "http://localhost:8080"
