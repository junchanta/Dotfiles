#!/bin/sh

INTERFACE="en0"
CACHE_FILE="/tmp/sketchybar_network_$INTERFACE"

# Get current bytes
read_bytes() {
  netstat -ibn | grep -e "$INTERFACE" -m 1 | awk '{print $7}'
}

write_bytes() {
  netstat -ibn | grep -e "$INTERFACE" -m 1 | awk '{print $10}'
}

CURRENT_DOWN=$(read_bytes)
CURRENT_UP=$(write_bytes)

if [ -f "$CACHE_FILE" ]; then
  PREV_DOWN=$(cut -d' ' -f1 "$CACHE_FILE")
  PREV_UP=$(cut -d' ' -f2 "$CACHE_FILE")

  DOWN_DIFF=$((CURRENT_DOWN - PREV_DOWN))
  UP_DIFF=$((CURRENT_UP - PREV_UP))

  # Convert to KB/s (update_freq is 2 seconds)
  DOWN_SPEED=$((DOWN_DIFF / 2 / 1024))
  UP_SPEED=$((UP_DIFF / 2 / 1024))

  # Format with fixed width (4 chars for number)
  if [ $DOWN_SPEED -ge 1024 ]; then
    DOWN_VAL=$(echo "scale=1; $DOWN_SPEED/1024" | bc)
    DOWN_LABEL=$(printf "%4sM" "$DOWN_VAL")
  else
    DOWN_LABEL=$(printf "%4sK" "$DOWN_SPEED")
  fi

  if [ $UP_SPEED -ge 1024 ]; then
    UP_VAL=$(echo "scale=1; $UP_SPEED/1024" | bc)
    UP_LABEL=$(printf "%4sM" "$UP_VAL")
  else
    UP_LABEL=$(printf "%4sK" "$UP_SPEED")
  fi

  sketchybar --set "$NAME" label="▼${DOWN_LABEL} ▲${UP_LABEL}"
else
  sketchybar --set "$NAME" label="▼   0K ▲   0K"
fi

echo "$CURRENT_DOWN $CURRENT_UP" > "$CACHE_FILE"
