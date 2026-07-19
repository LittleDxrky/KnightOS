#!/bin/bash
echo "Возврат sysctl к значениям по умолчанию..."
sudo sysctl -w vm.swappiness=60
sudo sysctl -w vm.vfs_cache_pressure=100
