#!/bin/bash

MVP="$(pgrep -f mpv_audiobook)"
CMUS="$(pgrep -x cmus)"

if [[ -z $MVP ]] && [[ -z $CMUS ]]; then
    echo
    exit 99
fi

_COLOR="%%{F$PRIMARY_COLOR}"
COLOR_="%%{F-}"
MAX_TITLE=35
ACTION="$1"

#echo "CMUS: $CMUS"
#echo "MPV: "$MVP""

# time_in_seconds 
# everything is converted into hours/minutes/seconds accordingly
_time() {
    case $2 in
        "00:00")
            printf '%02d:%02d' "$(($1%3600/60))" "$(($1%60))"
        ;;
        "00:00:00")
            printf '%02d:%02d:%02d' "$(($1/3600))" "$(($1%3600/60))" "$(($1%60))"
        ;;
    esac
}


_trim_title() {
    if [ ${#1} -gt $MAX_TITLE ]; then
        # * is a placeholder for an integer (in this case, the value of MAX_TITLE),
        TITLE="$(printf '%.*s' "$MAX_TITLE" "$1")..."
    else
        TITLE="$1"
    fi
}

# action will work only when a $1 parameter for the script is not empty
# for example config.ini:
# click-left = ~/.config/polybar/player.sh play
_run_action() {
    case $1 in
        play)
            eval $PLAY;;
        exit)
            eval $EXIT;;
        up)
            eval $UP;;
        down)
            eval $DOWN;;
    esac
}

_get_data() {
    case $1 in
        mpv)
        MPV_SOCKET='/tmp/mpvsocket'
        if ! [[ -S $MPV_SOCKET ]]; then
            exit 77
        fi
        # from tags
        TITLE=$(echo '{ "command": ["get_property", "path"] }' | socat - $MPV_SOCKET | jq -r .data)
        TITLE=${TITLE##*/}
        POSITION=$(echo '{ "command": ["get_property_string", "time-pos"] }' | socat - $MPV_SOCKET  | jq -r .data | cut -d'.' -f 1)
        DURATION=$(echo '{ "command": ["get_property_string", "duration"] }' | socat - $MPV_SOCKET | jq -r .data | cut -d'.' -f 1)
        PLAY="echo 'cycle pause' | socat - $MPV_SOCKET" 
        EXIT="echo 'quit' | socat - $MPV_SOCKET" 
        UP="echo 'add volume +5' | socat - $MPV_SOCKET" 
        DOWN="echo 'add volume -5' | socat - $MPV_SOCKET" 
        ;;

        cmus)
        INFO==$(cmus-remote -C status)
        if [[ $? -ne 0 ]]; then
            exit 88
        fi
        NAME=$(echo "$INFO" | grep "tag title" | cut -f 3- -d ' ')
        ARTIST=$(echo "$INFO" | grep "tag artist" | cut -f 3- -d ' ')
        TITLE="$ARTIST - $NAME"
        POSITION=$(echo "$INFO" | grep "position" | cut -f 2 -d ' ')
        DURATION=$(echo "$INFO" | grep "duration" | cut -f 2 -d ' ')
        PLAY="cmus-remote --pause"
        EXIT="pkill -x cmus"
        UP="cmus-remote --volume +5%"
        DOWN="cmus-remote --volume -5%"
        ;;
    esac
}

# time_format (Number) -> "title position / duration | "
_compose_string() {
    # ' - ' - cmus stopped and we didn't get any info
    if [[ ! -z "$TITLE" && "$TITLE" != ' - ' ]]; then
        printf "$_COLOR$TITLE$COLOR_ " 
        _time $POSITION $1
        printf "$_COLOR / $COLOR_"
        _time $DURATION $1
        printf " $_COLOR|$COLOR_"
    else
        echo
    fi
}

# player_name time_format (Number)
_display() {
    _get_data $1 
    _trim_title "$TITLE"
    _compose_string $2
    _run_action $ACTION
}

# assume: only one thing is running at a time
if pgrep -f mpv_audiobook > /dev/null; then
    _display mpv "00:00:00"
else
    _display cmus "00:00"
fi
