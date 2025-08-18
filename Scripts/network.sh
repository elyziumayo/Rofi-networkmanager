#!/bin/bash

# Configuration
THEME_FILE="$HOME/Scripts/wifi.rasi"
LOCK_SYMBOL="🔒"
UNLOCK_SYMBOL="🔓"
REFRESH_SYMBOL="🔄"
SETTINGS_SYMBOL="⚙️"
SAVED_SYMBOL="💾"
BACK_SYMBOL="⬅️"
CONNECT_SYMBOL="▶️"
FORGET_SYMBOL="❌"
WIFI_SYMBOL="📶"
WIRED_SYMBOL="🔌"
LOOPBACK_SYMBOL="🔄"
OTHER_SYMBOL="🔗"
NETWORK_TOGGLE_SYMBOL="🔌"
HIDDEN_NETWORK_SYMBOL="👻"
CONNECTED_SYMBOL="✅"

# Helper Functions
show_menu() {
    local options="$1"
    local prompt="$2"
    echo -e "$options" | rofi_cmd -dmenu -i -p "$prompt"
}

rofi_cmd() {
    if [[ -f "$THEME_FILE" ]]; then
        rofi -theme "$THEME_FILE" "$@" -kb-cancel "Escape"
    else
        rofi "$@" -kb-cancel "Escape"
    fi
}

get_input() {
    local prompt="$1"
    local is_password="${2:-false}"
    local lines="${3:-0}"
    local network_name="${4:-}"
    
    if [[ "$is_password" == "true" ]]; then
        rofi_cmd -dmenu -p "$prompt" -password -lines "$lines"
    else
        rofi_cmd -dmenu -p "$prompt" -lines "$lines"
    fi
}

handle_escape() {
    local callback="$1"
    local input="$2"
    local network_name="${3:-}"
    
    if [[ -z "$input" ]]; then
        if [[ -n "$network_name" ]]; then
            notify "Cancelled" "Password entry cancelled for $network_name" "normal"
        fi
        $callback
        return 1
    fi
    return 0
}

notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    notify-send -u "$urgency" "$title" "$message"
}

# Network Functions
get_current_wifi_ssid() {
    nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2
}

format_network_line() {
    local line="$1"
    local current_ssid="$2"
    local security=$(echo "$line" | awk '{print $3}')
    local symbol="$([[ "$security" == "--" ]] && echo "$UNLOCK_SYMBOL" || echo "$LOCK_SYMBOL")"
    local ssid=$(echo "$line" | awk '{print $1}')
    local rest=$(echo "$line" | cut -d' ' -f2-)
    
    # Check if this is the currently connected network
    if [[ "$ssid" == "$current_ssid" ]]; then
        echo "$CONNECTED_SYMBOL $ssid $rest"
    else
        echo "$symbol $ssid $rest"
    fi
}

get_networks() {
    local current_ssid=$(get_current_wifi_ssid)
    
    echo "____________________________________________________________________________________________________"
    echo " SSID                       BSSID        SECURITY   BARS  SIGNAL  BANDWIDTH  MODE  CHAN    RATE"
    echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
     
    nmcli -f SSID,BSSID,SECURITY,BARS,SIGNAL,BANDWIDTH,MODE,CHAN,RATE device wifi list | tail -n +2 | while read -r line; do
        format_network_line "$line" "$current_ssid"
    done
}

get_saved_networks() {
    nmcli -g NAME,UUID,TYPE connection show | sort | while IFS=: read -r name uuid type; do
        case "$type" in
            "802-11-wireless") echo "$WIFI_SYMBOL $name:$uuid:$type" ;;
            "802-3-ethernet") echo "$WIRED_SYMBOL $name:$uuid:$type" ;;
            "loopback"|"lo") echo "$LOOPBACK_SYMBOL $name:$uuid:$type" ;;
            *) echo "$OTHER_SYMBOL $name:$uuid:$type" ;;
        esac
    done
}

# connect functions with retry logic
connect_with_password() {
    local ssid="$1"
    local prompt_text="${2:-Password}"
    
    while true; do
        local password=$(get_input "$prompt_text" true 0 "$ssid")
        handle_escape main "$password" "$ssid" || return
        
        notify "Connecting" "Connecting to $ssid..." "low"
        
        if nmcli device wifi connect "$ssid" password "$password"; then
            notify "Connected" "Successfully connected to $ssid" "normal"
            return 0
        else
            notify "Connection Failed" "Wrong password for $ssid. Please try again." "critical"
            prompt_text="Wrong password! Try again"
        fi
    done
}

connect_to_network() {
    local selection="$1"
    
    if [[ "$selection" == *"SSID"* ]] || [[ "$selection" == --------* ]]; then
        main
        return
    fi
    
    selection=$(echo "$selection" | sed -E "s/^[^ ]+ //")
    local bssid=$(echo "$selection" | grep -o -E "([0-9A-F]{2}:){5}[0-9A-F]{2}")
    local ssid=$(echo "$selection" | sed -E "s/(.*)$bssid.*/\1/" | xargs)
    
    [[ -z "$ssid" ]] && exit 1
    
    local security=$(echo "$selection" | grep -o -E "(WPA|WEP|WPA2|--)")
    
    if [[ "$security" != "--" ]]; then
        connect_with_password "$ssid"
    else
        notify "Connecting" "Connecting to $ssid..." "low"
        if nmcli device wifi connect "$ssid"; then
            notify "Connected" "Successfully connected to $ssid" "normal"
        else
            notify "Connection Failed" "Failed to connect to $ssid" "critical"
        fi
    fi
}

