#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

PKG="$1"
if [ -z "$PKG" ]; then
    fail "remove" "Укажите имя пакета"
    exit 1
fi

SCRIPT="$BASE_DIR/packages/$PKG/remove.sh"
if [ -f "$SCRIPT" ]; then
    info "Удаляю $PKG..."
    bash "$SCRIPT"
    if [ $? -eq 0 ]; then
        ok "$PKG удалён"
    else
        fail "Ошибка удаления $PKG"
    fi
else
    fail "Пакет '$PKG' не найден"
    exit 1
fi
