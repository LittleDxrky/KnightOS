#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"

REMOTE_DIR="$BASE_DIR/var/remotes"
SOURCES_FILE="$REMOTE_DIR/sources.list"
mkdir -p "$REMOTE_DIR"

list_remotes() {
    if [ -d "$REMOTE_DIR" ] && [ "$(ls -A "$REMOTE_DIR")" ]; then
        for d in "$REMOTE_DIR"/*/; do
            name=$(basename "$d")
            url=$(git -C "$d" remote get-url origin 2>/dev/null || echo "unknown")
            printf "  %-15s %s\n" "$name" "$url"
            for pkg_dir in "$d"/*/; do
                if [ -f "$pkg_dir/package.conf" ]; then
                    pkg=$(basename "$pkg_dir")
                    desc=$(grep '^DESCRIPTION=' "$pkg_dir/package.conf" | cut -d= -f2-)
                    printf "    -> %-15s %s\n" "$pkg" "$desc"
                fi
            done
        done
    else
        info "No remote repositories added."
    fi
}

browse_sources() {
    if [ ! -f "$SOURCES_FILE" ]; then
        warn "Sources list not found. Creating default one..."
        cat > "$SOURCES_FILE" << 'INNEREOF'
mypackages|git@github.com:LittleDxrky/KnightOS.git|Gaming, desktop and custom tweaks by LittleDxrky
awesome-tweaks|https://github.com/awesome-linux/awesome-linux-tweaks.git|Community-driven collection of performance tweaks
auto-cpufreq|https://github.com/AdnanHodzic/auto-cpufreq.git|Automatic CPU speed & power optimizer for Linux
TLP|https://github.com/linrunner/TLP.git|Advanced power management for Linux
gamemode|https://github.com/FeralInteractive/gamemode.git|Optimise system performance on demand
undervolt|https://github.com/georgewhewell/undervolt.git|Intel/AMD CPU undervolting tool
mangohud|https://github.com/flightlessmango/Mangohud.git|Vulkan/OpenGL overlay for monitoring FPS, temperatures, etc.
zram-config|https://github.com/novaspirit/zram-config.git|Easy zram swap setup
INNEREOF
    fi

    section "Available Remote Repositories"
    echo
    local count=1
    while IFS='|' read -r name url desc; do
        [[ "$name" =~ ^#.*$ ]] && continue
        printf "%2d) %-20s %s\n" "$count" "$name" "$desc"
        printf "    URL: %s\n" "$url"
        ((count++))
    done < "$SOURCES_FILE"
    echo
    read -p "Enter number to add (or 0 to cancel): " num
    if [ "$num" -gt 0 ] 2>/dev/null; then
        local chosen=$(sed -n "${num}p" "$SOURCES_FILE" 2>/dev/null)
        if [ -n "$chosen" ]; then
            IFS='|' read -r name url desc <<< "$chosen"
            add_remote "$name" "$url"
        else
            fail "Invalid selection."
        fi
    fi
}

add_remote() {
    local name="$1"
    local url="$2"
    if [ -z "$name" ] || [ -z "$url" ]; then
        fail "Usage: ./knight remote add <name> <git-url>"
        exit 1
    fi
    local target="$REMOTE_DIR/$name"
    if [ -d "$target" ]; then
        fail "Remote '$name' already exists. Remove it first."
        exit 1
    fi

    info "Cloning $url into $target..."
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$url" "$target" 2>&1
    if [ $? -eq 0 ]; then
        ok "Remote added successfully."
    else
        fail "Failed to clone repository."
        echo "If the repository is private, use a personal access token:"
        echo "  git clone https://TOKEN@github.com/user/repo.git"
        echo "Or configure SSH: git@github.com:user/repo.git"
        exit 1
    fi

    for pkg_dir in "$target"/*/; do
        if [ -f "$pkg_dir/package.conf" ]; then
            pkg=$(basename "$pkg_dir")
            desc=$(grep '^DESCRIPTION=' "$pkg_dir/package.conf" | cut -d= -f2-)
            printf "  -> %-15s %s\n" "$pkg" "$desc"
        fi
    done
}

remove_remote() {
    local name="$1"
    if [ -z "$name" ]; then
        fail "Usage: ./knight remote remove <name>"
        exit 1
    fi
    local target="$REMOTE_DIR/$name"
    if [ ! -d "$target" ]; then
        fail "Remote '$name' not found."
        exit 1
    fi
    rm -rf "$target"
    ok "Remote '$name' removed."
}

update_remote() {
    local name="$1"
    if [ -z "$name" ]; then
        for d in "$REMOTE_DIR"/*/; do
            name=$(basename "$d")
            info "Updating $name..."
            GIT_TERMINAL_PROMPT=0 git -C "$d" pull --ff-only 2>&1
        done
    else
        local target="$REMOTE_DIR/$name"
        if [ ! -d "$target" ]; then
            fail "Remote '$name' not found."
            exit 1
        fi
        info "Updating $name..."
        GIT_TERMINAL_PROMPT=0 git -C "$target" pull --ff-only 2>&1
        ok "Remote '$name' updated."
    fi
}

case "${1:-}" in
    list)       list_remotes ;;
    browse)     browse_sources ;;
    add)        add_remote "$2" "$3" ;;
    remove)     remove_remote "$2" ;;
    update)     update_remote "$2" ;;
    *)          echo "Usage: ./knight remote {list|browse|add|remove|update}" ;;
esac
