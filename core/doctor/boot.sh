#!/bin/bash
# Анализ загрузки системы

section "Анализ загрузки"
if command -v systemd-analyze &>/dev/null; then
    systemd-analyze
    echo
    echo "Самые медленные сервисы:"
    systemd-analyze blame | head -5
else
    warn "systemd-analyze не установлен"
fi
