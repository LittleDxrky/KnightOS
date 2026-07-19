#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"
export COLOR_OUTPUT=false
KNIGHT_SHELL_ACTIVE=true

# Apply theme by copying to home (dialog reads ~/.dialogrc)
if [ "$THEME" = "light" ]; then
    cp "$BASE_DIR/core/lib/dialogrc.light" "$HOME/.dialogrc"
else
    cp "$BASE_DIR/core/lib/dialogrc.dark" "$HOME/.dialogrc"
fi

run_knight_cmd() {
    bash "$BASE_DIR/core/modules/$1.sh" "${@:2}" 2>&1 | sed "s/\x1b\[[0-9;]*m//g"
}

while true; do
    if command -v dialog >/dev/null; then
        CHOICE=$(dialog --clear --backtitle "KnightOS" --title "$(_ MSG_SHELL_MAIN_MENU)" --menu "$(_ MSG_SHELL_CHOOSE)" 18 60 8 \
            "1" "$(_ MSG_SHELL_DIAGNOSTICS)" \
            "2" "$(_ MSG_SHELL_PACKAGES)" \
            "3" "$(_ MSG_SHELL_BENCHMARK)" \
            "4" "$(_ MSG_SHELL_LOGS)" \
            "5" "$(_ MSG_SHELL_HELP)" \
            "6" "Language / Язык" \
            "7" "Theme / Тема" \
            "8" "$(_ MSG_SHELL_QUIT)" \
            2>&1 >/dev/tty)
    elif command -v whiptail >/dev/null; then
        CHOICE=$(whiptail --clear --backtitle "KnightOS" --title "$(_ MSG_SHELL_MAIN_MENU)" --menu "$(_ MSG_SHELL_CHOOSE)" 18 60 8 \
            "1" "$(_ MSG_SHELL_DIAGNOSTICS)" \
            "2" "$(_ MSG_SHELL_PACKAGES)" \
            "3" "$(_ MSG_SHELL_BENCHMARK)" \
            "4" "$(_ MSG_SHELL_LOGS)" \
            "5" "$(_ MSG_SHELL_HELP)" \
            "6" "Language / Язык" \
            "7" "Theme / Тема" \
            "8" "$(_ MSG_SHELL_QUIT)" \
            3>&1 1>&2 2>&3)
    else
        echo "Error: install dialog or whiptail."
        exit 1
    fi

    case "$CHOICE" in
        1) tmpfile=$(mktemp); run_knight_cmd doctor > "$tmpfile" 2>&1; dialog --textbox "$tmpfile" 20 70 2>/dev/null || whiptail --textbox "$tmpfile" 20 70; rm "$tmpfile" ;;
        2)
            while true; do
                if command -v dialog >/dev/null; then
                    PKG_CHOICE=$(dialog --clear --backtitle "KnightOS" --title "$(_ MSG_SHELL_PACKAGES)" --menu "$(_ MSG_SHELL_CHOOSE)" 15 50 5 \
                        "list" "$(_ MSG_SHELL_PKG_LIST)" \
                        "install" "$(_ MSG_SHELL_PKG_INSTALL)" \
                        "remove" "$(_ MSG_SHELL_PKG_REMOVE)" \
                        "info" "$(_ MSG_SHELL_PKG_INFO)" \
                        "back" "$(_ MSG_SHELL_BACK)" \
                        2>&1 >/dev/tty)
                else
                    PKG_CHOICE=$(whiptail --clear --backtitle "KnightOS" --title "$(_ MSG_SHELL_PACKAGES)" --menu "$(_ MSG_SHELL_CHOOSE)" 15 50 5 \
                        "list" "$(_ MSG_SHELL_PKG_LIST)" \
                        "install" "$(_ MSG_SHELL_PKG_INSTALL)" \
                        "remove" "$(_ MSG_SHELL_PKG_REMOVE)" \
                        "info" "$(_ MSG_SHELL_PKG_INFO)" \
                        "back" "$(_ MSG_SHELL_BACK)" \
                        3>&1 1>&2 2>&3)
                fi
                case "$PKG_CHOICE" in
                    list) tmpfile=$(mktemp); run_knight_cmd list > "$tmpfile"; dialog --textbox "$tmpfile" 20 70 2>/dev/null || whiptail --textbox "$tmpfile" 20 70; rm "$tmpfile" ;;
                    install)
                        pkglist=()
                        for d in "$BASE_DIR/packages/"*/; do
                            pkg=$(basename "$d")
                            ver=$(grep "^$pkg " "$BASE_DIR/var/installed.list" 2>/dev/null | awk '{print $2}')
                            [ -n "$ver" ] && desc="v$ver (installed)" || desc=$(grep -m1 "^DESCRIPTION=" "$d/package.conf" 2>/dev/null | cut -d= -f2-)
                            [ -z "$desc" ] && desc="No description"
                            pkglist+=("$pkg" "$desc" "OFF")
                        done
                        if [ ${#pkglist[@]} -gt 0 ]; then
                            if command -v dialog >/dev/null; then
                                selected=$(dialog --checklist "Select packages to install:" 20 70 10 "${pkglist[@]}" 2>&1 >/dev/tty)
                            else
                                selected=$(whiptail --checklist "Select packages to install:" 20 70 10 "${pkglist[@]}" 3>&1 1>&2 2>&3)
                            fi
                            for p in $selected; do run_knight_cmd install "$p" 2>&1 | dialog --progressbox 10 40 2>/dev/null || true; done
                        else
                            dialog --msgbox "No packages found." 6 40 2>/dev/null || whiptail --msgbox "No packages found." 6 40
                        fi
                        ;;
                    remove)
                        pkglist=()
                        while read -r line; do
                            pkg=$(echo "$line" | awk '{print $1}')
                            ver=$(echo "$line" | awk '{print $2}')
                            pkglist+=("$pkg" "v$ver" "OFF")
                        done < "$BASE_DIR/var/installed.list"
                        if [ ${#pkglist[@]} -gt 0 ]; then
                            if command -v dialog >/dev/null; then
                                selected=$(dialog --checklist "Select packages to remove:" 20 70 10 "${pkglist[@]}" 2>&1 >/dev/tty)
                            else
                                selected=$(whiptail --checklist "Select packages to remove:" 20 70 10 "${pkglist[@]}" 3>&1 1>&2 2>&3)
                            fi
                            for p in $selected; do run_knight_cmd remove "$p" 2>&1 | dialog --progressbox 10 40 2>/dev/null || true; done
                        else
                            dialog --msgbox "No installed packages." 6 40 2>/dev/null || whiptail --msgbox "No installed packages." 6 40
                        fi
                        ;;
                    info)
                        pkglist=()
                        for d in "$BASE_DIR/packages/"*/; do
                            pkg=$(basename "$d")
                            ver=$(grep "^$pkg " "$BASE_DIR/var/installed.list" 2>/dev/null | awk '{print $2}')
                            [ -n "$ver" ] && status="v$ver (installed)" || status="not installed"
                            desc=$(grep -m1 "^DESCRIPTION=" "$d/package.conf" 2>/dev/null | cut -d= -f2-)
                            [ -z "$desc" ] && desc="No description"
                            pkglist+=("$pkg $status - $desc")
                        done
                        if [ ${#pkglist[@]} -eq 0 ]; then
                            dialog --msgbox "No packages found." 6 40 2>/dev/null || whiptail --msgbox "No packages found." 6 40
                        else
                            if command -v fzf >/dev/null; then
                                pkgname=$(printf "%s\n" "${pkglist[@]}" | fzf --height 40% --reverse --prompt="Search package: " | awk '{print $1}')
                            else
                                echo "Available packages:"
                                for i in "${!pkglist[@]}"; do
                                    echo "$((i+1))) ${pkglist[$i]}"
                                done
                                echo -n "Enter number (or 0 to cancel): "
                                read -r num
                                if [ "$num" -gt 0 ] 2>/dev/null && [ "$num" -le "${#pkglist[@]}" ]; then
                                    pkgname=$(echo "${pkglist[$((num-1))]}" | awk '{print $1}')
                                else
                                    pkgname=""
                                fi
                            fi
                            if [ -n "$pkgname" ]; then
                                tmpfile=$(mktemp)
                                run_knight_cmd info "$pkgname" > "$tmpfile"
                                dialog --textbox "$tmpfile" 20 70 2>/dev/null || whiptail --textbox "$tmpfile" 20 70
                                rm "$tmpfile"
                            fi
                        fi
                        ;;
                    back) break ;;
                esac
            done
            ;;
        3)
            while true; do
                if command -v dialog >/dev/null; then
                    PERF_CHOICE=$(dialog --clear --backtitle "KnightOS" --title "$(_ MSG_SHELL_BENCHMARK)" --menu "$(_ MSG_SHELL_CHOOSE)" 15 50 5 \
                        "baseline" "$(_ MSG_SHELL_BASELINE)" \
                        "compare" "$(_ MSG_SHELL_COMPARE)" \
                        "history" "$(_ MSG_SHELL_HISTORY)" \
                        "show" "$(_ MSG_SHELL_SHOW_BASELINE)" \
                        "back" "$(_ MSG_SHELL_BACK)" \
                        2>&1 >/dev/tty)
                else
                    PERF_CHOICE=$(whiptail --clear --backtitle "KnightOS" --title "$(_ MSG_SHELL_BENCHMARK)" --menu "$(_ MSG_SHELL_CHOOSE)" 15 50 5 \
                        "baseline" "$(_ MSG_SHELL_BASELINE)" \
                        "compare" "$(_ MSG_SHELL_COMPARE)" \
                        "history" "$(_ MSG_SHELL_HISTORY)" \
                        "show" "$(_ MSG_SHELL_SHOW_BASELINE)" \
                        "back" "$(_ MSG_SHELL_BACK)" \
                        3>&1 1>&2 2>&3)
                fi
                case "$PERF_CHOICE" in
                    baseline|compare|show|history)
                        if command -v dialog >/dev/null; then
                            dialog --infobox "$(_ MSG_BENCHMARK_WAIT)" 5 40
                        else
                            whiptail --infobox "$(_ MSG_BENCHMARK_WAIT)" 5 40
                        fi
                        tmpfile=$(mktemp)
                        run_knight_cmd monitor "$PERF_CHOICE" > "$tmpfile" 2>&1
                        dialog --textbox "$tmpfile" 20 70 2>/dev/null || whiptail --textbox "$tmpfile" 20 70
                        rm "$tmpfile"
                        ;;
                    back) break ;;
                esac
            done
            ;;
        4) [ -f "$BASE_DIR/core/logs/knight.log" ] && { dialog --tailbox "$BASE_DIR/core/logs/knight.log" 20 70 2>/dev/null || whiptail --textbox "$BASE_DIR/core/logs/knight.log" 20 70; } || { dialog --msgbox "Log not found." 6 40 2>/dev/null || whiptail --msgbox "Log not found." 6 40; } ;;
        5) tmpfile=$(mktemp); run_knight_cmd help > "$tmpfile"; dialog --textbox "$tmpfile" 20 70 2>/dev/null || whiptail --textbox "$tmpfile" 20 70; rm "$tmpfile" ;;
        6)
            if command -v dialog >/dev/null; then
                LANG_CHOICE=$(dialog --clear --backtitle "KnightOS" --title "Language / Язык" --menu "Choose your language:" 12 40 2 \
                    "en" "English" \
                    "ru" "Русский" \
                    2>&1 >/dev/tty)
            else
                LANG_CHOICE=$(whiptail --clear --backtitle "KnightOS" --title "Language / Язык" --menu "Choose your language:" 12 40 2 \
                    "en" "English" \
                    "ru" "Русский" \
                    3>&1 1>&2 2>&3)
            fi
            if [ -n "$LANG_CHOICE" ]; then
                sed -i "s/^KNIGHT_LANG=.*/KNIGHT_LANG=$LANG_CHOICE/" "$BASE_DIR/knight.conf"
                exec "$BASE_DIR/knight" shell
            fi
            ;;
        7)
            CUR_THEME=$(grep '^THEME=' "$BASE_DIR/knight.conf" 2>/dev/null | cut -d= -f2)
            [ -z "$CUR_THEME" ] && CUR_THEME="dark"
            if [ "$CUR_THEME" = "dark" ]; then
                DARK_LABEL="Dark [*]"
                LIGHT_LABEL="Light"
            else
                DARK_LABEL="Dark"
                LIGHT_LABEL="Light [*]"
            fi
            if command -v dialog >/dev/null; then
                THEME_CHOICE=$(dialog --clear --backtitle "KnightOS" --title "Theme / Тема" --menu "Choose a theme:" 12 40 2 \
                    "dark" "$DARK_LABEL" \
                    "light" "$LIGHT_LABEL" \
                    2>&1 >/dev/tty)
            else
                THEME_CHOICE=$(whiptail --clear --backtitle "KnightOS" --title "Theme / Тема" --menu "Choose a theme:" 12 40 2 \
                    "dark" "$DARK_LABEL" \
                    "light" "$LIGHT_LABEL" \
                    3>&1 1>&2 2>&3)
            fi
            if [ -n "$THEME_CHOICE" ]; then
                sed -i "s/^THEME=.*/THEME=$THEME_CHOICE/" "$BASE_DIR/knight.conf"
                cp "$BASE_DIR/core/lib/dialogrc.$THEME_CHOICE" "$HOME/.dialogrc"
                exec "$BASE_DIR/knight" shell
            fi
            ;;
        8) clear; echo "Goodbye!"; exit 0 ;;
    esac
done
