#!/usr/bin/sh

xrdb -merge  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
xmodmap ~/.Xmodmap
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

# Taken from default xinit
# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi
#numlockx &
# Had issues launching gtk apps like meld quickly so started launching with dbus
#exec dbus-launch --exit-with-x11 bspwm
#exec dbus-launch bspwm
#exec bspwm
exec dbus-launch qtile start
