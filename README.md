# polybar-player

This simple script generates a customizable string, which can be easily modified, for two chosen audio players.
The script assumes that you run one player at a time, so you have to kill the other one when any of them is launched.

```
# i3 bindings
# run cmus and kill mpv
bindsym mod4+s exec pgrep --full '^cmus' || pkill -f mpv_audiobook; exec kitty --class cmus -o font_size=13 -e cmus
# run mpv and kill cmus
bindsym Shift+$mod+b exec --no-startup-id pgrep -f '^mpv_audiobook' || pkill -f cmus; exec mpv --title="mpv_audiobook" --input-ipc-server=/tmp/mpvsocket --save-position-on-quit -no-video "$(cat ~/.config/mpv/curbook.tmp)"
```

## ~/polybar/config.ini
```
[module/player]
type = custom/script
exec = ~/.config/polybar/player.sh
exec-if = pgrep -f mpv_audiobook || pgrep -x cmus
tail = true
interval = 1
click-left = ~/.config/polybar/player.sh left
click-right = ~/.config/polybar/player.sh right
scroll-up = ~/.config/polybar/player.sh up
scroll-down = ~/.config/polybar/player.sh down
```
#
