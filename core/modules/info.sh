#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

if [ $# -eq 0 ]; then
    bash "$BASE_DIR/scripts/system-info.sh"
    exit 0
fi

PKG="$1"
CONF="$BASE_DIR/packages/$PKG/package.conf"
if [ ! -f "$CONF" ]; then
    fail "Info" "Package '$PKG' not found"
    exit 1
fi

INSTALLED_LIST="$BASE_DIR/var/installed.list"
if installed=$(grep "^$PKG " "$INSTALLED_LIST" 2>/dev/null | awk '{print $2}'); then
    STATUS="${C_GREEN}installed ($installed)${C_RESET}"
else
    STATUS="not installed"
fi

section "Package info: $PKG"
echo -e "Status: $STATUS"
echo
while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    printf "  ${C_BOLD}%-12s${C_RESET} %s\n" "$key" "$value"
done < "$CONF"
