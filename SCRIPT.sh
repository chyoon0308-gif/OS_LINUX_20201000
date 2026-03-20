#!/bin/bash
if [ "$EUID" -eq 0 ]; then
    return 0 2>/dev/null || exit 0
fi
BASE_DIR="$HOME/linux"
mkdir -p "$BASE_DIR"
TODAY=$(date +%Y-%m-%d)
LOG_DIR="$BASE_DIR/$TODAY"
LOG_FILE="$LOG_DIR/${USER}_${TODAY}_session.log"
TIME_FILE="$LOG_DIR/${USER}_${TODAY}_session.tm"
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi
cd "$LOG_DIR" || exit
if [ -z "$UNDER_SCRIPT" ]; then
    export UNDER_SCRIPT=1
    # 맥(macOS) script 명령어 문법에 맞게 수정
    script -a "$LOG_FILE"
    exit
fi
