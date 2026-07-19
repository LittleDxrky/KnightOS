#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

URL="${1:-}"
if [ -z "$URL" ]; then
    fail "Usage: ./knight parse <git-url>"
    exit 1
fi

TMP_DIR=$(mktemp -d /tmp/knight-parse-XXXXXX)
info "Cloning $URL into $TMP_DIR..."
GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$URL" "$TMP_DIR" 2>&1
if [ $? -ne 0 ]; then
    fail "Failed to clone repository."
    rm -rf "$TMP_DIR"
    exit 1
fi

info "Scanning for packages..."
PACKAGES=()
# Ищем package.conf или install.sh
while IFS= read -r -d '' conf; do
    pkg_dir=$(dirname "$conf")
    pkg_name=$(basename "$pkg_dir")
    # Пропускаем корень репозитория, если файл лежит прямо там (это не пакет)
    if [ "$pkg_dir" != "$TMP_DIR" ]; then
        PACKAGES+=("$pkg_name:$pkg_dir")
        desc=$(grep -m1 '^DESCRIPTION=' "$conf" 2>/dev/null | cut -d= -f2-)
        [ -z "$desc" ] && desc="(no description)"
        printf "  %-20s %s\n" "$pkg_name" "$desc"
    fi
done < <(find "$TMP_DIR" -name 'package.conf' -print0)

# Также учитываем папки без package.conf, но с install.sh
while IFS= read -r -d '' install; do
    pkg_dir=$(dirname "$install")
    pkg_name=$(basename "$pkg_dir")
    if [ "$pkg_dir" != "$TMP_DIR" ] && [ ! -f "$pkg_dir/package.conf" ]; then
        PACKAGES+=("$pkg_name:$pkg_dir")
        printf "  %-20s (no package.conf)\n" "$pkg_name"
    fi
done < <(find "$TMP_DIR" -name 'install.sh' -print0)

if [ ${#PACKAGES[@]} -eq 0 ]; then
    warn "No installable packages found in this repository."
    rm -rf "$TMP_DIR"
    exit 0
fi

echo
read -p "Enter package names to install (space-separated, 'all' for all, 'q' to quit): " choice
if [ "$choice" = "q" ]; then
    info "Aborted."
    rm -rf "$TMP_DIR"
    exit 0
fi

install_pkg() {
    local name="$1" dir="$2"
    # Если пакет уже есть локально или в ремоутах – используем стандартную установку
    if [ -f "$BASE_DIR/packages/$name/install.sh" ] || grep -q "/$name/" <<<"$(ls -d "$BASE_DIR/var/remotes"/*/"$name" 2>/dev/null)"; then
        info "Package '$name' already exists in local/remote sources. Installing via standard method..."
        bash "$BASE_DIR/core/modules/install.sh" "$name"
    else
        # Временно добавляем как локальный пакет, чтобы использовать install.sh с проверками
        mkdir -p "$BASE_DIR/packages/$name"
        cp -r "$dir"/* "$BASE_DIR/packages/$name/"
        bash "$BASE_DIR/core/modules/install.sh" "$name"
        # После установки удаляем временную копию (пакет уже в var/installed.list)
        rm -rf "$BASE_DIR/packages/$name"
    fi
}

if [ "$choice" = "all" ]; then
    for entry in "${PACKAGES[@]}"; do
        IFS=':' read -r name dir <<< "$entry"
        install_pkg "$name" "$dir"
    done
else
    for name in $choice; do
        found=false
        for entry in "${PACKAGES[@]}"; do
            IFS=':' read -r pname pdir <<< "$entry"
            if [ "$pname" = "$name" ]; then
                found=true
                install_pkg "$name" "$pdir"
                break
            fi
        done
        if ! $found; then
            warn "Package '$name' not found in scanned repository."
        fi
    done
fi

rm -rf "$TMP_DIR"
