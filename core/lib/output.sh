#!/bin/bash

ok()   { echo -e "[ \033[0;32mOK\033[0m ] $*"; }
warn() { echo -e "[ \033[0;33mWARN\033[0m ] $*"; }
fail() { echo -e "[ \033[0;31mFAIL\033[0m ] $*"; }
info() { echo -e "[ \033[0;36mINFO\033[0m ] $*"; }
section() { echo -e "\n\033[1m========== $* ==========\033[0m"; }
