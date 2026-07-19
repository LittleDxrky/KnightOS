#!/bin/bash
if command -v mokutil &>/dev/null; then
    SB_STATE=$(mokutil --sb-state 2>/dev/null)
    if echo "$SB_STATE" | grep -q "SecureBoot enabled"; then
        warn "Secure Boot включён. Это может мешать загрузке неподписанных модулей (например, NVIDIA)."
        info "Если драйвер NVIDIA не загружается, выполните:"
        info "  1) sudo mokutil --disable-validation (временно)"
        info "  2) или переустановите драйвер с DKMS: sudo apt reinstall nvidia-driver-580"
    else
        ok "Secure Boot отключён или не активен"
    fi
else
    info "mokutil не установлен, невозможно проверить Secure Boot"
fi
