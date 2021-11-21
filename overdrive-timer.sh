#!/bin/bash
# kramski@web.de

deldelay=30
declare -A starttime endtime 

echo "A Bluetooth-based timer for Anki Overdrive supercar battery tests in demo mode."
echo "Make sure a car is switched off at least $deldelay seconds before this script starts."
echo "Timer starts when a car is switched on and ends $deldelay seconds after it runs out of juice (or is switched off)."
echo "(Ctrl-C to quit)."

stdbuf -i0 -o0 -e0 bluetoothctl scan on |
while read state dummy1 mac dummy2 name 
do
    if [[ "$state" =~ "NEW" && "$name" == "Drive" ]]
    then
        echo "$state" "$mac" "$name"
        starttime["$mac"]=$(date +%s)
        echo "Starting timer for $mac at $(date +%T)"
    else 
        if [[ "$state" =~ "DEL" && "$name" == "Drive" ]]
        then
            echo "$state" "$mac" "$name"
            endtime["$mac"]=$(date +%s)
            echo "Stopping timer for $mac at $(date +%T)"
            difftime=$((${endtime["$mac"]} - ${starttime["$mac"]} - $deldelay))
            mins=$(($difftime / 60))
            secs=$(($difftime % 60))
            echo "$mac: $mins mins $secs secs"
        fi
    fi
done
