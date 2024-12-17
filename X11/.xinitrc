#!/usr/bin/sh

#/usr/bin/VBoxClient-all
#xset +fp /usr/share/fonts/local/
#xset fp rehash
#xset +fp /home/craig/.local/share/fonts
#xset fp rehash
#xrandr --output HDMI-0 --rotate left
#xrandr --output DP-2 --pos 1440x579
#xrandr --output DP-2
#xset dpms force off
#xrandr --output DP-2 --auto --output HDMI-0 --refresh 143.99 --mode 2560x1440 --right-of DP-2
#[ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || export QT_QPA_PLATFORMTHEME="qt5ct"
# Taken from default xinit
# start some nice programs
#if [ -d /etc/X11/xinit/xinitrc.d ] ; then
# for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
#  [ -x "$f" ] && . "$f"
# done
# unset f
#fi
#numlockx &
# Had issues launching gtk apps like meld quickly so started launching with dbus
#exec dbus-launch --exit-with-x11 bspwm
#exec dbus-launch "/home/craig/venvs/qtile/bin/qtile start"

xrandr --output HDMI-0 --auto --output DP-2 --auto --left-of HDMI-0
xrdb -merge  ~/.Xresources
xmodmap ~/.Xmodmap
feh --bg-scale ~/my_settings/background.jpg
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
exec /home/craig/.local/share/pipx/venvs/qtile/bin/qtile start
