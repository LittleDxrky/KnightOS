#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"
NEW_LANG="${1:-}"
if [ -z "$NEW_LANG" ]; then
    info "Current language: ${KNIGHT_LANG:-en}"
    info "Available: en, ru"
    exit 0
fi
if [ "$NEW_LANG" != "en" ] && [ "$NEW_LANG" != "ru" ]; then
    fail "Language" "Unsupported language: $NEW_LANG. Use en or ru."
    exit 1
fi
sed -i "s/^KNIGHT_LANG=.*/KNIGHT_LANG=$NEW_LANG/" "$BASE_DIR/knight.conf"
ok "Language" "Changed to $NEW_LANG. Restart shell to apply."
if [ "$KNIGHT_SHELL_ACTIVE" = "true" ]; then
    exec "$BASE_DIR/knight" shell
fi
