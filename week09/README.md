# 9주차 실습: 파일시스템 관리 - 2

- 실습 일시: 2026-05-08
- 작성자: 20201000

## 1. 실습 목표
- LVM 구성 (PV/VG/LV)
- 가상 디스크 생성 및 루프 디바이스 연결
- I/O 특성 분석 (순차/랜덤)
- Quota를 이용한 디스크 사용량 제한

## 2. 주요 실습 내용

### 디스크 A (Docker용, 1GB)
- disk_a.img → /dev/loop0 → vg_docker → lv_docker
- mkfs.ext4 → /mnt/docker_new 마운트
- 순차 읽기: BW=9143 MiB/s

### 디스크 B (MySQL용, 2GB)
- disk_b.img → /dev/loop1 → vg_mysql → lv_mysql
- fstab UUID 등록 → /mnt/mysql_data 마운트
- LV 온라인 확장: 1GB → 1.5GB (lvextend + resize2fs)
- 랜덤 읽기: BW=110 MiB/s

### 디스크 C (Home Quota용, 2GB)
- disk_c.img → /dev/loop2 → vg_home → lv_home
- quota 옵션으로 마운트
- student1 quota 설정: soft 100M / hard 120M

### setup_disks.sh
- 세 디스크 자동 재연결 스크립트
- 이미 연결된 경우 중복 연결 방지

