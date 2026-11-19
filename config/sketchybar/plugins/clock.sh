#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/components#item----invoke-a-script

sketchybar --set "$NAME" label="$(date '+%Y-%m-%d %H:%M')"
