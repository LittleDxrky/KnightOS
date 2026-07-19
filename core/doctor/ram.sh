#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

# Пытаемся получить свободную память (поддержка английской и русской локали)
RAM=$(free -h | awk '/^Mem:|^Память:/ {print $7}')
if [ -n "$RAM" ]; then
    ok "Free RAM" "$RAM"
else
    warn "Free RAM" "Could not determine"
fi
