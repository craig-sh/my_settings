#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

xrandr --output VGA-0 --auto --output HDMI-0 --auto --right-of VGA-0

#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#  for f in /etc/X11/xinit/xinitrc.d/*; do
#    [ -x "$f" ] && . "$f"
#  done
#  unset f
#fi

xrdb -merge ~/.Xresources
#xset +fp ~/.fonts
#fc-cache -vf
# Make sure this is before the 'exec' command or it won't be sourced.
#[ -f /etc/xprofile ] && source /etc/xprofile
#[ -f ~/.xprofile ] && source ~/.xprofile

feh --bg-scale /home/craig/Documents/zen_wallpaper.png
numlockx on &
sxhkd &
exec bspwm
