# 13주차 서버 백업 관리 실습

## 1. 실습 주제

이번 실습은 서버 백업 관리이다.  
Docker 기반 WordPress 서버를 대상으로 파일 백업, DB 백업, Restic 스냅샷 생성, 장애 상황 생성, 복구 실습을 진행하였다.  
추가로 WordPress 관리자 화면에서 UpdraftPlus 플러그인을 이용한 백업도 수행하였다.

## 2. 실습 환경

| 항목 | 내용 |
|---|---|
| OS | macOS Sequoia |
| 장비 | MacBook Pro Apple Silicon |
| Shell | zsh |
| 컨테이너 환경 | Docker Desktop |
| 실습 경로 | ~/linux/week13 |
| 백업 도구 | Restic |
| WordPress 백업 플러그인 | UpdraftPlus |

## 3. 기존 서버 구성

이전 실습에서 Docker Compose 기반 WordPress 3-Tier 서버를 구성하였다.

| 컨테이너명 | 역할 |
|---|---|
| wp_nginx | Nginx 웹 서버 |
| wp_app | WordPress PHP-FPM |
| wp_db | MySQL 8.0 |
| wp_portainer | Docker 관리 도구 |
| wp_netdata | 서버 모니터링 도구 |

실습 시작 전 `df -h`, `docker ps` 명령어로 디스크 상태와 컨테이너 상태를 확인하였다.

## 4. 백업 디렉토리 구성

week13 폴더 안에 다음 디렉토리를 생성하였다.

| 디렉토리 | 용도 |
|---|---|
| restic-repo | Restic 암호화 백업 저장소 |
| backup/db | MySQL 덤프 파일 저장 |
| backup/files | WordPress 파일 백업 저장 |
| restore | Restic 복구 파일 임시 저장 |

## 5. Restic 설치 및 저장소 초기화

macOS 환경이므로 Homebrew를 이용하여 Restic을 설치하였다.

- 설치 경로: /opt/homebrew/bin/restic
- 버전: restic 0.18.1
- 저장소 경로: ~/linux/week13/restic-repo

Restic 저장소를 초기화한 뒤, 내부에 config, data, index, keys, locks, snapshots 디렉토리가 생성된 것을 확인하였다.

## 6. WordPress 볼륨 확인

Docker volume 목록과 inspect 명령어를 통해 WordPress 볼륨을 확인하였다.

| 항목 | 내용 |
|---|---|
| 볼륨 이름 | wordpress_wp_data |
| 컨테이너 내부 경로 | /var/www/html |
| Docker 내부 경로 | /var/lib/docker/volumes/wordpress_wp_data/_data |

macOS Docker Desktop에서는 `/var/lib/docker/volumes/...` 경로를 호스트에서 직접 접근할 수 없었다.  
따라서 임시 Alpine 컨테이너를 사용하여 WordPress 볼륨 내부 파일을 확인하였다.

확인된 주요 파일 및 디렉토리는 다음과 같다.

- index.php
- wp-admin
- wp-content
- wp-includes
- wp-config.php

볼륨 크기는 약 90.7M로 확인되었다.

## 7. WordPress 파일 백업

macOS 환경에서는 Docker 볼륨 경로를 직접 Restic으로 백업하기 어렵기 때문에, 임시 Alpine 컨테이너를 이용하여 WordPress 볼륨을 tar.gz 파일로 백업하였다.

생성된 파일은 다음과 같다.

- backup/files/wp_files_2026-06-05.tar.gz

파일 크기는 약 28M로 확인되었다.

이후 해당 파일을 Restic 저장소에 백업하였다.

| 스냅샷 ID | 태그 | 설명 |
|---|---|---|
| 0c7c4857 | wp_files, week13 | WordPress 파일 1차 백업 |

## 8. 증분 백업 확인

WordPress 관리자 화면에서 테스트 게시글을 작성하였다.

| 항목 | 내용 |
|---|---|
| 제목 | 13주차 백업 실습 테스트 |
| 본문 | Restic 증분 백업 확인용 게시글입니다. |

게시글 작성 후 WordPress 볼륨을 다시 tar.gz 파일로 백업하였다.

생성된 파일은 다음과 같다.

- backup/files/wp_files_after_2026-06-05_1000.tar.gz

두 번째 Restic 백업을 실행한 결과 다음 스냅샷이 생성되었다.

| 스냅샷 ID | 태그 | 설명 |
|---|---|---|
| 0cb2b9f0 | wp_files, week13 | WordPress 파일 2차 백업 |

두 번째 백업에서는 parent snapshot이 사용되었고, 추가 저장 용량은 약 5.331 KiB로 확인되었다.  
이를 통해 Restic의 증분 백업 효과를 확인하였다.

diff 결과 새로 추가된 파일은 다음과 같다.

- wp_files_after_2026-06-05_1000.tar.gz

## 9. Restic 무결성 검사

Restic 저장소 무결성 검사를 수행하였다.

검사 결과 `no errors were found`가 출력되어 백업 저장소에 오류가 없음을 확인하였다.

## 10. MySQL DB 백업

DB는 실행 중인 볼륨 파일을 직접 복사하면 데이터 불일치가 발생할 수 있으므로 mysqldump를 사용하였다.

