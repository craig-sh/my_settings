#!/usr/bin/sh

#/usr/bin/VBoxClient-all
#xset +fp /usr/share/fonts/local/
#xset fp rehash
#xrandr --output DP-0 --rotate left
xrandr --output  DP-0 --auto --output HDMI-0 --auto --right-of DP-0
#xrandr --output HDMI-0 --pos 1440x579
#xset dpms force off
xrdb -merge  ~/.Xresources
#[ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || export QT_QPA_PLATFORMTHEME="qt5ct"
feh --bg-scale ~/my_settings/background.jpg

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
