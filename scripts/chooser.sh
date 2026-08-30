#!/bin/sh

notify() {
notify-send "$1" "$2"
}

dmenu_styled() {
dmenu -i -b -fn 'Poppins:size=9' -nb '#1e1e2e' -nf '#cdd6f4' -sb '#f5e0dc' -sf '#1e1e2e' "$@"
}

youtube() {
    query=$(dmenu_styled -p "YouTube Search:")
    [ -z "$query" ] && return

    results=$(yt-dlp \
        --flat-playlist \
        --no-warnings \
        --print '%(id)s	%(title)s	%(uploader)s' \
        "ytsearch15:$query" 2>/dev/null)

    if [ -z "$results" ]; then
        notify "YouTube" "No results found"
        return
    fi

    display=$(printf '%s\n' "$results" | awk -F '\t' '{printf "%d. %s — %s\n", NR, $2, $3}')

    selected=$(printf '%s\n' "$display" |
        dmenu_styled -p "YouTube Results:" -l 15)

    [ -z "$selected" ] && return

    number=$(printf '%s\n' "$selected" | sed 's/^\([0-9]*\)\..*/\1/')
    video=$(printf '%s\n' "$results" | sed -n "${number}p")
    video_id=$(printf '%s\n' "$video" | cut -f1)

    [ -z "$video_id" ] && return

    url="https://www.youtube.com/watch?v=$video_id"

    subtitle_dir="${XDG_CACHE_HOME:-$HOME/.cache}/chooser-subs"
    mkdir -p "$subtitle_dir"

    rm -f "$subtitle_dir/$video_id".*.vtt

    yt-dlp \
        --no-warnings \
        --skip-download \
        --write-subs \
        --write-auto-subs \
        --sub-langs "en.*" \
        --sub-format "vtt" \
        -o "$subtitle_dir/%(id)s.%(ext)s" \
        "$url" >/dev/null 2>&1

    subtitle=$(find "$subtitle_dir" \
        -maxdepth 1 \
        -type f \
        -name "$video_id.*.vtt" \
        -print -quit)

    if [ -n "$subtitle" ]; then
        mpv --sub-file="$subtitle" "$url"
    else
        mpv "$url"
    fi
}

wifi_menu() {
choice=$(printf '%s\n' "Connect WiFi" "Disconnect WiFi" "ProtonVPN Connect" "ProtonVPN Disconnect" | dmenu_styled -p "WiFi/VPN:")

case "$choice" in
    "Connect WiFi")
        nmcli radio wifi on

        networks=$(nmcli -t -f SSID,SIGNAL dev wifi list --rescan yes 2>/dev/null | awk -F: '$1 != "" {print $2 "% " $1}' | sort -rn)

        [ -z "$networks" ] && {
            notify "WiFi" "No networks found"
            return
        }

        selected=$(printf '%s\n' "$networks" | dmenu_styled -p "Select WiFi:" -l 10)
        [ -z "$selected" ] && return

        ssid=$(printf '%s\n' "$selected" | sed 's/^[0-9]*% //')
        password=$(dmenu_styled -p "Password:")
        [ -z "$password" ] && return

        if nmcli dev wifi connect "$ssid" password "$password"; then
            notify "WiFi" "Connected to $ssid"
        else
            notify "WiFi" "Failed to connect to $ssid"
        fi
        ;;

    "Disconnect WiFi")
        connection=$(nmcli -t -f NAME,TYPE con show --active | awk -F: '$2 == "802-11-wireless" {print $1; exit}')

        if [ -n "$connection" ]; then
            if nmcli con down "$connection"; then
                notify "WiFi" "Disconnected from $connection"
            fi
        else
            notify "WiFi" "No active WiFi connection"
        fi
        ;;

    "ProtonVPN Connect")
        kitty --hold -e protonvpn connect
        ;;

    "ProtonVPN Disconnect")
        if protonvpn disconnect; then
            notify "ProtonVPN" "Disconnected"
        else
            notify "ProtonVPN" "Failed to disconnect"
        fi
        ;;
   esac

}

