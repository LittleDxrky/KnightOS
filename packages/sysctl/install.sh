#!/bin/bash
echo "Применяю оптимальные значения sysctl..."
sudo sysctl -w vm.swappiness=10
sudo sysctl -w vm.vfs_cache_pressure=50
