#!/bin/bash

source core/lib/output.sh

ROOT_USE=$(df / | awk 'NR==2 {print $5}')

ok "Root Usage" "$ROOT_USE"
