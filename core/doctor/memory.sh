#!/bin/bash
# Проверка параметров памяти

SWAPPINESS=$(cat /proc/sys/vm/swappiness)
CACHE_PRESSURE=$(cat /proc/sys/vm/vfs_cache_pressure)
FREE=$(free -h | awk '/^Mem:/ {print $7}')

printf "Swappiness:        %s (рекомендуется <=10)\n" "$SWAPPINESS"
printf "Cache pressure:    %s (рекомендуется 50)\n" "$CACHE_PRESSURE"
printf "Свободная память:  %s\n" "$FREE"

if [ "$SWAPPINESS" -gt 10 ]; then
    info "Рекомендация: уменьшить swappiness (установите пакет sysctl)"
fi
if [ "$CACHE_PRESSURE" -ne 50 ]; then
    info "Рекомендация: установить vfs_cache_pressure=50"
fi
