#!/bin/bash

# Find Ethernet and Airport real interface number

ETHINT=$(system_profiler SPNetworkDataType | grep -i -A 1 'Hardware\: Ethernet' | grep en | awk -F " : " '{printf $NF}' | grep -o "[^ ]*$")
AIRINT=$(system_profiler SPNetworkDataType | grep -i -A 1 'Hardware\: Airport' | awk -F " : " '{printf $NF}' | grep -o "[^ ]*$")

function set_airport {

    new_status=$1

    if [ $new_status = "On" ]; then
	/usr/sbin/networksetup -setairportpower $AIRINT on
	touch /var/tmp/prev_air_on
    else
	/usr/sbin/networksetup -setairportpower $AIRINT off
	if [ -f "/var/tmp/prev_air_on" ]; then
	    rm /var/tmp/prev_air_on
	fi
    fi

}

function growl {

    # Checks whether Growl is installed
    if [ -f "/usr/local/bin/growlnotify" ]; then
	/usr/local/bin/growlnotify -m "$1" -a "AirPort Utility.app"
    fi

}

# Set default values
prev_eth_status="Off"
prev_air_status="Off"

eth_status="Off"

# Determine previous ethernet status
# If file prev_eth_on exists, ethernet was active last time we checked
if [ -f "/var/tmp/prev_eth_on" ]; then
    prev_eth_status="On"
fi

# Determine same for AirPort status
# File is prev_air_on
if [ -f "/var/tmp/prev_air_on" ]; then
    prev_air_status="On"
fi

# Check actual current ethernet status
if [ "`ifconfig $ETHINT | grep \"status: active\"`" != "" ]; then
    eth_status="On"
fi

# And actual current AirPort status
air_status=`/usr/sbin/networksetup -getairportpower $AIRINT | awk '{ print $4 }'`

# If any change has occured. Run external script (if it exists)
if [ "$prev_air_status" != "$air_status" ] || [ "$prev_eth_status" != "$eth_status" ]; then
    if [ -f "./statusChanged.sh" ]; then
	"./statusChanged.sh" "$eth_status" "$air_status" &
    fi
fi

# Determine whether ethernet status changed
if [ "$prev_eth_status" != "$eth_status" ]; then

    if [ "$eth_status" = "On" ]; then
	set_airport "Off"
	growl "Wired network detected. Turning AirPort off."
#   osascript -e 'display notification "Wired network detected. Turning AirPort off." with title "AiportToggle"'
    else
	set_airport "On"
	growl "No wired network detected. Turning AirPort on."
#   osascript -e 'display notification "No wired network detected. Turning AirPort on." with title "AiportToggle"'
    fi

# If ethernet did not change
else

    # Check whether AirPort status changed
    # If so it was done manually by user
    if [ "$prev_air_status" != "$air_status" ]; then
	set_airport $air_status

	if [ "$air_status" = "On" ]; then
	    growl "AirPort manually turned on."
#       osascript -e 'display notification "AirPort manually turned on." with title "AiportToggle"'
	else
#       osascript -e 'display notification "AirPort manually turned off." with title "AiportToggle"'
	    growl "AirPort manually turned off."
	fi

    fi

fi

# Update ethernet status
if [ "$eth_status" == "On" ]; then
    touch /var/tmp/prev_eth_on
else
    if [ -f "/var/tmp/prev_eth_on" ]; then
	rm /var/tmp/prev_eth_on
    fi
fi

exit 0