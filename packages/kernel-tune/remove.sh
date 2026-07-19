#!/bin/bash
echo "Reverting kernel tuning to defaults..."
sudo sysctl -w fs.file-max=4096
sudo sysctl -w fs.inotify.max_user_watches=8192
sudo sysctl -w net.core.rmem_max=212992
sudo sysctl -w net.core.wmem_max=212992
sudo sysctl -w kernel.kptr_restrict=1
sudo sysctl -w kernel.dmesg_restrict=0
sudo sysctl -w kernel.perf_event_paranoid=2
sudo sysctl -w net.ipv4.tcp_syncookies=0
echo "Kernel tuning reverted."
