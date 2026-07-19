#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

section "Проверка и применение стандартных исправлений"

NEW_FIXES=0

run_cmd() {
    if [ -n "$KNIGHT_SUDO_PASS" ]; then
        echo "$KNIGHT_SUDO_PASS" | sudo -S bash -c "$1"
    else
        bash -c "$1"
    fi
}

# 1. TCP BBR
CURRENT_CC=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
if [ "$CURRENT_CC" != "bbr" ]; then
    info "Включение TCP BBR (сейчас: $CURRENT_CC)..."
    run_cmd "sysctl -w net.ipv4.tcp_congestion_control=bbr" && { ok "TCP BBR включён"; ((NEW_FIXES++)); } || fail "Ошибка включения BBR"
else
    ok "TCP BBR уже активен"
fi

# 2. Сетевые буферы
RMAX=$(sysctl -n net.core.rmem_max 2>/dev/null)
WMAX=$(sysctl -n net.core.wmem_max 2>/dev/null)
if [ "$RMAX" -lt 16777216 ] || [ "$WMAX" -lt 16777216 ]; then
    info "Увеличение сетевых буферов..."
    run_cmd "sysctl -w net.core.rmem_max=16777216" || fail "Ошибка rmem_max"
    run_cmd "sysctl -w net.core.wmem_max=16777216" || fail "Ошибка wmem_max"
    if [ $? -eq 0 ]; then
        ok "Сетевые буферы увеличены"
        ((NEW_FIXES++))
    fi
else
    ok "Сетевые буферы уже оптимальны"
fi

# 3. Лимит inotify
INOTIFY=$(sysctl -n fs.inotify.max_user_watches 2>/dev/null)
if [ "$INOTIFY" -lt 524288 ]; then
    info "Увеличение лимита inotify..."
    run_cmd "sysctl -w fs.inotify.max_user_watches=524288" && { ok "Лимит inotify увеличен"; ((NEW_FIXES++)); } || fail "Ошибка inotify"
else
    ok "Лимит inotify уже достаточен"
fi

# 4. fstrim.timer
if systemctl is-enabled fstrim.timer 2>/dev/null | grep -q enabled; then
    ok "fstrim.timer уже активен"
else
    info "Включение fstrim.timer..."
    run_cmd "systemctl enable fstrim.timer --now" && { ok "fstrim.timer включён"; ((NEW_FIXES++)); } || warn "Не удалось включить fstrim.timer"
fi

# 5. Проверка загрузки NVIDIA
info "Проверка загрузки NVIDIA..."
if command -v nvidia-smi &>/dev/null && ! nvidia-smi &>/dev/null; then
    if mokutil --sb-state 2>/dev/null | grep -q enabled; then
        warn "Secure Boot мешает. Пропускаем автоматическое включение."
    else
        run_cmd "modprobe nvidia" 2>/dev/null && { ok "Модуль nvidia загружен"; ((NEW_FIXES++)); } || warn "Не удалось загрузить nvidia"
    fi
else
    ok "NVIDIA уже работает или не используется"
fi

echo ""
if [ $NEW_FIXES -gt 0 ]; then
    ok "Применено новых исправлений: $NEW_FIXES"
else
    info "Все рекомендуемые настройки уже применены."
fi

section "Готово."
