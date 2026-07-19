#!/bin/bash

: "${CHECKS:=0}"
: "${OKS:=0}"
: "${WARNS:=0}"
: "${FAILS:=0}"

reset_stats() {
    CHECKS=0
    OKS=0
    WARNS=0
    FAILS=0
}

add_ok() {
    ((CHECKS++))
    ((OKS++))
}

add_warn() {
    ((CHECKS++))
    ((WARNS++))
}

add_fail() {
    ((CHECKS++))
    ((FAILS++))
}

print_stats() {
    echo
    echo "-----------------------------"
    printf "Checks   : %d\n" "$CHECKS"
    printf "OK       : %d\n" "$OKS"
    printf "Warnings : %d\n" "$WARNS"
    printf "Errors   : %d\n" "$FAILS"
    echo "-----------------------------"
}
