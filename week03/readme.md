# 3주차 실습: 계정 및 권한 관리

- 실습 일시: 2026-03-20
- 작성자: 20201000

## 1. 실습 목표
- Docker Compose로 컨테이너 기반 웹 서버 관리
- 계정 및 파일 권한 제어
- 다중 계정 생성 자동화
- 팀별 공유 폴더 설정 및 ACL 권한 관리

## 2. Docker Compose 설정
- nginx:1.25-alpine 이미지로 my-web-proxy 컨테이너 실행
- docker-compose.yml로 볼륨, 네트워크 설정

## 3. 접근 권한과 RBAC
- pds 폴더 생성 후 chmod 770으로 권한 설정
- guest 계정 생성 및 접근 제한 확인
- web_admin 계정 생성 및 sudoers 설정
  - docker compose restart만 허용

## 4. 계정 생성 자동화
- /etc/skel 설정 (umask 077, HISTTIMEFORMAT)
- create_user.sh 스크립트로 student1~20 자동 생성
- 기본 패스워드 설정 및 readme.txt 자동 배포

## 5. 팀 공유 폴더와 SetGID
- dev_team1 그룹 생성
- student1~5 그룹 추가 (team_user.sh)
- dev_share 폴더에 SetGID(2750) 설정
- student9(외부인) 접근 차단 확인

## 6. ACL 세부 권한 설정
- setfacl로 student2에게 test.sh 실행 권한 부여
- getfacl로 ACL 설정 확인
- su-exec로 student2 실행 테스트 성공

## 7. 실습문제
- web_admin sudoers: docker compose restart만 허용
- delete_user.sh로 student6~20 계정 삭제
- team_share 폴더 생성 및 student3,4 그룹 제거
