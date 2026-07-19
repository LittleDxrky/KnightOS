#!/bin/bash
echo "Disabling zram..."
sudo systemctl stop zram-config 2>/dev/null
sudo systemctl disable zram-config 2>/dev/null
sudo swapoff /dev/zram0 2>/dev/null
sudo modprobe -r zram 2>/dev/null
echo "zram disabled."
