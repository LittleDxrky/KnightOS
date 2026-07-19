#!/bin/bash

get_default_sink_name() {
    pactl info | grep "Default Sink:" | sed 's/Default Sink: //'
}

show_status() {
    echo "======================================"
    echo " Audio Control"
    echo "======================================"
    local sink=$(get_default_sink_name)
    if [ -n "$sink" ]; then
        echo "Active device: $sink"
        echo "Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)"
        echo "Mute: $(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes\|no')"
    else
        echo "No active device detected."
    fi
    echo "======================================"
}

while true; do
    show_status
    echo ""
    echo "1) Volume up (+5%)"
    echo "2) Volume down (-5%)"
    echo "3) Toggle mute"
    echo "4) Set volume to specific %"
    echo "5) List available devices"
    echo "6) Change default device"
    echo "7) Direct ALSA control (amixer)"
    echo "8) Exit"
    echo ""
    read -p "Your choice: " choice

    case $choice in
        1) 
            pactl set-sink-volume @DEFAULT_SINK@ +5%
            echo "Volume increased by 5%"
            ;;
        2) 
            pactl set-sink-volume @DEFAULT_SINK@ -5%
            echo "Volume decreased by 5%"
            ;;
        3) 
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            echo "Mute toggled"
            ;;
        4) 
            read -p "Enter volume (0-100%): " vol
            pactl set-sink-volume @DEFAULT_SINK@ "$vol%"
            echo "Volume set to $vol%"
            ;;
        5)
            echo "Available devices:"
            default=$(get_default_sink_name)
            pactl list short sinks | while read -r line; do
                id=$(echo "$line" | awk '{print $1}')
                name=$(echo "$line" | awk '{print $2}')
                if [ "$name" = "$default" ]; then
                    echo " * $id: $name [ACTIVE]"
                else
                    echo "   $id: $name"
                fi
            done
            ;;
        6) 
            read -p "Enter device name or number from the list above: " sink
            if pactl set-default-sink "$sink" 2>/dev/null; then
                echo "Default device changed to $sink"
            else
                echo "Failed to change device. Check the name/number and try again."
            fi
            ;;
        7)
            read -p "Enter ALSA card number (e.g., 2 for Chu2): " card
            echo "Available controls for card $card:"
            amixer -c "$card" scontrols
            read -p "Enter control name (e.g., PCM, Master): " control
            read -p "Enter volume (0-100%): " vol
            amixer -c "$card" sset "$control" "$vol%" && echo "ALSA volume set" || echo "ALSA command failed"
            ;;
        8) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
    echo ""
    sleep 1
done
