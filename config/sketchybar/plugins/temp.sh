#!/bin/sh

TEMP=$(osx-cpu-temp -C 2>/dev/null | cut -d'°' -f1)

if [ -z "$TEMP" ]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

TEMP_INT=${TEMP%.*}

if [ "$TEMP_INT" -ge 80 ]; then
  COLOR="0xfff7768e"
elif [ "$TEMP_INT" -ge 60 ]; then
  COLOR="0xffe0af68"
else
  COLOR="0xff5c9fff"
fi

sketchybar --set "$NAME" label="${TEMP}°" icon.color="$COLOR"
