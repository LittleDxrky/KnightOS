#!/bin/bash
section "Диски"
df -h /
echo

if command -v smartctl &>/dev/null; then
    echo "SMART-информация о /dev/sda:"
    if [ -n "$KNIGHT_SUDO_PASS" ]; then
        echo "$KNIGHT_SUDO_PASS" | sudo -S smartctl -H /dev/sda 2>/dev/null
    else
        sudo smartctl -H /dev/sda 2>/dev/null || echo "Требуется sudo"
    fi
fi
