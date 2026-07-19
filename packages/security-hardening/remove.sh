#!/bin/bash
echo "Reverting security hardening..."
sudo sysctl -w kernel.randomize_va_space=0
sudo sysctl -w kernel.kptr_restrict=1
sudo sysctl -w kernel.dmesg_restrict=0
sudo sysctl -w kernel.perf_event_paranoid=2
sudo sysctl -w kernel.yama.ptrace_scope=0
sudo sysctl -w net.ipv4.tcp_syncookies=0
sudo sysctl -w net.ipv4.conf.all.accept_source_route=1
echo "Security hardening reverted."
