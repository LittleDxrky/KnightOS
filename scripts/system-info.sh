#!/bin/bash

echo "KnightOS"

echo

echo "CPU:"
lscpu | grep "Имя модели"

echo

echo "RAM:"
free -h

echo

echo "GPU:"
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader

echo

echo "Kernel:"
uname -r
