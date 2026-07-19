#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

JSON_MODE=false
if [ "$1" = "--json" ]; then
    JSON_MODE=true
    shift
fi

PKG="$1"
if [ -z "$PKG" ]; then
    if $JSON_MODE; then
        echo '{"status":"error","message":"Package not specified"}'
    else
        fail "install" "Укажите имя пакета"
    fi
    exit 1
fi

INSTALLED_LIST="$BASE_DIR/var/installed.list"
INSTALLING_FILE="$BASE_DIR/var/.installing"
mkdir -p "$BASE_DIR/var"
touch "$INSTALLING_FILE"

# Проверка циклической зависимости
if grep -qxF "$PKG" "$INSTALLING_FILE"; then
    if $JSON_MODE; then
        echo "{\"status\":\"error\",\"message\":\"Cyclic dependency detected for $PKG\"}"
    else
        fail "Cyclic dependency" "Package '$PKG' is already being installed – cycle detected!"
    fi
    exit 1
fi
echo "$PKG" >> "$INSTALLING_FILE"

PKG_DIR=""
SCRIPT=""
for dir in "$BASE_DIR/packages/$PKG" "$BASE_DIR/var/remotes"/*/"$PKG"; do
    if [[ -f "$dir/install.sh" ]]; then
        PKG_DIR="$dir"
        SCRIPT="$PKG_DIR/install.sh"
        break
    fi
done

if [[ ! -f "$SCRIPT" ]]; then
    sed -i "/^$PKG$/d" "$INSTALLING_FILE" 2>/dev/null
    if $JSON_MODE; then
        echo "{\"status\":\"error\",\"message\":\"Package '$PKG' not found\"}"
    else
        fail "Install" "Package '$PKG' not found"
    fi
    exit 1
fi

CONF="$PKG_DIR/package.conf"

# Конфликты
if [[ -f "$CONF" ]]; then
    CONFLICTS=$(grep -E '^CONFLICTS=' "$CONF" 2>/dev/null | cut -d= -f2-)
    for conflict in $CONFLICTS; do
        if grep -q "^$conflict " "$INSTALLED_LIST" 2>/dev/null; then
            sed -i "/^$PKG$/d" "$INSTALLING_FILE" 2>/dev/null
            if $JSON_MODE; then
                echo "{\"status\":\"error\",\"message\":\"Package '$PKG' conflicts with installed '$conflict'\"}"
            else
                fail "Conflict" "Package '$PKG' conflicts with installed '$conflict'"
            fi
            exit 1
        fi
    done
fi

# Системные требования
check_req() {
    local key="$1" value="$2"
    case "$key" in
        REQUIRES_GPU)
            [[ "$value" == "nvidia" ]] && ! command -v nvidia-smi &>/dev/null && {
                if $JSON_MODE; then
                    echo '{"status":"error","message":"NVIDIA GPU required but not detected"}'
                else
                    fail "Requirement" "NVIDIA GPU not detected. Package may not work."
                fi
                exit 1
            }
            ;;
        REQUIRES_KERNEL_MIN)
            local cur_ver=$(uname -r | cut -d- -f1)
            printf '%s\n%s\n' "$value" "$cur_ver" | sort -V -C 2>/dev/null || {
                if $JSON_MODE; then
                    echo "{\"status\":\"error\",\"message\":\"Kernel >= $value required (current: $cur_ver)\"}"
                else
                    fail "Requirement" "Kernel >= $value required (current: $cur_ver)"
                fi
                exit 1
            }
            ;;
        REQUIRES_DISTRO)
            local cur_distro=$(lsb_release -si 2>/dev/null || grep '^ID=' /etc/os-release | cut -d= -f2)
            local matched=false
            IFS=',' read -ra distros <<< "$value"
            for d in "${distros[@]}"; do
                [[ "${cur_distro,,}" == *"${d,,}"* ]] && matched=true && break
            done
            $matched || {
                if $JSON_MODE; then
                    echo "{\"status\":\"error\",\"message\":\"Distro must be one of: $value (current: $cur_distro)\"}"
                else
                    fail "Requirement" "Distro must be one of: $value (current: $cur_distro)"
                fi
                exit 1
            }
            ;;
    esac
}
if [[ -f "$CONF" ]]; then
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^REQUIRES_ ]] && check_req "$key" "$value"
    done < "$CONF"
fi

# Зависимости
if [[ -f "$CONF" ]]; then
    DEPS=$(grep -E '^DEPENDS=' "$CONF" 2>/dev/null | cut -d= -f2-)
    for dep in $DEPS; do
        if grep -q "^$dep " "$INSTALLED_LIST" 2>/dev/null; then
            $JSON_MODE || ok "Dependency" "'$dep' already installed"
        else
            $JSON_MODE || info "Installing dependency: $dep"
            bash "$0" "$dep" || {
                sed -i "/^$PKG$/d" "$INSTALLING_FILE" 2>/dev/null
                if $JSON_MODE; then
                    echo "{\"status\":\"error\",\"message\":\"Failed to install dependency '$dep'\"}"
                else
                    fail "Dependency" "Failed to install '$dep'"
                fi
                exit 1
            }
        fi
    done
fi

# Установка
PKG_VER=$(grep '^VERSION=' "$CONF" 2>/dev/null | cut -d= -f2-)
[[ -z "$PKG_VER" ]] && PKG_VER="unknown"

if [[ -n "$KNIGHT_SUDO_PASS" ]]; then
    echo "$KNIGHT_SUDO_PASS" | sudo -S bash "$SCRIPT"
else
    bash "$SCRIPT"
fi

if [[ $? -eq 0 ]]; then
    mkdir -p "$BASE_DIR/var"
    sed -i "/^$PKG /d" "$INSTALLED_LIST" 2>/dev/null
    echo "$PKG $PKG_VER" >> "$INSTALLED_LIST"
    sort -u -o "$INSTALLED_LIST" "$INSTALLED_LIST"
    sed -i "/^$PKG$/d" "$INSTALLING_FILE" 2>/dev/null
    if $JSON_MODE; then
        echo "{\"status\":\"ok\",\"message\":\"Package '$PKG' v$PKG_VER installed\",\"package\":\"$PKG\",\"version\":\"$PKG_VER\"}"
    else
        ok "Install" "Package '$PKG' v$PKG_VER installed"
    fi
else
    sed -i "/^$PKG$/d" "$INSTALLING_FILE" 2>/dev/null
    if $JSON_MODE; then
        echo "{\"status\":\"error\",\"message\":\"Installation failed for '$PKG'\"}"
    else
        fail "Install" "Package '$PKG' failed"
    fi
fi
