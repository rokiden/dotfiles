#!/bin/bash
SYSFS_PATH="/sys/devices/platform/lg-laptop"
VALID_FILES=("fan_mode" "battery_care_limit" "usb_charge")

# Check if at least one argument is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <pseudo-file> [value]"
    exit 1
fi

# Validate the pseudo-file name
is_valid=false
for file in "${VALID_FILES[@]}"; do
    if [[ "$1" == "$file" ]]; then
        is_valid=true
        break
    fi
done
if ! $is_valid; then
    echo "Error: Invalid pseudo-file. Allowed values: ${VALID_FILES[*]}"
    exit 2
fi

FILE_PATH="$SYSFS_PATH/$1"

# Check if the pseudo-file exists
if [[ ! -e "$FILE_PATH" ]]; then
    echo "Error: File $FILE_PATH does not exist."
    exit 3
fi

# If a second argument is provided, write to the file, otherwise read from it
if [[ -n "$2" ]]; then
    VAL="$2"
    if [[ "$VAL" == "toggle" ]]; then
        case $1 in
          fan_mode | usb_charge)
		  VAL=$((1-$(cat $FILE_PATH)))
    	  ;;
          battery_care_limit)
		  [[ $(cat $FILE_PATH) = 100 ]] && VAL="80" || VAL="100"
    	  ;;
          *)
		  echo "invalid value"
		  exit 4
          ;;
	esac
    fi
    echo "$VAL" > "$FILE_PATH"
else
    cat "$FILE_PATH"
fi

