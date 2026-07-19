#!/bin/bash
CONFIG_FILE="$BASE_DIR/knight.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
