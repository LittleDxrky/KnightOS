#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

INSTALLED_LIST="$BASE_DIR/var/installed.list"
UPDATED=0

update_pkg() {
    local pkg="$1"
    local installed_ver="$2"
    local conf="$BASE_DIR/packages/$pkg/package.conf"
    
    if [ ! -f "$conf" ]; then
        warn "Update" "Package $pkg: package.conf not found, skipping"
        return 1
    fi
    
    local available_ver=$(grep -E '^VERSION=' "$conf" 2>/dev/null | cut -d= -f2-)
    if [ -z "$available_ver" ]; then
        warn "Update" "Package $pkg: no VERSION in package.conf"
        return 1
    fi
    
    if [ "$installed_ver" != "$available_ver" ]; then
        info "Updating $pkg from v$installed_ver to v$available_ver..."
        bash "$BASE_DIR/core/modules/install.sh" "$pkg"
        if [ $? -eq 0 ]; then
            ok "Update" "$pkg updated to v$available_ver"
            UPDATED=1
        else
            fail "Update" "$pkg failed"
        fi
    else
        ok "Update" "$pkg is up-to-date (v$installed_ver)"
    fi
}

if [ $# -eq 0 ]; then
    # Обновить все установленные пакеты
    if [ ! -f "$INSTALLED_LIST" ] || [ ! -s "$INSTALLED_LIST" ]; then
        info "No packages installed."
        exit 0
    fi
    while IFS=" " read -r pkg ver; do
        update_pkg "$pkg" "$ver"
    done < "$INSTALLED_LIST"
else
    # Обновить указанный пакет
    PKG="$1"
    installed_ver=$(grep "^$PKG " "$INSTALLED_LIST" 2>/dev/null | awk "{print \$2}")
    if [ -z "$installed_ver" ]; then
        fail "Update" "Package $PKG is not installed"
        exit 1
    fi
    update_pkg "$PKG" "$installed_ver"
fi

if [ "$UPDATED" -eq 1 ]; then
    info "Run ./knight list to see updated packages."
fi
