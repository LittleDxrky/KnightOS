#!/bin/bash
for i in 0 1 2 3; do
    amixer -c 2 sset "IEC958,$i" 100% 2>/dev/null
    amixer -c 2 sset "IEC958,$i" unmute 2>/dev/null
done
echo "Громкость Chu2 DSP установлена на 100%"
