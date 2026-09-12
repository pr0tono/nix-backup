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
choice=$(printf '%s\n' "Connect WiFi" "Disconnect WiFi" | dmenu_styled -p "WiFi:")

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
   esac
}

vms_chooser() {
	vms=$(virsh list --all | sed '1,2d')
	sel=$(echo "$vms" | dmenu_styled -p "Start: " -l 10 -i | awk '{print $2}')
	[ -z "$sel" ] ; exit 0
	virsh start "$sel" ; virt-viewer -w "$sel"
}

bluetooth_menu() {
    local choice
    choice=$(printf '%s\n' "Connect Device" "Disconnect Device" \
        | dmenu_styled -p "Bluetooth:")

    case "$choice" in
        "Connect Device")
            bluetoothctl power on >/dev/null 2>&1
            bluetoothctl scan on >/dev/null 2>&1 &
            local scan_pid=$!
            kill "$scan_pid" 2>/dev/null || true
            wait "$scan_pid" 2>/dev/null
            bluetoothctl scan off >/dev/null 2>&1
            local offline=""
            while IFS=$'\t' read -r mac name; do
                [ -z "$mac" ] && continue
                if ! bluetoothctl info "$mac" 2>/dev/null | grep -q 'Connected: yes'; then
                    [ -z "$name" ] && name="$mac"
                    offline+="${mac}\t${name}"$'\n'
                fi
            done < <(bluetoothctl devices | awk '{mac=$2; $1=$2=""; print mac "\t" $0}')

            [ -z "$offline" ] && { notify "Bluetooth" "No offline devices found"; return; }

            local selected
            selected=$(printf '%s\n' "$offline" | cut -f2- \
                | dmenu_styled -p "Connect:" -l 10)
            [ -z "$selected" ] && return

            local mac
            mac=$(printf '%s\n' "$offline" | awk -F'\t' -v n="$selected" '$2==n {print $1; exit}')
            [ -z "$mac" ] && { notify "Bluetooth" "Device not found"; return; }

            bluetoothctl trust "$mac"   >/dev/null 2>&1
            bluetoothctl pair   "$mac"  >/dev/null 2>&1
            bluetoothctl connect "$mac" >/dev/null 2>&1

            if bluetoothctl info "$mac" 2>/dev/null | grep -q 'Connected: yes'; then
                notify "Bluetooth" "Connected to $selected"
            else
                notify "Bluetooth" "Failed to connect to $selected"
            fi
            ;;

        "Disconnect Device")
            local connected=""
            while IFS=$'\t' read -r mac name; do
                [ -z "$mac" ] && continue
                local info
                info=$(bluetoothctl info "$mac" 2>/dev/null)
                if printf '%s\n' "$info" | grep -q 'Connected: yes'; then
                    [ -z "$name" ] && name="$mac"
                    connected+="${mac} — ${name}"$'\n'
                fi
            done < <(bluetoothctl devices | awk '{mac=$2; $1=$2=""; print mac "\t" $0}')

            [ -z "$connected" ] && { notify "Bluetooth" "No devices connected"; return; }

            local sel
            sel=$(printf '%s' "$connected" | dmenu_styled -p "Disconnect:" -l 10)
            [ -z "$sel" ] && return

            mac=${sel%% *}

            if bluetoothctl disconnect "$mac" >/dev/null 2>&1; then
                notify "Bluetooth" "Disconnected"
            else
                notify "Bluetooth" "Failed to disconnect"
            fi
            ;;
    esac
}

sound_menu() {
    local selected
    selected=$(pactl list sinks short | awk '{print $1"\t"$2}' | dmenu_styled -p "Output:" -l 10)
    [ -z "$selected" ] && return
    pactl set-default-sink "${selected%%	*}"
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
        return
        ;;
esac

notify "Monitor" "$choice"

}

main_choice=$(printf '%s\n' "YouTube" "Go to Arch" "Ollama" "Sound" "Monitor Preset" "Vms" "WiFi" "Bluetooth" | dmenu_styled -p "Choose:")

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
"Vms")
vms_chooser
;;
"WiFi")
wifi_menu
;;
"Bluetooth")
bluetooth_menu
;;
esac
