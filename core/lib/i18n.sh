#!/bin/bash
# Загрузка локализации
if [ -z "$KNIGHT_LANG" ]; then
    KNIGHT_LANG="en"
fi
LOCALE_FILE="$BASE_DIR/core/locale/${KNIGHT_LANG}.conf"
if [ -f "$LOCALE_FILE" ]; then
    source "$LOCALE_FILE"
else
    source "$BASE_DIR/core/locale/en.conf"
fi

# Функция перевода: _ "ключ" -> значение
_() {
    local key="$1"
    echo "${!key:-$key}"
}
