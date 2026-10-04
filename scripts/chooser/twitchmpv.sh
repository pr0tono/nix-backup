#!/usr/bin/env bash
# original script copied from https://github.com/Aethar01/twitchmpv/tree/main
args() {

    if [ -n "$1" ] && [[ ! "$1" =~ ^\-.+ ]]; then
        CHANNEL=$1
        shift
    fi

    local options="hc:q:n:adsvli"
    local longoptions="help,config:,quality:,name:,audio-only,disown,silent,verbose,low-latency,ignore-config"
    local parsed_args
    parsed_args=$(getopt -o "$options" --long "$longoptions" -n "$(basename "$0")" -- "$@") || {
        usage
        exit 1
    }


    eval set -- "$parsed_args"
    while true; do
        case $1 in
            -h | --help)
                usage
                exit 0
                ;;
            -c | --config)
                shift
                CONFIG_FILE=$1
                ;;
            -q | --quality)
                shift
                QUALITY=$1
                ;;
            -n | --name)
                shift
                CHANNEL=$1
                ;;
            -a | --audio-only)
                NO_VIDEO=1
                ;;
            -d | --disown)
                DISOWN=1
                ;;
            -s | --silent)
                SILENT=1
                ;;
            -v | --verbose)
                DEBUG=1
                ;;
            -l | --low-latency)
                LOW_LATENCY=1
                ;;
            -i | --ignore-config)
                IGNORE_CONFIG=1
                ;;
            --)
                shift
                if [ -z "$CHANNEL" ] && [ -n "$1" ]; then
                    CHANNEL=$1
                    shift
                fi
                # add all remaining arguments to array of arguments
                for arg; do
                    OPT_ARRAY+=("$arg")
                done
                break
                ;;
            *)
                usage
                exit 1
                ;;
        esac
        shift
    done
}

usage() {
    cat <<'EOF'
    Usage: twitchmpv [channel name or url] [options] -- [streamlink arguments]

    Watch Twitch streams with mpv using streamlink. If no channel is given,
    choose from recent channels with ${PICKER:-fzf}.

    Options:
    -h, --help              Show this help message and exit
    -c, --config <path>     Set the path to the config file
    -q, --quality <quality> Set the quality of the stream
    -n, --name <channel>    Set the name of the twitch channel, can also be a twitch url
    -a, --audio-only        Disable video playback
    -d, --disown            Disown the process (if you run with -a and -d, you can only kill the process manually)
    -s, --silent            Run streamlink in silent mode
    -v, --verbose           Print debug information
    -l, --low-latency       Enable low latency mode
    -i, --ignore-config     Ignore the config file except for the oauth and client id
    --                      Pass additional arguments to streamlink
EOF
}

error() {
    echo "Error: $*" >&2
    exit 1
}

info() {
    if [ "$DEBUG" == 1 ]; then
        echo "Info: $*" >&2
    fi
}

warn() {
    echo "Warning: $*" >&2
}

check_dependencies() {
    if ! [ -x "$(command -v streamlink)" ]; then
        error "streamlink is not installed"
    fi
    if ! [ -x "$(command -v mpv)" ]; then
        error "mpv is not installed"
    fi
    info "Dependencies found"
}

check_config_file() {
    if [ -z "$CONFIG_FILE" ]; then
        CONFIG_FILE="$HOME/.config/twitchmpv/config"
    fi
}

check_picker_dependency() {
    local picker_cmd

    read -r -a picker_cmd <<< "${PICKER:-fzf}"
    if ! [ -x "$(command -v "${picker_cmd[0]}")" ]; then
        error "${picker_cmd[0]} is not installed"
    fi
}

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        info "Config file not found: $CONFIG_FILE"
    fi
    if [ -r "$CONFIG_FILE" ]; then
        info "Loading config file: $CONFIG_FILE"
        while read -r line; do
            if echo "$line" | grep -F = &>/dev/null; then
                if echo "$line" | grep -E '^\s*#' &>/dev/null; then
                    continue
                fi
                if [ "$IGNORE_CONFIG" == 1 ] && ! echo "$line" | grep -E '^(twitchOauth|twitchClientId)' &>/dev/null; then
                    continue
                fi
                line1=$(echo "$line" | tr -d '[:space:]')
                varname=$(echo "$line1" | cut -d '=' -f 1)
                config[$varname]=$(echo "$line1" | cut -d '=' -f 2-)
            fi
        done < "$CONFIG_FILE"
    fi
    
    if [ -z "$DISOWN" ]; then
        DISOWN="${config[disown]}"
        info "Disown set to $DISOWN"
    fi
    if [ -z "$NO_VIDEO" ]; then
        NO_VIDEO="${config[noVideo]}"
        info "No video set to $NO_VIDEO"
    fi
    if [ -z "$SILENT" ]; then
        SILENT="${config[silent]}"
        info "Silent set to $SILENT"
    fi
    if [ -z "$QUALITY" ]; then
        QUALITY="${config[defaultQuality]}"
        info "Quality set to $QUALITY"
    fi
    if [ -z "$LOW_LATENCY" ]; then
        LOW_LATENCY="${config[lowLatency]}"
        info "Low latency set to $LOW_LATENCY"
    fi
}

