#!/bin/sh
# Waybar recording helper
# Usage: record.sh [start|stop|status]

PIDFILE=/tmp/waybar-record.pid
PATHFILE=/tmp/waybar-record.path

is_recording() {
    [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "$1" in
    start)
        if is_recording; then
            exit 0
        fi
        SINK_MON="$(pactl get-default-sink).monitor"
        SOURCE="$(pactl get-default-source)"
        OUTFILE="$HOME/Music/rec_$(date +%Y%m%d_%H%M%S).mp3"
        ffmpeg -y \
            -f pulse -i "$SINK_MON" \
            -f pulse -i "$SOURCE" \
            -filter_complex amix=inputs=2:duration=longest \
            "$OUTFILE" \
            </dev/null >/tmp/waybar-record.log 2>&1 &
        echo $! > "$PIDFILE"
        echo "$OUTFILE" > "$PATHFILE"
        ;;
    stop)
        if is_recording; then
            kill "$(cat "$PIDFILE")" 2>/dev/null
        fi
        rm -f "$PIDFILE" "$PATHFILE"
        ;;
    status)
        if is_recording; then
            OUTFILE=$(cat "$PATHFILE" 2>/dev/null || echo 'unknown')
            printf '{"text":"󰑋","class":"recording","tooltip":"Recording active — right-click to stop\\nOutput: %s"}\n' "$OUTFILE"
        else
            rm -f "$PIDFILE" 2>/dev/null
            printf '{"text":"󰑋","class":"","tooltip":"Left-click to start recording\\nRight-click to stop"}\n'
        fi
        ;;
    *)
        echo "Usage: $0 [start|stop|status]" >&2
        exit 1
        ;;
esac
