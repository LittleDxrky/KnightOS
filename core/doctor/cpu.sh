#!/bin/bash
DRIVER=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null)
GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
printf "CPU driver:    %s\n" "$DRIVER"
printf "CPU governor:  %s\n" "$GOVERNOR"
if [ "$DRIVER" = "intel_pstate" ] && [ "$GOVERNOR" = "powersave" ]; then
    warn "Рекомендация: для повышения производительности установите пакет cpu-performance"
    info "Выполните: ./knight install cpu-performance"
fi
