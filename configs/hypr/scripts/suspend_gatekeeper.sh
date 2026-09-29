#!/bin/bash
# Only suspend if no music is playing and load is low

# Check for active media player
if playerctl status 2>/dev/null | grep -q "Playing"; then
    exit 1
fi

# Check system load (1-minute average > 0.8)
if (( $(echo "$(awk '{print $1}' /proc/loadavg) > 0.8" | bc -l) )); then
    exit 1
fi

# If we get here, it's safe to suspend
systemctl suspend
