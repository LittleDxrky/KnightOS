#!/bin/bash
if command -v nvidia-smi &>/dev/null; then
    echo "Optimizing NVIDIA GPU..."
    sudo nvidia-persistenced --user nvidia-persistenced 2>/dev/null || true
    sudo nvidia-smi -pm 1
    # Установим максимальный Power Limit, если он снижен
    MAX_POWER=$(nvidia-smi -q -d POWER | grep "Max Power Limit" | awk -F: '{print $2}' | xargs | cut -d. -f1)
    if [ -n "$MAX_POWER" ]; then
        sudo nvidia-smi -pl $MAX_POWER
    fi
    # Разрешим разгон (Coolbits) – аккуратно, без вреда
    sudo nvidia-xconfig --cool-bits=12 2>/dev/null || true
    echo "NVIDIA optimizations applied."
else
    echo "NVIDIA GPU not found, skipping."
fi