state_file() {
    if [ -n "$XDG_STATE_HOME" ]; then
        printf '%s\n' "$XDG_STATE_HOME/twitchmpv/recent_channels"
    else
        printf '%s\n' "$HOME/.local/state/twitchmpv/recent_channels"
    fi
}

pick_channel() {
    local file
    local picker_cmd

    file=$(state_file)
    if [ ! -s "$file" ]; then
        usage
        error "Channel name is required and no recent channels were found"
    fi

    check_picker_dependency
    read -r -a picker_cmd <<< "${PICKER:-fzf}"
    CHANNEL=$("${picker_cmd[@]}" < "$file") || error "No channel selected"

    if [ -z "$CHANNEL" ]; then
        error "No channel selected"
    fi
}

save_recent_channel() {
    local file
    local dir
    local line
    local channels=()

    file=$(state_file)
    dir=$(dirname "$file")
    mkdir -p "$dir" || warn "Could not create state directory: $dir"

    channels+=("$CHANNEL")
    if [ -r "$file" ]; then
        while read -r line; do
            if [ -n "$line" ] && [ "$line" != "$CHANNEL" ]; then
                channels+=("$line")
            fi
            if [ "${#channels[@]}" -ge 25 ]; then
                break
            fi
        done < "$file"
    fi

    printf '%s\n' "${channels[@]}" > "$file" || warn "Could not save recent channel: $file"
}

check_channel() {
    if [ -z "$CHANNEL" ]; then
        pick_channel
    fi
    if [[ $CHANNEL == *"twitch.tv"* ]]; then
        STREAM_URL="$CHANNEL"
    else
        STREAM_URL="https://www.twitch.tv/$CHANNEL"
    fi
    info "Channel set to $CHANNEL"
}

check_streamlink_opts() {
    OPT_ARRAY+=(-p mpv
               --twitch-disable-ads)
    if [ -n "${config[twitchOauth]}" ]; then
        OPT_ARRAY+=(--twitch-api-header "Authorization=OAuth ${config[twitchOauth]}")
    fi
    if [ -n "${config[twitchClientId]}" ]; then
        OPT_ARRAY+=(--twitch-api-header "Client-Id=${config[twitchClientId]}")
    fi
    if [ "$NO_VIDEO" == 1 ]; then
        OPT_ARRAY+=(-a --no-video)
    fi
    if [ "$SILENT" == 1 ]; then
        OPT_ARRAY+=(-Q)
    fi
    if [ "$LOW_LATENCY" == 1 ]; then
        OPT_ARRAY+=(--twitch-low-latency)
    fi
    info "Streamlink options: ${OPT_ARRAY[*]}"
}

play_stream() {
    info "Starting streamlink..."
    if [ "$DISOWN" == 1 ]; then
        nohup streamlink "${OPT_ARRAY[@]}" "$STREAM_URL" "$QUALITY" >/dev/null </dev/null &
    else
        streamlink "${OPT_ARRAY[@]}" "$STREAM_URL" "$QUALITY"
    fi
}

main() {
    check_config_file
    load_config
    check_channel
    check_dependencies
    check_streamlink_opts
    save_recent_channel
    play_stream
}

typeset -A config
config=(
    [twitchOauth]="" # Twitch OAuth token
    [twitchClientId]="" # Twitch Client ID
    [defaultQuality]="best" # Default quality
    [disown]=0
    [noVideo]=0
    [silent]=0
    [lowLatency]=0
)

args "$@"
main
