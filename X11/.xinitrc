#!/usr/bin/sh

xrdb -merge  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
xmodmap ~/.Xmodmap
#numlockx &
# Had issues launching gtk apps like meld quickly so started launching with dbus
#exec dbus-launch --exit-with-x11 bspwm
exec dbus-launch bspwm
#exec bspwm
