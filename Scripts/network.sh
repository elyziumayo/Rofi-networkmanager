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

# Custom rofi command function for settings menu
rofi_cmd_settings() {
    if [[ -f "$THEME_FILE" ]]; then
        rofi -theme "$THEME_FILE" \
             -theme-str 'window{width:400px;}' \
             -theme-str 'listview{columns:1; lines:4; spacing:5px;}' \
             -theme-str 'element{padding:9px;}' \
             -theme-str 'element-text{font:"JetBrains Mono Nerd Font Propo 10";}' \
             -theme-str 'inputbar{background-image:none; padding:8px;}' \
             -theme-str 'entry{padding:8px;}' \
             -theme-str 'textbox-prompt-colon{background-color:	#6670ad;str:"  ";padding:8px;}'\
             "$@" -kb-cancel "Escape"
    else
        rofi "$@" -kb-cancel "Escape"
    fi
}

# Custom rofi command function for hidden network SSID input
rofi_cmd_hidden_ssid() {
    if [[ -f "$THEME_FILE" ]]; then
        rofi -theme "$THEME_FILE" \
             -theme-str 'window{width:350px;}' \
             -theme-str 'mainbox{children:["message","inputbar"];}' \
             -theme-str 'inputbar{background-image:none; padding:10px;}' \
             -theme-str 'textbox{font:"JetBrains Mono Nerd Font Propo 10";padding:12px;expand:false;}' \
             -theme-str 'textbox-prompt-colon{background-color:	#6670ad;str:" 👻 ";padding:7px;}' \
             -theme-str 'textbox{background-color:#656291;}' \
             -theme-str 'entry{placeholder:"Enter hidden network name";padding:7px;}' \
             -theme-str 'listview{lines:0;}' \
             "$@" -kb-cancel "Escape"
    else
        rofi "$@" -kb-cancel "Escape"
    fi
}

# Custom rofi command function for security selection
rofi_cmd_security() {
    if [[ -f "$THEME_FILE" ]]; then
        rofi -theme "$THEME_FILE" \
             -theme-str 'window{width:345px;}' \
             -theme-str 'listview{columns:1; lines:3;}' \
             -theme-str 'element{padding:10px;}' \
             -theme-str 'element-text{font:"JetBrains Mono Nerd Font Propo 10";}' \
             -theme-str 'inputbar{background-image:none; padding:8px;}' \
             -theme-str 'textbox-prompt-colon{background-color:#6670ad;str:"  ";padding:8px;}' \
             "$@" -kb-cancel "Escape"
    else
        rofi "$@" -kb-cancel "Escape"
    fi
}

# Custom rofi command function for saved networks
rofi_cmd_saved() {
    if [[ -f "$THEME_FILE" ]]; then
        rofi -theme "$THEME_FILE" \
             -theme-str 'window{width:345px;}' \
             -theme-str 'listview{columns:1;lines:5;}' \
             -theme-str 'element{padding:8px;}' \
             -theme-str 'element-text{font:"JetBrains Mono Nerd Font Propo 10";}' \
             -theme-str 'inputbar{background-image:none; padding:8px;}' \
             -theme-str 'textbox-prompt-colon{background-color:#6670ad;str:"  ";padding:8px;}' \
             "$@" -kb-cancel "Escape"
    else
        rofi "$@" -kb-cancel "Escape"
    fi
}

# Custom rofi command function for network actions (Connect/Forget/Back)
rofi_cmd_actions() {
    if [[ -f "$THEME_FILE" ]]; then
        rofi -theme "$THEME_FILE" \
             -theme-str 'window{width:345px;}' \
             -theme-str 'listview{columns:1; lines:3; spacing:3px;}' \
             -theme-str 'element{padding:10px;}' \
             -theme-str 'element-text{font:"JetBrains Mono Nerd Font Propo 10";}' \
             -theme-str 'inputbar{background-image:none; padding:8px;}' \
             -theme-str 'textbox-prompt-colon{background-color:#6670ad;str:"  ";padding:8px;}' \
             "$@" -kb-cancel "Escape"
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
        rofi_cmd -theme-str 'mainbox{children:["message","inputbar"];}'\
                 -theme-str 'window{width:345px;}'\
                 -theme-str 'inputbar{background-image:none;padding:7px;}'\
                 -theme-str 'message{margin:3px;}textbox{background-color:#656291;font:"JetBrains Mono Nerd Font Propo 10";padding:10px;expand:false;}'\
                 -theme-str 'textbox-prompt-colon{background-color:	#6670ad;str:"  ";}'\
                 -theme-str 'entry { placeholder:"Password";}'\
                 -theme-str 'listview{lines:0;}'\
                -dmenu -p "$prompt" -password -lines "$lines" -mesg "  | $network_name"
    else
        rofi_cmd -dmenu -p "$prompt" -lines "$lines" -p "@"
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
    
    echo " ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟ ͟  "
    echo " SSID                       BSSID        SECURITY   BARS  SIGNAL  BANDWIDTH  MODE  CHAN    RATE"
    echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
     
    nmcli -f SSID,BSSID,SECURITY,BARS,SIGNAL,BANDWIDTH,MODE,CHAN,RATE device wifi list | tail -n +2 | while read -r line; do
        format_network_line "$line" "$current_ssid"
    done
}

