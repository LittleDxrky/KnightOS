#!/bin/bash
echo "Applying kernel tuning..."
# Увеличиваем лимиты
sudo sysctl -w fs.file-max=100000
sudo sysctl -w fs.inotify.max_user_watches=524288
# Сетевые буферы
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
# Защита от атак
sudo sysctl -w kernel.kptr_restrict=2
sudo sysctl -w kernel.dmesg_restrict=1
sudo sysctl -w kernel.perf_event_paranoid=3
sudo sysctl -w net.ipv4.tcp_syncookies=1
echo "Kernel tuning applied."
