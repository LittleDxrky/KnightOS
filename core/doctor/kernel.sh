#!/bin/bash
# Проверка ядра

KERNEL=$(uname -r)
printf "Текущее ядро: %s\n" "$KERNEL"
if grep -q "LTS" /etc/os-release 2>/dev/null; then
    info "Рекомендуется использовать LTS-ядро для стабильности"
fi
