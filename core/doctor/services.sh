#!/bin/bash
# Проверка ненужных служб

section "Ненужные службы"
SERVICES=(
    bluetooth.service
    gpu-manager.service
    plymouth-quit-wait.service
    snapd.service
)

for svc in "${SERVICES[@]}"; do
    if systemctl is-enabled "$svc" 2>/dev/null | grep -q enabled; then
        printf "  %s: \033[0;33mвключена\033[0m\n" "$svc"
    else
        printf "  %s: отключена\n" "$svc"
    fi
done
