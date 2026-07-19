#!/bin/bash
# Проверка аудиоподсистемы

section "Аудио"
if pactl info &>/dev/null; then
    SINK=$(pactl info | grep "Default Sink" | cut -d: -f2 | xargs)
    printf "Активное устройство: %s\n" "$SINK"
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o '[0-9]*%' | head -1)
    printf "Громкость:           %s\n" "$VOL"
else
    warn "PulseAudio/PipeWire не активен"
fi

# Проверка Chu2 DSP (карта 2)
if amixer -c 2 scontrols &>/dev/null; then
    IEC958_0=$(amixer -c 2 sget "IEC958,0" 2>/dev/null | grep -o '\[on\]\|\[off\]')
    printf "Chu2 DSP (IEC958,0): %s\n" "${IEC958_0:-неизвестно}"
fi
