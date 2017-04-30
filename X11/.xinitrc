#/usr/bin/VBoxClient-all
#xset +fp /usr/share/fonts/local/
#xset fp rehash
xrandr --output  DP-0 --auto --output HDMI-0 --auto --right-of DP-0
#xset dpms force off
xrdb -merge  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
numlockx &
sxhkd &
exec bspwm
##exec /opt/kf5/bin/startkde
