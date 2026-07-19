#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$BASE_DIR/core/bootstrap.sh"
export LC_NUMERIC=C

MONITOR_DIR="$BASE_DIR/var/monitor"
BASELINE_FILE="$MONITOR_DIR/baseline.json"
HISTORY_FILE="$MONITOR_DIR/history.log"
mkdir -p "$MONITOR_DIR"

measure_cpu() {
    if command -v sysbench >/dev/null 2>&1; then
        sysbench cpu --cpu-max-prime=20000 run 2>/dev/null | grep "total time:" | awk '{print $NF}' | sed 's/,/./ ; s/s//'
    else
        { time for i in $(seq 1 200000); do :; done; } 2>&1 | grep real | awk '{print $2}' | sed 's/,/./ ; s/^0m//; s/s//'
    fi
}

measure_ram() {
    local testfile="/tmp/knight-monitor-ram-$$"
    dd if=/dev/zero of="$testfile" bs=64M count=1 conv=fdatasync 2>&1 | tail -1 | grep -oP '\d+\.?\d*(?= MB/s)' || echo "N/A"
    rm -f "$testfile"
}

measure_disk() {
    local testdir="/tmp/knight-monitor-disk-$$"
    mkdir "$testdir"
    local start=$(date +%s%N)
    for i in $(seq 1 500); do
        dd if=/dev/urandom of="$testdir/file-$i" bs=4k count=1 2>/dev/null
    done
    local end=$(date +%s%N)
    rm -rf "$testdir"
    LC_NUMERIC=C awk "BEGIN { printf \"%.2f\", ($end - $start) / 1000000000 }"
}

measure_latency() {
    ping -c 5 -q localhost 2>/dev/null | tail -1 | awk -F/ '{print $5}' | sed 's/,/./'
}

run_benchmark() {
    echo "{"
    echo "  \"cpu\": \"$(measure_cpu)\","
    echo "  \"ram\": \"$(measure_ram)\","
    echo "  \"disk_io\": \"$(measure_disk)\","
    echo "  \"latency\": \"$(measure_latency)\""
    echo "}"
}

compare_metric() {
    local name="$1" baseline="$2" current="$3" direction="$4"
    if [ "$baseline" = "N/A" ] || [ "$current" = "N/A" ]; then
        printf "[ ${C_YELLOW}??${C_RESET} ] %-12s N/A\n" "$name"
        return
    fi
    local change arrow color
    if [ "$direction" = "higher_better" ]; then
        change=$(LC_NUMERIC=C awk "BEGIN { printf \"%.2f\", (($current - $baseline) / $baseline) * 100 }")
    else
        change=$(LC_NUMERIC=C awk "BEGIN { printf \"%.2f\", (($baseline - $current) / $baseline) * 100 }")
    fi
    arrow=$(LC_NUMERIC=C awk "BEGIN { if ($change > 0) print \"UP\"; else print \"DOWN\" }")
    if [ "$arrow" = "UP" ]; then
        color="$C_GREEN"
    else
        color="$C_RED"
    fi
    printf "[ ${color}%s${C_RESET} ] %-12s %s -> %s (%+.2f%%)\n" "$arrow" "$name" "$baseline" "$current" "$change"
}

case "${1:-}" in
    baseline)
        info "Running baseline benchmark..."
        run_benchmark > "$BASELINE_FILE"
        ok "Baseline saved to $BASELINE_FILE"
        ;;
    compare)
        if [ ! -f "$BASELINE_FILE" ]; then
            fail "No baseline found. Run ./knight monitor baseline first."
            exit 1
        fi
        info "Running comparison benchmark..."
        CURRENT_FILE="$MONITOR_DIR/current.json"
        run_benchmark > "$CURRENT_FILE"
        
        section "Performance Comparison (baseline vs current)"
        echo
        b_cpu=$(grep "\"cpu\":" "$BASELINE_FILE" | cut -d: -f2 | tr -d " ,\"")
        c_cpu=$(grep "\"cpu\":" "$CURRENT_FILE" | cut -d: -f2 | tr -d " ,\"")
        compare_metric "cpu" "$b_cpu" "$c_cpu" "lower_better"

        b_ram=$(grep "\"ram\":" "$BASELINE_FILE" | cut -d: -f2 | tr -d " ,\"")
        c_ram=$(grep "\"ram\":" "$CURRENT_FILE" | cut -d: -f2 | tr -d " ,\"")
        compare_metric "ram" "$b_ram" "$c_ram" "higher_better"

        b_disk=$(grep "\"disk_io\":" "$BASELINE_FILE" | cut -d: -f2 | tr -d " ,\"")
        c_disk=$(grep "\"disk_io\":" "$CURRENT_FILE" | cut -d: -f2 | tr -d " ,\"")
        compare_metric "disk_io" "$b_disk" "$c_disk" "lower_better"

        b_lat=$(grep "\"latency\":" "$BASELINE_FILE" | cut -d: -f2 | tr -d " ,\"")
        c_lat=$(grep "\"latency\":" "$CURRENT_FILE" | cut -d: -f2 | tr -d " ,\"")
        compare_metric "latency" "$b_lat" "$c_lat" "lower_better"

        # Save to history
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp | cpu=$c_cpu (was $b_cpu) | ram=$c_ram (was $b_ram) | disk=$c_disk (was $b_disk) | lat=$c_lat (was $b_lat)" >> "$HISTORY_FILE"
        rm "$CURRENT_FILE"
        ;;
    history)
        if [ -f "$HISTORY_FILE" ]; then
            section "Performance History (last 10)"
            tail -10 "$HISTORY_FILE"
        else
            info "No history yet. Run ./knight monitor compare to start recording."
        fi
        ;;
    show)
        if [ -f "$BASELINE_FILE" ]; then
            section "Current Baseline"
            cat "$BASELINE_FILE"
        else
            info "No baseline found. Create one with: ./knight monitor baseline"
        fi
        ;;
    *)
        echo "Usage: ./knight monitor {baseline|compare|history|show}"
        ;;
esac
