#!/usr/bin/sh

xrdb -merge  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
xmodmap ~/.Xmodmap
exec bspwm