bluetooth_menu() {
choice=$(printf '%s\n' "Connect Device" "Disconnect Device" | dmenu_styled -p "Bluetooth:")

case "$choice" in
    "Connect Device")
        bluetoothctl power on >/dev/null 2>&1
        bluetoothctl scan on >/dev/null 2>&1 &
        scan_pid=$!

        kill "$scan_pid" >/dev/null 2>&1 || true
        bluetoothctl scan off >/dev/null 2>&1

        devices=$(bluetoothctl devices)

        [ -z "$devices" ] && {
            notify "Bluetooth" "No devices found"
            return
        }

        selected=$(printf '%s\n' "$devices" | sed 's/^Device [^ ]* //' | dmenu_styled -p "Connect:" -l 10)
        [ -z "$selected" ] && return

        mac=$(printf '%s\n' "$devices" | awk -v name="$selected" '$0 ~ "Device [^ ]* " name "$" {print $2; exit}')

        [ -z "$mac" ] && {
            notify "Bluetooth" "Device not found"
            return
        }

        bluetoothctl trust "$mac" >/dev/null 2>&1
        bluetoothctl pair "$mac" >/dev/null 2>&1
        bluetoothctl connect "$mac" >/dev/null 2>&1

        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            notify "Bluetooth" "Connected to $selected"
        else
            notify "Bluetooth" "Failed to connect to $selected"
        fi
        ;;

    "Disconnect Device")
        connected=""

        while read -r mac; do
            [ -z "$mac" ] && continue

            if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
                name=$(bluetoothctl info "$mac" 2>/dev/null | sed -n 's/^[[:space:]]*Name: //p' | head -n 1)
                [ -z "$name" ] && name="$mac"
                connected="${connected}${mac} — ${name}"$'\n'
            fi
        done < <(bluetoothctl devices | awk '{print $2}')

        [ -z "$connected" ] && {
            notify "Bluetooth" "No devices connected"
            return
        }

        selected=$(printf '%s' "$connected" | dmenu_styled -p "Disconnect:" -l 10)
        [ -z "$selected" ] && return

        mac=$(printf '%s\n' "$selected" | awk '{print $1}')

        if bluetoothctl disconnect "$mac" >/dev/null 2>&1; then
            notify "Bluetooth" "Disconnected"
        else
            notify "Bluetooth" "Failed to disconnect"
        fi
        ;;
esac

}

sound_menu() {
    sinks=$(pactl -f json list sinks)

    selected=$(pactl list sinks | awk '
        /^Sink #/ {
            id=$2
            sub("#", "", id)
        }
        /^[[:space:]]*Description:/ {
            desc=$0
            sub(/^[[:space:]]*Description: /, "", desc)
            print id "\t" desc
        }
    ' | dmenu_styled -p "Output:" -l 10)

    [ -z "$selected" ] && return

    sink_id=$(printf '%s\n' "$selected" | cut -f1)

    pactl set-default-sink "$sink_id"

    notify "Sound" "Output changed"
}

monitor_menu() {
choice=$(printf '%s\n' "Extend Right" "Extend Left" "Mirror" "HDMI Only" "Laptop Only" "Turn Off" | dmenu_styled -p "Monitor Preset:")

case "$choice" in
    "Extend Right")
        xrandr --output HDMI-1 --auto --right-of eDP-1 --output eDP-1 --primary
        ;;
    "Extend Left")
        xrandr --output HDMI-1 --auto --left-of eDP-1 --output eDP-1 --primary
        ;;
    "Mirror")
        xrandr --output HDMI-1 --auto --same-as eDP-1 --output eDP-1 --primary
        ;;
    "HDMI Only")
        xrandr --output eDP-1 --off --output HDMI-1 --auto --primary
        ;;
    "Laptop Only")
        xrandr --output HDMI-1 --off --output eDP-1 --auto --primary
        ;;
    "Turn Off")
        xrandr --output HDMI-1 --off
        ;;
    *)
        return
        ;;
esac

notify "Monitor" "$choice"

}

main_choice=$(printf '%s\n' "YouTube" "Go to Arch" "Ollama" "Sound" "Monitor Preset" "WiFi" "Bluetooth" | dmenu_styled -p "Choose:")

case "$main_choice" in
"YouTube")
youtube
;;
"Go to Arch")
kitty --hold -e ssh -X piotr@100.127.87.20
;;
"Ollama")
kitty --hold -e ollama run llama3.2
;;
"Sound")
sound_menu
;;
"Monitor Preset")
monitor_menu
;;
"WiFi")
wifi_menu
;;
"Bluetooth")
bluetooth_menu
;;
esac
