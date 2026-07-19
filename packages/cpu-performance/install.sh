#!/bin/bash
# Установить governor=performance для всех ядер
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee "$cpu" > /dev/null 2>&1
done
echo "CPU governor переключён в performance"
