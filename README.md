# polybar-player

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
