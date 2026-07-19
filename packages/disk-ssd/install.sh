#!/bin/bash
echo "Optimizing SSD parameters..."
# Включить trim (если поддерживается)
sudo systemctl enable fstrim.timer --now 2>/dev/null
# Применить noatime к корневому разделу в fstab (осторожно)
if grep -q " / " /etc/fstab && ! grep "noatime" /etc/fstab; then
    sudo sed -i 's/\(\/dev\/\S*\s*\/\s*\S*\s*\)defaults/\1defaults,noatime,discard/' /etc/fstab
    echo "Added noatime and discard to root mount options. Remount to apply."
fi
# Установить планировщик mq-deadline для SSD
for disk in /sys/block/sd* /sys/block/nvme*; do
    if [ -f "$disk/queue/scheduler" ]; then
        echo mq-deadline | sudo tee "$disk/queue/scheduler" >/dev/null
    fi
done
echo "SSD optimizations applied."
