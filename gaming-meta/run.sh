#!/bin/bash
echo "Launching game mode optimizations..."
echo "gamemoded is running: $(systemctl is-active gamemoded)"
echo "NVIDIA power limit: $(nvidia-smi -q -d POWER | grep 'Power Limit' | head -1)"
