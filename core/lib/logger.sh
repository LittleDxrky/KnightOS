#!/bin/bash
LOG_DIR="$BASE_DIR/core/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/knight.log"

log_info()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" >> "$LOG_FILE"; }
log_warn()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >> "$LOG_FILE"; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >> "$LOG_FILE"; }
