#!/bin/bash
echo "Applying security hardening..."
sudo sysctl -w kernel.randomize_va_space=2
sudo sysctl -w kernel.kptr_restrict=2
sudo sysctl -w kernel.dmesg_restrict=1
sudo sysctl -w kernel.perf_event_paranoid=3
sudo sysctl -w kernel.yama.ptrace_scope=1
sudo sysctl -w net.ipv4.tcp_syncookies=1
# Включить защиту от маршрутизации исходных пакетов
sudo sysctl -w net.ipv4.conf.all.accept_source_route=0
echo "Security hardening applied."
