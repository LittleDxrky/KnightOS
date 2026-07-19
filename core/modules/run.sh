#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

PKG="$1"
if [ -z "$PKG" ]; then
    fail "Run" "Package not specified"
    exit 1
fi

# Ищем run.sh в пакете (локально и в ремоутах)
for base in "$BASE_DIR/packages" "$BASE_DIR/var/remotes"/*; do
    script="$base/$PKG/run.sh"
    if [ -f "$script" ]; then
        info "Running $PKG..."
        bash "$script" "${@:2}"
        exit $?
    fi
done

fail "Run" "No run.sh found for package '$PKG'"
exit 1
