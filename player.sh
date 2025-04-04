#!/bin/bash

_COLOR="%%{F$PRIMARY_COLOR}"
COLOR_="%%{F-}"
MAX_TITLE=55
ACTION="$1"

# time_in_seconds format (3/whatever)
_time() {
    if [ $2 == 3 ]; then
        printf ' %02d:%02d:%02d ' "$(($1/3600))" "$(($1%3600/60))" "$(($1%60))"
    fi

    if [ $2 == 2 ]; then
        printf ' %02d:%02d ' "$(($1%3600/60))" "$(($1%60))"
    fi
}


_trim_title() {
    if [ ${#1} -gt $MAX_TITLE ]; then
        TITLE="$(printf '%.55s' "$1")..."
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
        TITLE=$(echo '{ "command": ["get_property", "media-title"] }' | socat - $MPV_SOCKET | jq -r .data)
        # in seconds
        POSITION=$(echo '{ "command": ["get_property_string", "time-pos"] }' | socat - $MPV_SOCKET  | jq -r .data | cut -d'.' -f 1)
        DURATION=$(echo '{ "command": ["get_property_string", "duration"] }' | socat - $MPV_SOCKET | jq -r .data | cut -d'.' -f 1)
        PLAY="echo 'cycle pause' | socat - $MPV_SOCKET" 
        EXIT="echo 'quit' | socat - $MPV_SOCKET" 
        UP="echo 'add volume +5' | socat - $MPV_SOCKET" 
        DOWN="echo 'add volume -5' | socat - $MPV_SOCKET" 
        ;;

        cmus)
        NAME=$(cmus-remote -C status | grep "tag title" | cut -f 3- -d ' ')
        ARTIST=$(cmus-remote -C status | grep "tag artist" | cut -f 3- -d ' ')
        TITLE="$ARTIST - $NAME"
        POSITION=$(cmus-remote -C status | grep "position" | cut -f 2 -d ' ')
        DURATION=$(cmus-remote -C status | grep "duration" | cut -f 2 -d ' ')
        PLAY="cmus-remote --pause"
        EXIT="pkill -x cmus"
        UP="cmus-remote --volume +5%"
        DOWN="cmus-remote --volume -5%"
        ;;
    esac
}

# time_format (Number)
_compose_string() {
    # ' - ' - cmus stopped and we didn't get any info
    if [[ ! -z "$TITLE" && "$TITLE" != ' - ' ]]; then
        printf "$_COLOR$TITLE$COLOR_" 
        _time $POSITION $1
        printf "$_COLOR/$COLOR_"
        _time $DURATION $1
        printf "$_COLOR|$COLOR_"
    else
        echo ""
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
    _display mpv 3
else
    _display cmus 2
fi
