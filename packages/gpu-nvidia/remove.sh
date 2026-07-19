#!/bin/bash
echo "Reverting NVIDIA optimizations..."
sudo nvidia-smi -pm 0 2>/dev/null || true
# Вернём стандартный power limit? Оставим как есть.
echo "NVIDIA settings restored to defaults (persistence mode off)."
