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
            echo "$line" 
            first_line=false
        else
            ssid=$(echo "$line" | awk '{print $1}')
            security=$(echo "$line" | awk '{print $3}')
            
            if [[ "$security" == *"WPA"* || "$security" == *"WEP"* ]]; then
                marker=""  # Secured network
            else
                marker=""  # Open network
            fi

            echo "$marker $line"
        fi
    done | column -t -s $'\t'  # Format output into columns
}

# Function to get the list of saved networks
get_saved_networks() {
    # Add back option as the first line
    echo "󰌍 Back to Main Menu"
    echo ""  # Empty line for separation
    
    # List saved connections with type information
    nmcli -t -f NAME,TYPE connection show | while IFS=':' read -r name type; do
        # Remove any leading/trailing whitespace from name
        name=$(echo "$name" | xargs)
        case "$type" in
            "802-11-wireless")
                echo "󰖩 $name"  # WiFi symbol
                ;;
            "802-3-ethernet")
                echo "󰈀 $name"  # Ethernet symbol
                ;;
            "tun")
                echo "󰖂 $name"  # VPN symbol
                ;;
            "bridge")
                echo "󰯎 $name"  # Bridge symbol
                ;;
            *)
                echo "󰤭 $name"  # Generic network symbol for other types
                ;;
        esac
    done
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

# Add reload option
reload_option="󰑐 Reload Networks"

# Add hidden network option
hidden_network_option="󰖪 Add Hidden Network"

# Get the list of networks (this will be the rest of the lines)
networks=$(get_wifi_list)

# Add the option to view saved networks after disabling networking
view_saved_networks_option="󰋊 View Saved Networks"

# Combine all options and networks
full_list="$network_option\n$reload_option\n$hidden_network_option\n$view_saved_networks_option\n$networks"

# Show networks in Rofi for selection
while true; do
    chosen_network=$(echo -e "$full_list" | \
        rofi -dmenu -i -p "Select WiFi Network" \
        -theme wifi.rasi )

    # Exit if no network was chosen (Escape pressed)
    if [[ -z "$chosen_network" ]]; then
        exit 0
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
        break
    fi

    # Handle reload option
    if [[ "$chosen_network" == "$reload_option" ]]; then
        notify-send "WiFi" "Reloading networks..."
        networks=$(get_wifi_list)
        full_list="$network_option\n$reload_option\n$hidden_network_option\n$view_saved_networks_option\n$networks"
        continue
    fi

    # Handle hidden network connection
    if [[ "$chosen_network" == "$hidden_network_option" ]]; then
        while true; do
            # Get SSID for hidden network
            hidden_ssid=$(echo -e "󰌍 Back to Main Menu\n" | \
                rofi -dmenu -i -p "Enter Hidden Network SSID" -lines 0 -theme ~/Scripts/wifi.rasi)

            # Handle back option or Escape for SSID
            if [[ -z "$hidden_ssid" ]] || [[ "$hidden_ssid" == "󰌍 Back to Main Menu" ]]; then
                break  # Return to main menu
            fi

            # Get password for hidden network
            password=$(echo -e "󰌍 Back to SSID\n" | \
                rofi -dmenu -i -p "Enter Password" -password -lines 0 -theme ~/Scripts/wifi.rasi)

            # Handle back option or Escape for password
            if [[ -z "$password" ]] || [[ "$password" == "󰌍 Back to SSID" ]]; then
                continue  # Go back to SSID input
            fi

            # Try to connect to the hidden network
            notify-send "WiFi" "Attempting to connect to hidden network $hidden_ssid..."
            if nmcli device wifi connect "$hidden_ssid" password "$password" hidden yes; then
                notify-send "WiFi" "Successfully connected to hidden network $hidden_ssid"
                break 2  # Return to main menu after successful connection
            else
                notify-send "WiFi" "Failed to connect to hidden network $hidden_ssid"
                continue  # Try again from SSID input
            fi
        done
        continue  # Return to main menu
    fi

    # Handle viewing saved networks
    if [[ "$chosen_network" == "$view_saved_networks_option" ]]; then
        while true; do
            saved_networks=$(get_saved_networks)

            # Display saved networks in Rofi
            selected_saved_network=$(echo -e "$saved_networks" | \
                rofi -dmenu -i -p "Select Saved Network to Forget" \
                -theme ~/Scripts/wifi.rasi)

            # Return to main menu if Escape pressed
            if [[ -z "$selected_saved_network" ]]; then
                break
            fi

            # Handle back option
            if [[ "$selected_saved_network" == "󰌍 Back to Main Menu" ]]; then
                break
            fi

            # Extract network name without the symbol
            network_name=$(echo "$selected_saved_network" | cut -d' ' -f2-)

            # Forget the selected saved network
            nmcli connection delete "$network_name"
            notify-send "WiFi" "Network '$network_name' forgotten successfully."
            break  # Break out of the inner loop to return to main menu
        done
        continue  # Return to main menu
    fi

    # Handle regular network connection
    ssid=$(echo "$chosen_network" | awk '{print $2}')
    notify-send "WiFi" "Attempting to connect to $ssid..."

    # Check if the network is already known
    if nmcli connection show | grep -q "^$ssid "; then
        nmcli connection up "$ssid"
    else
        # Check if network is secured
        if echo "$chosen_network" | grep -q "WPA\|WEP"; then
            while true; do
                # Get password from Rofi prompt with back option
                password=$(echo -e "󰌍 Back to Networks\n" | \
                    rofi -dmenu -i -p "Enter Password" -password -lines 0 -theme ~/Scripts/wifi.rasi)

                # Handle back option or Escape
                if [[ -z "$password" ]] || [[ "$password" == "󰌍 Back to Networks" ]]; then
                    break
                fi

                # Try to connect to the network with the password
                if nmcli device wifi connect "$ssid" password "$password"; then
                    notify-send "WiFi" "Successfully connected to $ssid"
                    break 2  # Exit both loops on success
                else
                    notify-send "WiFi" "Failed to connect to $ssid. Incorrect password or other error."
                    continue
                fi
            done
            continue
        else
            # Connect to an open network
            if nmcli device wifi connect "$ssid"; then
                notify-send "WiFi" "Successfully connected to $ssid"
                break
            else
                notify-send "WiFi" "Failed to connect to $ssid"
                continue
            fi
        fi
    fi
done

