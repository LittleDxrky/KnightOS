#!/bin/bash
if command -v nvidia-smi &>/dev/null; then
    if ! nvidia-smi &>/dev/null; then
        warn "NVIDIA драйвер установлен, но не может связаться с GPU."
        # Проверяем Secure Boot
        if mokutil --sb-state 2>/dev/null | grep -q enabled; then
            warn "Причина: Secure Boot блокирует неподписанный модуль nvidia."
            info "Решение: sudo mokutil --disable-validation (с перезагрузкой) или переустановите драйвер с DKMS."
        else
            warn "Попробуйте загрузить модуль вручную: sudo modprobe nvidia"
        fi
    else
        nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
        ok "NVIDIA драйвер работает"
    fi
else
    info "NVIDIA драйвер не установлен (или используется другая GPU)"
fi