백업 전 `wp_posts` 개수를 확인한 결과 8개였다.

생성된 DB 덤프 파일은 다음과 같다.

- backup/db/db_2026-06-05.sql.gz

파일 크기는 약 337K로 확인되었다.

압축 파일 내부에서 CREATE TABLE 문을 확인하였고, 다음 주요 테이블이 포함되어 있었다.

- wp_comments
- wp_links
- wp_options
- wp_posts
- wp_users

## 11. DB 덤프 파일 Restic 백업

DB 덤프 파일을 Restic 저장소에 백업하였다.

| 스냅샷 ID | 태그 | 설명 |
|---|---|---|
| 0c008c81 | db_backup, 2026-06-05 | MySQL DB 덤프 백업 |

전체 스냅샷은 총 3개로 확인되었다.

| 스냅샷 ID | 설명 |
|---|---|
| 0c7c4857 | WordPress 파일 1차 백업 |
| 0cb2b9f0 | WordPress 파일 2차 백업 |
| 0c008c81 | MySQL DB 덤프 백업 |

## 12. 장애 상황 생성

복구 실습을 위해 WordPress 게시글을 삭제하였다.

삭제 후 `wp_posts` 개수를 확인한 결과 0개로 변경되었다.

브라우저에서도 다음 문구가 표시되어 게시글이 사라진 것을 확인하였다.

- Sorry, but nothing was found.

## 13. Restic을 이용한 DB 복구

DB 백업 스냅샷 `0c008c81`을 restore 디렉토리로 복구하였다.

복구된 DB 덤프 파일은 다음 위치에서 확인되었다.

- ~/linux/week13/restore/Users/mac/linux/week13/backup/db/db_2026-06-05.sql.gz

복구된 덤프 파일을 MySQL에 다시 입력한 뒤 `wp_posts` 개수를 확인하였다.

복원 후 결과는 다음과 같다.

- COUNT(*) = 8

브라우저에서도 삭제되었던 게시글이 다시 표시되는 것을 확인하였다.

## 14. UpdraftPlus 플러그인 백업

WordPress 관리자 화면에서 UpdraftPlus 플러그인을 설치하고 활성화하였다.

진행 순서는 다음과 같다.

1. 플러그인 메뉴 이동
2. 플러그인 추가
3. UpdraftPlus 검색
4. 지금 설치
5. 활성화
6. UpdraftPlus 화면에서 지금 백업 실행

백업 완료 후 기존 백업 목록에서 다음 항목들이 생성된 것을 확인하였다.

- 데이터베이스
- 플러그인
- 테마
- 업로드
- 기타

## 15. UpdraftPlus 백업 파일 위치 확인

macOS Docker Desktop 환경이므로 임시 Alpine 컨테이너를 이용하여 UpdraftPlus 백업 파일 위치를 확인하였다.

확인 경로는 다음과 같다.

- /data/wp-content/updraft/

확인된 주요 파일은 다음과 같다.

- backup_2026-06-05-0114_20201000_WordPress_Lab_...-db.gz
- backup_2026-06-05-0114_20201000_WordPress_Lab_...-others.zip
- backup_2026-06-05-0114_20201000_WordPress_Lab_...-plugins.zip
- backup_2026-06-05-0114_20201000_WordPress_Lab_...-themes.zip
- backup_2026-06-05-0114_20201000_WordPress_Lab_...-uploads.zip

전체 용량은 약 23.5M로 확인되었다.

## 16. CLI 백업과 UpdraftPlus 백업 비교

| 항목 | Restic + mysqldump | UpdraftPlus |
|---|---|---|
| 실행 방식 | 터미널 명령어 | WordPress 관리자 GUI |
| 백업 위치 | 외부 Restic 저장소 | WordPress 내부 wp-content/updraft |
| 암호화 | AES-256 암호화 지원 | 기본 압축 파일 |
| 중복 제거 | 지원 | 미지원 |
| 증분 백업 | Restic 스냅샷 기반 | 무료 버전은 제한적 |
| 무결성 검사 | restic check 지원 | 별도 검사 제한 |
| 복구 난이도 | 명령어 필요 | GUI 기반 복구 가능 |
| 실무 대상 | 서버 관리자 | WordPress 관리자 |

## 17. 실습 정리

이번 실습에서는 Docker 기반 WordPress 서버의 파일과 DB를 각각 백업하고 복구하였다.  
WordPress 파일은 Docker 볼륨을 tar.gz로 추출한 뒤 Restic으로 백업하였고, MySQL DB는 mysqldump를 사용하여 논리 백업을 수행하였다.

또한 Restic의 스냅샷, 증분 백업, 무결성 검사, 복구 기능을 확인하였다.  
게시글 삭제 장애 상황을 만든 뒤 DB 백업 스냅샷을 복구하여 게시글이 정상적으로 복원되는 것을 확인하였다.

마지막으로 UpdraftPlus 플러그인을 이용하여 WordPress 관리자 화면에서도 백업을 생성하고, 실제 백업 파일이 wp-content/updraft 디렉토리에 저장되는 것을 확인하였다.
