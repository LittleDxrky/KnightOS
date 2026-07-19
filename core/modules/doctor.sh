#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

section "Диагностика системы (KnightOS Doctor)"
echo

for check in "$BASE_DIR/core/doctor/"*.sh; do
    if [ -f "$check" ]; then
        source "$check"
    fi
done
