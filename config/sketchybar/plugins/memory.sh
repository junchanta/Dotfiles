#!/bin/sh

MEMORY=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | cut -d'%' -f1)

if [ "$MEMORY" -ge 80 ]; then
  COLOR="0xfff7768e"
elif [ "$MEMORY" -ge 60 ]; then
  COLOR="0xffe0af68"
else
  COLOR="0xff5c9fff"
fi

sketchybar --set "$NAME" label="${MEMORY}%" icon.color="$COLOR"