get_saved_networks() {
    nmcli -g NAME,UUID,TYPE connection show | sort | while IFS=: read -r name uuid type; do
        case "$type" in
            "802-11-wireless") echo "$WIFI_SYMBOL $name" ;;
            "802-3-ethernet") echo "$WIRED_SYMBOL $name" ;;
            "loopback"|"lo") echo "$LOOPBACK_SYMBOL $name" ;;
            *) echo "$OTHER_SYMBOL $name" ;;
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
            nmcli connection delete "$ssid" 2>/dev/null || true
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
    
    # Check if network is already saved
    if nmcli connection show | grep -q "^$ssid "; then
        notify "Connecting" "Connecting to saved network $ssid..." "low"
        if nmcli connection up "$ssid"; then
            notify "Connected" "Successfully connected to $ssid" "normal"
        else
            notify "Connection Failed" "Failed to connect to $ssid" "critical"
        fi
        return
    fi
    
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
    # Use custom rofi command for SSID input
    local ssid=$(rofi_cmd_hidden_ssid -dmenu -p "Hidden Network" -lines 0 -mesg "👻 | Enter SSID name")
    handle_escape show_settings "$ssid" || return
    
    # Use custom rofi command for security selection
    local security=$(echo -e "WPA/WPA2\nWEP\nNone" | rofi_cmd_security -dmenu -i -p "Security")
    handle_escape show_settings "$security" || return
    
    if [[ "$security" != "None" ]]; then
        while true; do
            local password=$(get_input "Password" true 0 "$ssid")
            handle_escape show_settings "$password" "$ssid" || return
            
            notify "Connecting" "Connecting to hidden network $ssid..." "low"
            
            local connect_output
            connect_output=$(nmcli device wifi connect "$ssid" password "$password" hidden yes 2>&1)
            local exit_code=$?
            
            if [[ $exit_code -eq 0 ]]; then
                notify "Connected" "Successfully connected to hidden network $ssid" "normal"
                return 0
            else
                if echo "$connect_output" | grep -q "No network with SSID"; then
                    notify "Network Not Found" "Hidden network '$ssid' does not exist or is not in range" "critical"
                    return 1
                else
                    notify "Connection Failed" "Wrong password for $ssid. Please try again." "critical"
                fi
            fi
        done
    else
        notify "Connecting" "Connecting to hidden network $ssid..." "low"
        local connect_output
        connect_output=$(nmcli device wifi connect "$ssid" hidden yes 2>&1)
        local exit_code=$?
        
        if [[ $exit_code -eq 0 ]]; then
            notify "Connected" "Successfully connected to hidden network $ssid" "normal"
        else
            if echo "$connect_output" | grep -q "No network with SSID"; then
                notify "Network Not Found" "Hidden network '$ssid' does not exist or is not in range" "critical"
            else
                notify "Connection Failed" "Failed to connect to hidden network $ssid" "critical"
            fi
        fi
    fi
}

show_saved_networks() {
    local saved=$(get_saved_networks)
    
    # Use custom rofi command for saved networks
    local selection=$(echo -e "$BACK_SYMBOL Back\n$saved" | rofi_cmd_saved -dmenu -i -p "Saved Networks")
    
    if ! handle_escape show_settings "$selection" || [[ "$selection" == "$BACK_SYMBOL Back" ]]; then
        show_settings
        return
    fi
    
    local network_name=$(echo "$selection" | sed -E "s/^[^ ]+ //")
    # Use custom rofi command for actions
    local action=$(echo -e "$CONNECT_SYMBOL Connect\n$FORGET_SYMBOL Forget\n$BACK_SYMBOL Back" | rofi_cmd_actions -dmenu -i -p "$network_name")
    
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
    
    # Use custom rofi command for settings menu
    local selection=$(echo -e "$options" | rofi_cmd_settings -dmenu -i -p "Settings")
    
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
