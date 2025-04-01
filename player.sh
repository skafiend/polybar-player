#!/bin/bash

_COLOR="%%{F$PRIMARY_COLOR}"
COLOR_="%%{F-}"
LEFT=""
RIGHT=""

_print_hours() {
    printf ' %02d:%02d:%02d ' "$1" "$2" "$3"
}

_print_minutes() {
    printf ' %02d:%02d ' "$1" "$2"
}

_trim_title() {
    if [ ${#1} -gt 55 ]; then
        TITLE="$(printf '%.55s' "$1")..."
    else
        TITLE="$1"
    fi
}

_run_action() {
    case $1 in
        left)
            eval $LEFT;;
        right)
            eval $RIGHT;;
        up)
            eval $UP;;
        down)
            eval $DOWN;;
    esac
}

_getdata() {
    case $1 in
        mpv)
        MPV_SOCKET='/tmp/mpvsocket'
        TITLE=$(echo '{ "command": ["get_property", "media-title"] }' | socat - $MPV_SOCKET | jq -r .data)
        # in seconds
        POSITION=$(echo '{ "command": ["get_property_string", "time-pos"] }' | socat - $MPV_SOCKET  | jq -r .data | cut -d'.' -f 1)
        DURATION=$(echo '{ "command": ["get_property_string", "duration"] }' | socat - $MPV_SOCKET | jq -r .data | cut -d'.' -f 1)
        LEFT="echo 'cycle pause' | socat - $MPV_SOCKET" 
        RIGHT="echo 'quit' | socat - $MPV_SOCKET" 
        UP="echo 'add volume +5' | socat - $MPV_SOCKET" 
        DOWN="echo 'add volume -5' | socat - $MPV_SOCKET" 
        ;;

        cmus)
        NAME=$(cmus-remote -C status | grep "tag title" | cut -f 3- -d ' ')
        ARTIST=$(cmus-remote -C status | grep "tag artist" | cut -f 3- -d ' ')
        TITLE="$ARTIST - $NAME"
        POSITION=$(cmus-remote -C status | grep "position" | cut -f 2 -d ' ')
        DURATION=$(cmus-remote -C status | grep "duration" | cut -f 2 -d ' ')
        LEFT="cmus-remote --pause"
        RIGHT="pkill -x cmus"
        UP="cmus-remote --volume +5%"
        DOWN="cmus-remote --volume -5%"
        ;;
    esac
}

# name position duration
_display_data() {
    # ' - ' - cmus stopped and we didn't get any info
    if [[ ! -z "$1" && "$1" != ' - ' ]]; then
        printf "$_COLOR$1$COLOR_" 
        $2
        printf "$_COLOR/$COLOR_"
        $3
        printf "$_COLOR|$COLOR_"
    else
        echo ""
    fi
}

# assume: only one thing is running at a time
if pgrep -f mpv_audiobook > /dev/null; then
    _getdata mpv 
    _trim_title "$TITLE"
    _display_data "$TITLE" \
                 "_print_hours $((POSITION/3600)) $((POSITION%3600/60)) $((POSITION%60))" \
                 "_print_hours $((DURATION/3600)) $((DURATION%3600/60)) $((DURATION%60))"
    _run_action $1
else
    _getdata cmus
    _trim_title "$TITLE"
    _display_data "$TITLE"  \
                  "_print_minutes $((POSITION%3600/60)) $((POSITION%60))" \
                  "_print_minutes $((DURATION%3600/60)) $((DURATION%60))"
    _run_action $1
fi
