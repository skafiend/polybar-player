# polybar-player

This simple script generates a customizable string, which can be easily modified, for two chosen audio players.

## i3 bindings
```
# only one player at a time is supposed to be running

# run cmus and kill mpv
bindsym mod4+s exec pgrep --full '^cmus' || pkill -f mpv_audiobook; exec kitty --class cmus -o font_size=13 -e cmus
# run mpv and kill cmus
bindsym $mod4+s exec --no-startup-id pgrep -f '^mpv_audiobook' || pkill -f cmus; exec mpv --title="mpv_audiobook" --input-ipc-server=/tmp/mpvsocket --save-position-on-quit -no-video "$(cat ~/.config/mpv/curbook.tmp)"
```

## ~/polybar/config.ini
- The script should work for any bar which supports custom scripts with some text output
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
