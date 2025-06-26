#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <device_name> <update_interval> <perc_warn> <perc_crit>" >&2
    echo "Example: $0 intel-rapl:0 1 50 90" >&2
    exit 1
fi

DEVICE="$1"
UPDATE_PERIOD="$2"
PERC_WARN="$3"
PERC_CRIT="$4"
BASEDIR="/sys/class/powercap/$DEVICE"

# Validate device exists
if [[ ! -d "$BASEDIR" ]]; then
    echo "{"text": "Error: Device $DEVICE not found", "class": "error"}"
    exit 1
fi

# Validate required files exist
if [[ ! -f "$BASEDIR/energy_uj" ]] || [[ ! -f "$BASEDIR/max_energy_range_uj" ]] || [[ ! -f "$BASEDIR/constraint_0_power_limit_uw" ]]; then
    echo "{"text": "Error: Required files missing", "class": "error"}"
    exit 1
fi

ENERGY_PATH="$BASEDIR/energy_uj"
MAX_ENERGY=$(cat "$BASEDIR/max_energy_range_uj")
POWER_LIMIT=$(cat "$BASEDIR/constraint_0_power_limit_uw")
LAST_ENERGY=-1
LAST_TIME=-1

CALC_WATTS=0.0
CALC_PERCENT=0
calculate_power() {
    local current_energy=$(cat "$ENERGY_PATH")
    local current_time=$(date +%s%N)

    if [[ $LAST_ENERGY -ne -1 ]]; then
        local energy_diff=$current_energy
        
        # Handle energy counter wraparound
        if [[ $current_energy -lt $LAST_ENERGY ]]; then
            energy_diff=$(( current_energy + MAX_ENERGY - LAST_ENERGY ))
        else
            energy_diff=$(( current_energy - LAST_ENERGY ))
        fi

        # Convert nanoseconds to seconds properly using bc
        local time_diff=$(bc -l <<< "($current_time - $LAST_TIME) / 1000000000")
        
        if (( $(echo "$time_diff > 0" | bc -l) )); then
            CALC_WATTS=$(bc -l <<< "scale=1;$energy_diff / $time_diff / 1000000")
	    CALC_PERCENT=$(bc -l <<< "scale=0;$CALC_WATTS * 1000000 * 100 / $POWER_LIMIT")
        fi
    fi

    LAST_ENERGY=$current_energy
    LAST_TIME=$current_time
}

# Main loop
while true; do
    calculate_power
    CLASS="default"
    if [[ $CALC_PERCENT -gt $PERC_CRIT ]]; then
	    CLASS="critical"
    elif [[ $CALC_PERCENT -gt $PERC_WARN ]]; then
	    CLASS="warning"
    fi
	
    jq -n --unbuffered --compact-output \
	--arg text "$(printf '%4sW' ${CALC_WATTS})" \
        --argjson percentage "$CALC_PERCENT" \
        --arg class "$CLASS" \
        '$ARGS.named'
    sleep $UPDATE_PERIOD
done
