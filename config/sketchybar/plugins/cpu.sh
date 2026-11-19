#!/bin/sh

CPU=$(top -l 1 | grep -E "^CPU" | grep -Eo '[0-9]+\.[0-9]+%' | head -1 | cut -d'%' -f1)
CPU_INT=${CPU%.*}

if [ "$CPU_INT" -ge 80 ]; then
  COLOR="0xfff7768e"
elif [ "$CPU_INT" -ge 50 ]; then
  COLOR="0xffe0af68"
else
  COLOR="0xff5c9fff"
fi

sketchybar --set "$NAME" label="${CPU}%" icon.color="$COLOR"
