#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

INSTALLED_LIST="$BASE_DIR/var/installed.list"
PACKAGES_DIR="$BASE_DIR/packages"

echo "Доступные пакеты:"
echo ""
declare -a pkg_names
i=1
for pkg_dir in "$PACKAGES_DIR"/*/; do
    pkg=$(basename "$pkg_dir")
    desc=""
    [ -f "$pkg_dir/package.conf" ] && desc=$(grep '^DESCRIPTION=' "$pkg_dir/package.conf" | cut -d= -f2-)
    installed=""
    if grep -qxF "$pkg" "$INSTALLED_LIST" 2>/dev/null; then
        installed="[установлен]"
    fi
    printf "%2d. %-20s %s %s\n" "$i" "$pkg" "$desc" "$installed"
    pkg_names[$i]="$pkg"
    ((i++))
done

[ $i -eq 1 ] && { info "Пакеты не найдены."; exit 0; }

echo ""
read -p "Введите номер пакета (0 для выхода): " num
if [ "$num" -eq 0 ] 2>/dev/null || [ -z "$num" ]; then
    exit 0
fi

pkg="${pkg_names[$num]}"
if [ -z "$pkg" ]; then
    fail "list" "Неверный номер"
    exit 1
fi

if grep -qxF "$pkg" "$INSTALLED_LIST" 2>/dev/null; then
    echo "Пакет '$pkg' уже установлен."
    read -p "Удалить? (y/N): " ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
        bash "$BASE_DIR/core/modules/remove.sh" "$pkg"
    fi
else
    echo "Пакет '$pkg' не установлен."
    read -p "Установить? (y/N): " ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
        bash "$BASE_DIR/core/modules/install.sh" "$pkg"
    fi
fi
