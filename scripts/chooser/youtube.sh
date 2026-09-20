#!/bin/sh

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
        mpv --sub-file="$subtitle" "$url" --volume=50
    else
        mpv "$url" --volume=50
    fi
}

youtube
