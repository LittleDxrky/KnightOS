#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

PKG="$1"
if [ -z "$PKG" ]; then
    fail "status" "Укажите имя пакета"
    exit 1
fi

INSTALLED_LIST="$BASE_DIR/var/installed.list"
if grep -q "^$PKG " "$INSTALLED_LIST" 2>/dev/null; then
    version=$(grep "^$PKG " "$INSTALLED_LIST" | awk '{print $2}')
    ok "Пакет '$PKG' установлен (версия $version)"
else
    warn "Пакет '$PKG' не установлен"
fi

# Дополнительная проверка состояния (если есть run.sh, можно вызвать с ключом --status)
SCRIPT="$BASE_DIR/packages/$PKG/run.sh"
if [ -f "$SCRIPT" ]; then
    info "Запустите './knight run $PKG' для взаимодействия с пакетом"
fi