connect_hidden_network() {
    local ssid=$(get_input "Enter SSID")
    handle_escape show_settings "$ssid" || return
    
    local security=$(show_menu "WPA/WPA2\nWEP\nNone" "Security Type")
    handle_escape show_settings "$security" || return
    
    if [[ "$security" != "None" ]]; then
        while true; do
            local password=$(get_input "Password" true 0 "$ssid")
            handle_escape show_settings "$password" "$ssid" || return
            
            notify "Connecting" "Connecting to hidden network $ssid..." "low"
            
            if nmcli device wifi connect "$ssid" password "$password" hidden yes; then
                notify "Connected" "Successfully connected to hidden network $ssid" "normal"
                return 0
            else
                notify "Connection Failed" "Wrong password for $ssid. Please try again." "critical"
            fi
        done
    else
        notify "Connecting" "Connecting to hidden network $ssid..." "low"
        if nmcli device wifi connect "$ssid" hidden yes; then
            notify "Connected" "Successfully connected to hidden network $ssid" "normal"
        else
            notify "Connection Failed" "Failed to connect to hidden network $ssid" "critical"
        fi
    fi
}

show_saved_networks() {
    local saved=$(get_saved_networks)
    local selection=$(show_menu "$BACK_SYMBOL Back\n$saved" "Saved Networks")
    
    if ! handle_escape show_settings "$selection" || [[ "$selection" == "$BACK_SYMBOL Back" ]]; then
        show_settings
        return
    fi
    
    local network_info=$(echo "$selection" | sed -E "s/^[^ ]+ //")
    local network_name=$(echo "$network_info" | cut -d: -f1)
    local action=$(show_menu "$CONNECT_SYMBOL Connect\n$FORGET_SYMBOL Forget\n$BACK_SYMBOL Back" "$network_name")
    
    if ! handle_escape show_saved_networks "$action" || [[ "$action" == "$BACK_SYMBOL Back" ]]; then
        show_saved_networks
        return
    fi
    
    case "$action" in
        "$CONNECT_SYMBOL Connect")
            notify "Connecting" "Connecting to $network_name..." "low"
            if nmcli connection up "$network_name"; then
                notify "Connected" "Successfully connected to $network_name" "normal"
            else
                notify "Connection Failed" "Failed to connect to $network_name" "critical"
            fi
            ;;
        "$FORGET_SYMBOL Forget")
            if nmcli connection delete "$network_name"; then
                notify "Success" "Network $network_name has been forgotten" "normal"
            else
                notify "Error" "Failed to forget network $network_name" "critical"
            fi
            show_saved_networks
            ;;
    esac
}

show_settings() {
    local network_status=$(nmcli networking)
    local network_toggle_text="$([[ "$network_status" == "enabled" ]] && echo "$NETWORK_TOGGLE_SYMBOL Disable Networking" || echo "$NETWORK_TOGGLE_SYMBOL Enable Networking")"
    
    local options="$network_toggle_text\n$HIDDEN_NETWORK_SYMBOL Connect to Hidden Network\n$SAVED_SYMBOL Show Saved Networks\n$BACK_SYMBOL Back"
    local selection=$(show_menu "$options" "Settings")
    
    if ! handle_escape main "$selection" || [[ "$selection" == "$BACK_SYMBOL Back" ]]; then
        main
        return
    fi
    
    case "$selection" in
        "$NETWORK_TOGGLE_SYMBOL Disable Networking")
            if nmcli networking off; then
                notify "Networking Disabled" "All network connections have been disabled" "normal"
            else
                notify "Error" "Failed to disable networking" "critical"
            fi
            show_settings
            ;;
        "$NETWORK_TOGGLE_SYMBOL Enable Networking")
            if nmcli networking on; then
                notify "Networking Enabled" "Network connections have been enabled" "normal"
            else
                notify "Error" "Failed to enable networking" "critical"
            fi
            show_settings
            ;;
        "$HIDDEN_NETWORK_SYMBOL Connect to Hidden Network")
            connect_hidden_network
            ;;
        "$SAVED_SYMBOL Show Saved Networks")
            show_saved_networks
            ;;
    esac
}

main() {
    notify "Network Manager" "Scanning for networks..." "low"
    local networks=$(get_networks)
    local selection=$(show_menu "$REFRESH_SYMBOL Refresh\n$SETTINGS_SYMBOL Settings\n$networks" "WiFi Networks")
    
    if ! handle_escape exit "$selection"; then
        exit 0
    fi
    
    case "$selection" in
        "$REFRESH_SYMBOL Refresh")
            notify "Refreshing" "Scanning for networks..." "low"
            nmcli device wifi rescan
            main
            ;;
        "$SETTINGS_SYMBOL Settings")
            show_settings
            ;;
        *)
            connect_to_network "$selection"
            ;;
    esac
}

main
