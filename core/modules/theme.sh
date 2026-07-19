#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"
NEW_THEME="${1:-}"
if [ -z "$NEW_THEME" ]; then
    info "Current theme: ${THEME:-dark}"
    info "Available: dark, light"
    exit 0
fi
if [ "$NEW_THEME" != "dark" ] && [ "$NEW_THEME" != "light" ]; then
    fail "Theme" "Unsupported theme: $NEW_THEME. Use dark or light."
    exit 1
fi
sed -i "s/^THEME=.*/THEME=$NEW_THEME/" "$BASE_DIR/knight.conf"
# Apply theme immediately if in shell
if [ -n "$KNIGHT_SHELL_ACTIVE" ]; then
    cp "$BASE_DIR/core/lib/dialogrc.$NEW_THEME" "$HOME/.dialogrc"
fi
ok "Theme" "Changed to $NEW_THEME. Restart shell to apply fully."
