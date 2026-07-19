#!/bin/bash
echo "Reverting SSD optimizations..."
sudo systemctl disable fstrim.timer --now 2>/dev/null
# Убрать noatime/discard из fstab
sudo sed -i 's/,noatime//g; s/,discard//g' /etc/fstab
echo "SSD optimizations reverted."
