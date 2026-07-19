#!/bin/bash
# Вернуть governor=powersave
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee "$cpu" > /dev/null 2>&1
done
echo "CPU governor возвращён в powersave"
