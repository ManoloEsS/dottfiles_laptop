#!/bin/bash
# Reset Bluetooth + Audio (PipeWire/WirePlumber) on Arch

DEVICE_MAC="A8:99:DC:57:E1:1F"   # Heavys H1H

echo ">>> Stopping services..."
systemctl --user stop pipewire pipewire-pulse wireplumber
sudo systemctl stop bluetooth

echo ">>> Removing Bluetooth configs..."
sudo rm -rf /var/lib/bluetooth/*

echo ">>> Removing audio configs..."
rm -rf ~/.config/pipewire
rm -rf ~/.local/state/wireplumber
rm -rf ~/.config/pulse

echo ">>> Resetting Bluetooth adapter..."
sudo rfkill unblock bluetooth
if hciconfig | grep -q hci0; then
    sudo hciconfig hci0 down
    sudo hciconfig hci0 up
    echo ">>> Adapter hci0 reset successfully."
else
    echo ">>> No hci0 adapter found (USB dongle unplugged? firmware missing?)."
fi

echo ">>> Restarting services..."
sudo systemctl start bluetooth
systemctl --user start pipewire pipewire-pulse wireplumber
sleep 3

echo ">>> Attempting to connect to $DEVICE_MAC..."
bluetoothctl << EOF
power on
agent on
default-agent
connect $DEVICE_MAC
trust $DEVICE_MAC
exit
EOF

echo ">>> Done!"
echo "If connection fails, put your Heavys H1H in pairing mode and rerun this script."

