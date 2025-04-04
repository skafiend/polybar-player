# polybar-player

This simple script generates a customizable string, which can be easily modified, for two chosen audio players.

## i3 bindings
```
# only one player at a time is supposed to be running

# run cmus and kill mpv
bindsym mod4+s exec pgrep --full '^cmus' || pkill -f mpv_audiobook; exec kitty --class cmus -o font_size=13 -e cmus
# run mpv and kill cmus
bindsym mod4+b exec --no-startup-id pgrep -f '^mpv_audiobook' || pkill -f cmus; exec mpv --title="mpv_audiobook" --input-ipc-server=/tmp/mpvsocket --save-position-on-quit -no-video "$(cat ~/.config/mpv/curbook.tmp)"
```

## ~/polybar/config.ini
- It should work for any bar which supports custom scripts/modules
```
  [module/player]
  type = custom/script
  exec = ~/.config/polybar/player.sh
  # modify this line as necessary
  exec-if = pgrep -f mpv_audiobook || pgrep -x cmus
  tail = true
  interval = 1
  click-left = ~/.config/polybar/player.sh left
  click-right = ~/.config/polybar/player.sh right
  scroll-up = ~/.config/polybar/player.sh up
  scroll-down = ~/.config/polybar/player.sh down
```
## ~/polybar/player.sh
- Change these variables as you need. Keep in mind that POSITION and DURATION is measured in seconds
- Other variables are pretty self-explanatory
### cmus
![cmus_preview](https://github.com/skafiend/polybar-player/blob/main/preview_cmus.png)
```
  NAME=$(cmus-remote -C status | grep "tag title" | cut -f 3- -d ' ')
  ARTIST=$(cmus-remote -C status | grep "tag artist" | cut -f 3- -d ' ')
  TITLE="$ARTIST - $NAME"
  POSITION=$(cmus-remote -C status | grep "position" | cut -f 2 -d ' ')
  DURATION=$(cmus-remote -C status | grep "duration" | cut -f 2 -d ' ')
  PLAY="cmus-remote --pause"
  EXIT="pkill -x cmus"
  UP="cmus-remote --volume +5%"
  DOWN="cmus-remote --volume -5%"
```
### mpv
![mpv_preview](https://github.com/skafiend/polybar-player/blob/main/preview_mpv.png)
```
  MPV_SOCKET='/tmp/mpvsocket'
  TITLE=$(echo '{ "command": ["get_property", "media-title"] }' | socat - $MPV_SOCKET | jq -r .data)
  POSITION=$(echo '{ "command": ["get_property_string", "time-pos"] }' | socat - $MPV_SOCKET  | jq -r .data | cut -d'.' -f 1)
  DURATION=$(echo '{ "command": ["get_property_string", "duration"] }' | socat - $MPV_SOCKET | jq -r .data | cut -d'.' -f 1)
  PLAY="echo 'cycle pause' | socat - $MPV_SOCKET" 
  EXIT="echo 'quit' | socat - $MPV_SOCKET" 
  UP="echo 'add volume +5' | socat - $MPV_SOCKET" 
  DOWN="echo 'add volume -5' | socat - $MPV_SOCKET" 
```
