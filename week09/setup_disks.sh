#!/bin/bash

# 1. loop 디바이스 재연결
if ! losetup -a | grep -q disk_a.img; then
    losetup -fP disk_a.img
fi
if ! losetup -a | grep -q disk_b.img; then
    losetup -fP disk_b.img
fi
if ! losetup -a | grep -q disk_c.img; then
    losetup -fP disk_c.img
fi

# 2. LVM 활성화
vgchange -ay

# 3. fstab 마운트
mount -a

# 4. Docker 시작

# 5. 컨테이너 시작

# 상태 확인
echo "=== 디스크 상태 ==="
losetup -a
lvs
df -hT | grep -E "vg_|loop"
echo "=== 컨테이너 상태 ==="
