#!/usr/bin/env bash

notify() {
    notify-send "$1" "$2"
}

wifi_menu() {
    local choice networks selected ssid password connection

    choice=$(
        printf '%s\n' \
            "Connect WiFi" \
            "Disconnect WiFi" |
            rofi -dmenu -i -p "WiFi:"
    )

    case "$choice" in
        "Connect WiFi")
            nmcli radio wifi on

            networks=$(
                nmcli -t -f SSID,SIGNAL dev wifi list --rescan yes 2>/dev/null |
                    awk -F: '$1 != "" {print $2 "% " $1}' |
                    sort -rn
            )

            if [ -z "$networks" ]; then
                notify "WiFi" "No networks found"
                return
            fi

            selected=$(
                printf '%s\n' "$networks" |
                    rofi -dmenu -i -p "Select WiFi:" -lines 10
            )

            [ -z "$selected" ] && return

            ssid=$(printf '%s\n' "$selected" |
                sed 's/^[0-9]*% //')

            password=$(rofi -dmenu -i -p "Password:")
            [ -z "$password" ] && return

            if nmcli dev wifi connect "$ssid" password "$password"; then
                notify "WiFi" "Connected to $ssid"
            else
                notify "WiFi" "Failed to connect to $ssid"
            fi
            ;;

        "Disconnect WiFi")
            connection=$(
                nmcli -t -f NAME,TYPE con show --active |
                    awk -F: '$2 == "802-11-wireless" {print $1; exit}'
            )

            if [ -n "$connection" ]; then
                if nmcli con down "$connection"; then
                    notify "WiFi" "Disconnected from $connection"
                else
                    notify "WiFi" "Failed to disconnect"
                fi
            else
                notify "WiFi" "No active WiFi connection"
            fi
            ;;

esac
}

vms_menu() {
    local vm

    vm=$(
        virsh list --all --name |
            sed '/^$/d' |
            rofi -dmenu -i -p "Start VM:" -lines 10
    )

    [ -z "$vm" ] && return

    if virsh start "$vm"; then
        virt-viewer -w "$vm"
    else
        notify "Virtual Machine" "Could not start $vm"
    fi
}

notify() {
    command -v notify-send >/dev/null && notify-send "$1" "$2"
}

bt_power_on() {
    bluetoothctl show | grep -q "Powered: yes" && return 0
    bluetoothctl power on >/dev/null 2>&1
}

bt_scan() {
    local duration="${1:-5}"
    bluetoothctl --timeout "$duration" scan on >/dev/null 2>&1 &
    sleep "$duration"
    wait 2>/dev/null || true
}

bt_is_connected() {
    bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes"
}

bt_list_devices() {
    local filter="$1" mac name
    bluetoothctl devices | while read -r _ mac name; do
        [ -z "$mac" ] && continue

        if bt_is_connected "$mac"; then
            [ "$filter" = "connected" ] && printf '%s — %s\n' "$mac" "${name:-$mac}"
        else
            [ "$filter" = "disconnected" ] && printf '%s — %s\n' "$mac" "${name:-$mac}"
        fi
    done
}

bt_pick_device() {
    local prompt="$1" devices="$2"
    [ -z "$devices" ] && { notify "Bluetooth" "No devices found"; return 1; }
    printf '%s\n' "$devices" | rofi -dmenu -i -p "$prompt" -lines 10
}

bt_reconnect() {
    bt_power_on || { notify "Bluetooth" "Failed to power on"; return; }
    bt_scan 2
    notify "Bluetooth" "Reconnect scan complete"
}

bt_connect() {
    bt_power_on || { notify "Bluetooth" "Failed to power on"; return; }

    bluetoothctl agent on >/dev/null 2>&1
    bluetoothctl default-agent >/dev/null 2>&1

    bt_scan 5

    local selected mac name
    selected=$(bt_pick_device "Connect:" "$(bt_list_devices disconnected)") || return
    [ -z "$selected" ] && return

    mac=${selected%% *}
    name=${selected#* — }

    bluetoothctl trust "$mac" >/dev/null 2>&1
    bluetoothctl pair  "$mac" >/dev/null 2>&1 || true

    if bluetoothctl connect "$mac" >/dev/null 2>&1; then
        notify "Bluetooth" "Connected to $name"
    else
        notify "Bluetooth" "Failed to connect to $name"
    fi
}

bt_disconnect() {
    local selected mac name
    selected=$(bt_pick_device "Disconnect:" "$(bt_list_devices connected)") || return
    [ -z "$selected" ] && return

    mac=${selected%% *}
    name=${selected#* — }

    if bluetoothctl disconnect "$mac" >/dev/null 2>&1; then
        notify "Bluetooth" "Disconnected from $name"
    else
        notify "Bluetooth" "Failed to disconnect from $name"
    fi
}

bluetooth_menu() {
    local choice
    choice=$(printf '%s\n' \
        "Reconnect Devices" \
        "Connect Device" \
        "Disconnect Device" |
        rofi -dmenu -i -p "Bluetooth:") || return

    case "$choice" in
        "Reconnect Devices")  bt_reconnect  ;;
        "Connect Device")     bt_connect    ;;
        "Disconnect Device")  bt_disconnect ;;
    esac
}

sound_menu() {
    local selected sink_id

    selected=$(
        pactl list sinks short |
            awk '{print $1 "\t" $2}' |
            rofi -dmenu -i -p "Output:" -lines 10
    )

    [ -z "$selected" ] && return

    sink_id=$(printf '%s\n' "$selected" | cut -f1)

    pactl set-default-sink "$sink_id"
    notify "Sound" "Output changed"
}

main_menu() {
    local choice

    choice=$(
        printf '%s\n' \
	    "Watch" \
            "Ollama" \
            "Sound" \
            "VMs" \
            "WiFi" \
	    "SSH" \
            "Bluetooth" |
            rofi -dmenu -i -p "Choose:"
    )

    case "$choice" in
	"Watch")
	modules=$(printf '%s\n' "YouTube" "Twitch" "Anime" | rofi -dmenu -i -p "Watch")
	case "$modules" in

	   "YouTube")
		/etc/nixos/scripts/chooser/youtube.sh &
            	;;

	   "Anime")
	    	/etc/nixos/scripts/chooser/ani-cli.sh --rofi &
	    	;;

	   "Twitch")
	    	channels=$(cat ~/.local/state/twitchmpv/recent_channels)
	    	chosen=$(echo "$channels" | rofi -dmenu -i -p "Twitch")
	    	[ -n "$chosen" ] && /etc/nixos/scripts/chooser/twitchmpv.sh "$chosen"
	    	;;
	esac
	    ;;
	
        "Ollama")
            kitty --hold -e ollama run llama3.2
            ;;

        "Sound")
            sound_menu
            ;;

        "VMs")
            vms_menu
            ;;

        "WiFi")
            wifi_menu
            ;;

	"SSH")
	    rofi -show ssh
	    ;;

        "Bluetooth")
            bluetooth_menu
            ;;
    esac
}

main_menu
