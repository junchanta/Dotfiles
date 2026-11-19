#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-this-script

if [ "$SELECTED" = "true" ]; then
	sketchybar --set "$NAME" background.color=0xff5c9fff icon.color=0xff000000
else
	sketchybar --set "$NAME" background.color=0x40ffffff icon.color=0xffffffff
fi
