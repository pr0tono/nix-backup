#!/usr/bin/env bash

notify() {
    notify-send "$1" "$2"
}

youtube() {
    local query results display selected number video_id url
    local subtitle_dir subtitle
    local tab

    tab=$(printf '\t')

    query=$(rofi -dmenu -i -p "YouTube Search:")
    [ -z "$query" ] && return

    results=$(
        yt-dlp \
            --flat-playlist \
            --playlist-end 15 \
            --no-warnings \
            --skip-download \
            --js-runtimes deno \
            --print "%(id)s${tab}%(title)s${tab}%(channel)s" \
            "ytsearch15:$query" 2>/dev/null
    )

    if [ -z "$results" ]; then
        notify "YouTube" "No results found"
        return
    fi

    display=$(
        printf '%s\n' "$results" |
            awk -F "$tab" '
                {
                    title = $2
                    channel = $3

                    if (title == "" || title == "NA" || title == "N/A")
                        title = "Untitled video"

                    if (channel == "" || channel == "NA" || channel == "N/A")
                        channel = "Unknown channel"

                    printf "%d. %s — %s\n", NR, title, channel
                }
            '
    )

    selected=$(
        printf '%s\n' "$display" |
            rofi -dmenu -i -p "YouTube Results:" -lines 15
    )

    [ -z "$selected" ] && return

    number=$(
        printf '%s\n' "$selected" |
            sed 's/^\([0-9]*\)\..*/\1/'
    )

    video_id=$(
        printf '%s\n' "$results" |
            sed -n "${number}p" |
            cut -f1
    )

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
        --sub-format vtt \
        -o "$subtitle_dir/%(id)s.%(ext)s" \
        "$url" >/dev/null 2>&1

    subtitle=$(
        find "$subtitle_dir" \
            -maxdepth 1 \
            -type f \
            -name "$video_id.*.vtt" \
            -print -quit
    )

    if [ -n "$subtitle" ]; then
        mpv --sub-file="$subtitle" "$url"
    else
        mpv "$url"
    fi
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

bluetooth_devices() {
    local mode="$1"
    local line data mac name info connected

    while IFS= read -r line; do
        [ -z "$line" ] && continue

        data=${line#Device }
        mac=${data%% *}
        name=${data#"$mac"}
        name=${name# }

        [ -z "$mac" ] && continue
        [ -z "$name" ] && name="$mac"

        info=$(bluetoothctl info "$mac" 2>/dev/null)

        if printf '%s\n' "$info" |
            grep -q '^[[:space:]]*Connected: yes'; then
            connected=yes
        else
            connected=no
        fi

        case "$mode" in
            connected)
                [ "$connected" = yes ] &&
                    printf '%s — %s\n' "$mac" "$name"
                ;;

            disconnected)
                [ "$connected" = no ] &&
                    printf '%s — %s\n' "$mac" "$name"
                ;;
        esac
    done < <(bluetoothctl devices)
}

bluetooth_menu() {
    local choice selected mac device_name
    local scan_pid devices

    choice=$(
        printf '%s\n' \
            "Reconnect Devices" \
            "Connect Device" \
            "Disconnect Device" |
            rofi -dmenu -i -p "Bluetooth:"
    )

    case "$choice" in
        "Reconnect Devices")
            bluetoothctl power on >/dev/null 2>&1

            bluetoothctl scan on >/dev/null 2>&1 &
            scan_pid=$!

            sleep 5

            bluetoothctl scan off >/dev/null 2>&1
            kill "$scan_pid" 2>/dev/null || true
            wait "$scan_pid" 2>/dev/null || true

            notify "Bluetooth" "Device scan completed"
            ;;

        "Connect Device")
            bluetoothctl power on >/dev/null 2>&1 || {
                notify "Bluetooth" "Could not power on Bluetooth"
                return
            }

            bluetoothctl agent on >/dev/null 2>&1
            bluetoothctl default-agent >/dev/null 2>&1

            bluetoothctl scan on >/dev/null 2>&1 &
            scan_pid=$!

            sleep 5

            bluetoothctl scan off >/dev/null 2>&1
            kill "$scan_pid" 2>/dev/null || true
            wait "$scan_pid" 2>/dev/null || true

            devices=$(bluetooth_devices disconnected)

            if [ -z "$devices" ]; then
                notify "Bluetooth" "No offline devices found"
                return
            fi

            selected=$(
                printf '%s\n' "$devices" |
                    rofi -dmenu -i -p "Connect:" -lines 10
            )

            [ -z "$selected" ] && return

            mac=${selected%% *}
            device_name=${selected#* — }

            bluetoothctl trust "$mac" >/dev/null 2>&1
            bluetoothctl pair "$mac" >/dev/null 2>&1 || true

            if bluetoothctl connect "$mac" >/dev/null 2>&1; then
                notify "Bluetooth" "Connected to $device_name"
            else
                notify "Bluetooth" "Failed to connect to $device_name"
            fi
            ;;

        "Disconnect Device")
            devices=$(bluetooth_devices connected)

            if [ -z "$devices" ]; then
                notify "Bluetooth" "No devices connected"
                return
            fi

            selected=$(
                printf '%s\n' "$devices" |
                    rofi -dmenu -i -p "Disconnect:" -lines 10
            )

            [ -z "$selected" ] && return

            mac=${selected%% *}

            if bluetoothctl disconnect "$mac" >/dev/null 2>&1; then
                notify "Bluetooth" "Disconnected"
            else
                notify "Bluetooth" "Failed to disconnect"
            fi
            ;;
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

monitor_menu() {
    local choice

    choice=$(
        printf '%s\n' \
            "Extend Right" \
            "Extend Left" \
            "Mirror" \
            "HDMI Only" \
            "Laptop Only" \
            "Turn Off" |
            rofi -dmenu -i -p "Monitor Preset:"
    )

    case "$choice" in
        "Extend Right")
            xrandr \
                --output HDMI-1 --auto --right-of eDP-1 \
                --output eDP-1 --primary
            ;;

        "Extend Left")
            xrandr \
                --output HDMI-1 --auto --left-of eDP-1 \
                --output eDP-1 --primary
            ;;

        "Mirror")
            xrandr \
                --output HDMI-1 --auto --same-as eDP-1 \
                --output eDP-1 --primary
            ;;

        "HDMI Only")
            xrandr \
                --output eDP-1 --off \
                --output HDMI-1 --auto --primary
            ;;

        "Laptop Only")
            xrandr \
                --output HDMI-1 --off \
                --output eDP-1 --auto --primary
            ;;

        "Turn Off")
            xrandr --output HDMI-1 --off
            return
            ;;
    esac

    [ -n "$choice" ] && notify "Monitor" "$choice"
}

main_menu() {
    local choice

    choice=$(
        printf '%s\n' \
            "YouTube" \
            "Ollama" \
            "Sound" \
            "Monitor Preset" \
            "VMs" \
            "WiFi" \
	    "SSH" \
            "Bluetooth" |
            rofi -dmenu -i -p "Choose:"
    )

    case "$choice" in
        "YouTube")
            youtube
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
