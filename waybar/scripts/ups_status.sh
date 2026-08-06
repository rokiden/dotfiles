#!/bin/bash
# Waybar module: NUT UPS status (battery.charge + ups.status via upsc)
#
# Usage: ups_status.sh <ups_name> <host> <poll_interval_s> <warn_pct> <crit_pct>
# Example: ups_status.sh Champ1K localhost 5 70 40
#
# Coloring (class):
#   critical - upsc unreachable/errored, or battery.charge < crit_pct
#   warning  - battery.charge < warn_pct, or ups.status is not "OL" (on battery)
#   default  - online (OL) and battery.charge >= warn_pct
#
# Prints one JSON line per poll: {"text","class","tooltip","percentage"}

set -u

UPS_NAME="${1:?Usage: $0 <ups_name> <host> <poll_interval_s> <warn_pct> <crit_pct>}"
HOST="${2:?Usage: $0 <ups_name> <host> <poll_interval_s> <warn_pct> <crit_pct>}"
POLL_INTERVAL="${3:-5}"
WARN_PCT="${4:-70}"
CRIT_PCT="${5:-40}"

# Same 5-level glyph set as the built-in "battery" module, for visual consistency.
ICONS=($'\uf244' $'\uf243' $'\uf242' $'\uf241' $'\uf240')

battery_icon() {
    local pct="$1"
    if   (( pct < 20 )); then echo "${ICONS[0]}"
    elif (( pct < 40 )); then echo "${ICONS[1]}"
    elif (( pct < 60 )); then echo "${ICONS[2]}"
    elif (( pct < 80 )); then echo "${ICONS[3]}"
    else                      echo "${ICONS[4]}"
    fi
}

status_words() {
    # Translate NUT ups.status flags into a human-readable summary.
    local out="" flag
    for flag in $1; do
        case "$flag" in
            OL)      out+="Online, ";;
            OB)      out+="On battery, ";;
            LB)      out+="Low battery, ";;
            RB)      out+="Replace battery, ";;
            CHRG)    out+="Charging, ";;
            DISCHRG) out+="Discharging, ";;
            BYPASS)  out+="Bypass, ";;
            CAL)     out+="Calibrating, ";;
            OFF)     out+="Off, ";;
            OVER)    out+="Overloaded, ";;
            TRIM)    out+="Trimming voltage, ";;
            BOOST)   out+="Boosting voltage, ";;
            FSD)     out+="Forced shutdown, ";;
            *)       out+="$flag, ";;
        esac
    done
    echo "${out%, }"
}

emit() {
    jq -n --unbuffered --compact-output \
        --arg text "$1" \
        --arg class "$2" \
        --arg tooltip "$3" \
        --argjson percentage "$4" \
        '$ARGS.named'
}

while true; do
    RAW="$(upsc "${UPS_NAME}@${HOST}" 2>&1)"
    RC=$?

    if [[ $RC -ne 0 ]]; then
        ERR="$(echo "$RAW" | grep -m1 '^Error:' || echo "$RAW" | tail -n1)"
        emit "UPS? ${ICONS[0]}" "critical" "UPS: ${UPS_NAME}@${HOST}"$'\n'"Connection lost: ${ERR}" 0
        sleep "$POLL_INTERVAL"
        continue
    fi

    CHARGE="$(echo "$RAW" | awk -F': ' '/^battery.charge:/ {print $2}')"
    STATUS="$(echo "$RAW" | awk -F': ' '/^ups.status:/ {print $2}')"
    RUNTIME_S="$(echo "$RAW" | awk -F': ' '/^battery.runtime:/ {print $2}')"
    LOAD="$(echo "$RAW" | awk -F': ' '/^ups.load:/ {print $2}')"
    INVOLT="$(echo "$RAW" | awk -F': ' '/^input.voltage:/ {print $2}')"
    MODEL="$(echo "$RAW" | awk -F': ' '/^device.model:/ {print $2}')"

    if [[ -z "$CHARGE" || -z "$STATUS" ]]; then
        emit "UPS? ${ICONS[0]}" "critical" "UPS: ${UPS_NAME}@${HOST}"$'\n'"Connection lost: incomplete data from upsd" 0
        sleep "$POLL_INTERVAL"
        continue
    fi

    CHARGE_INT="${CHARGE%%.*}"

    CLASS="default"
    if (( CHARGE_INT < CRIT_PCT )); then
        CLASS="critical"
    elif (( CHARGE_INT < WARN_PCT )) || [[ "$STATUS" != *OL* ]]; then
        CLASS="warning"
    fi

    ICON="$(battery_icon "$CHARGE_INT")"
    TEXT="${CHARGE_INT}% ${ICON}"

    NL=$'\n'
    TOOLTIP="UPS: ${UPS_NAME}${MODEL:+ (${MODEL})}"
    TOOLTIP+="${NL}Status: $(status_words "$STATUS")"
    TOOLTIP+="${NL}Charge: ${CHARGE_INT}%"
    [[ -n "$RUNTIME_S" ]] && TOOLTIP+="${NL}Runtime left: $((RUNTIME_S / 60)) min"
    [[ -n "$LOAD" ]] && TOOLTIP+="${NL}Load: ${LOAD}%"
    [[ -n "$INVOLT" ]] && TOOLTIP+="${NL}Input: ${INVOLT}V"

    emit "$TEXT" "$CLASS" "$TOOLTIP" "$CHARGE_INT"

    sleep "$POLL_INTERVAL"
done
