#!/bin/bash

# Dependencies: network-manager, rofi, notify-send

# Function to get the list of available WiFi networks
get_wifi_list() {
    first_line=true

    # Show notification while fetching the Wi-Fi list
    notify-send "WiFi" "Fetching available Wi-Fi networks..."

    # Get detailed WiFi network information
    nmcli --field SSID,BSSID,SECURITY,BARS,SIGNAL,BANDWIDTH,MODE,CHAN,RATE device wifi list | \
    while read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi

        if [[ "$first_line" == true ]]; then
            echo "$line"  # Just print the header line without any marker
            first_line=false
        else
            ssid=$(echo "$line" | awk '{print $1}')
            security=$(echo "$line" | awk '{print $3}')
            
            if [[ "$security" == *"WPA"* || "$security" == *"WEP"* ]]; then
                marker=" "  # Secured network
            else
                marker=" "  # Open network
            fi

            echo "$marker $line"
        fi
    done | column -t -s $'\t'  # Format output into columns
}

# Function to get the list of saved networks
get_saved_networks() {
    # List saved connections
    nmcli -t -f NAME connection show  # Only show SSID names
}

# Function to determine the current network state and return the toggle option
toggle_networks() {
    # Get the current network status (check if networking is enabled)
    network_status=$(nmcli networking)

    if [[ "$network_status" == "enabled" ]]; then
        echo "󰖪  Disable Networking"
    else
        echo "󰖩 Enable Networking"
    fi
}

# Get the current networking option (this will be the first line)
network_option=$(toggle_networks)

# Get the list of networks (this will be the rest of the lines)
networks=$(get_wifi_list)

# Add the option to view saved networks after disabling networking
view_saved_networks_option="  View Saved Networks"

# Combine the toggle option, saved networks option, and networks
full_list="$network_option\n$view_saved_networks_option\n$networks"

# Show networks in Rofi for selection
chosen_network=$(echo -e "$full_list" | \
    rofi -dmenu -i -p "Select WiFi Network" \
    -theme ~/Scripts/wifi.rasi )

# Exit if no network was chosen
if [[ -z "$chosen_network" ]]; then
    notify-send "WiFi" "No network selected. Exiting."
    exit 1
fi

# Handle network toggle (enable/disable)
if [[ "$chosen_network" == "$network_option" ]]; then
    if [[ "$network_option" == "󰖪  Disable Networking" ]]; then
        nmcli networking off
        notify-send "Network" "All networks disabled."
    else
        nmcli networking on
        notify-send "Network" "All networks enabled."
    fi
    exit 0
fi

# Handle viewing saved networks
if [[ "$chosen_network" == "$view_saved_networks_option" ]]; then
    saved_networks=$(get_saved_networks)

    # Display saved networks in Rofi
    selected_saved_network=$(echo -e "$saved_networks" | \
        rofi -dmenu -i -p "Select Saved Network to Forget" \
        -theme ~/.local/share/rofi/stuff/wifi.rasi )

    # Exit if no saved network was selected
    if [[ -z "$selected_saved_network" ]]; then
        notify-send "WiFi" "No saved network selected. Exiting."
        exit 1
    fi

    # Forget the selected saved network
    nmcli connection delete "$selected_saved_network"
    notify-send "WiFi" "Network '$selected_saved_network' forgotten successfully."
    exit 0
fi

# Extract SSID from chosen network (after stripping the marker)
ssid=$(echo "$chosen_network" | awk '{print $2}')

# Show notification for attempting connection
notify-send "WiFi" "Attempting to connect to $ssid..."

# Check if the network is already known
if nmcli connection show | grep -q "^$ssid "; then
    nmcli connection up "$ssid"
else
    # Check if network is secured
    if echo "$chosen_network" | grep -q "WPA\|WEP"; then
        # Get password from Rofi prompt
        password=$(rofi -dmenu -p "Enter Password" -password -lines 0)
        if [[ -z "$password" ]]; then
            notify-send "WiFi" "Connection attempt cancelled. No password provided."
            exit 1
        fi

        # Try to connect to the network with the password
        nmcli device wifi connect "$ssid" password "$password"
    else
        # Connect to an open network
        nmcli device wifi connect "$ssid"
    fi
fi

# Check connection status and notify the user accordingly
if [ $? -eq 0 ]; then
    notify-send "WiFi" "Successfully connected to $ssid"
else
    notify-send "WiFi" "Failed to connect to $ssid. Incorrect password or other error."
fi

