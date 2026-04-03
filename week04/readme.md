# 4주차 실습: 계정 및 권한 관리 보완
- 실습 일시: 2026-04-03
- 작성자: 20201000

## 1. 로그인 배너 설정
- /etc/motd 파일로 로그인 환영 메시지 설정

## 2. ACL 보완
- student2의 dev_share 권한을 --x에서 r-x로 수정
- getfacl로 설정 확인

## 3. 권한 테스트 결과
- student2: 목록 확인 + test.sh 실행 성공
- student3: dev_team1 그룹 없음, 접근 완전 차단
- student6: 삭제된 계정 확인

## 4. Mac 환경 특이사항
- Docker 볼륨 마운트 경로(/usr/share/nginx/html)는 ACL 미지원
- /home 경로에서 정상 동작 확인
