#!/bin/bash
echo "Setting up zram..."
sudo apt update && sudo apt install zram-config -y || true
sudo systemctl enable zram-config --now 2>/dev/null || true
# Если пакет не установился, активируем вручную
if ! systemctl is-active --quiet zram-config; then
    sudo modprobe zram
    echo 4G | sudo tee /sys/block/zram0/disksize
    sudo mkswap /dev/zram0
    sudo swapon /dev/zram0
fi
echo "zram enabled."
