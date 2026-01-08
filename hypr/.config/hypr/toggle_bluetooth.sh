#!/bin/bash

# Get Bluetooth status
status=$(rfkill list bluetooth | grep -i "Soft blocked" | awk '{print $3}')

if [ "$status" == "yes" ]; then
    rfkill unblock bluetooth
    bluetoothctl power on
    notify-send "Bluetooth Enabled"
else
    bluetoothctl power off
    rfkill block bluetooth
    notify-send "Bluetooth Disabled"
fi

