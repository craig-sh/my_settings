#/usr/bin/VBoxClient-all
#xset +fp /usr/share/fonts/local/
#xset fp rehash
xrandr --output  DP-0.8 --auto --output DP-0.1.8 --auto --right-of DP-0.8
xset dpms force off
xrdb -merge  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
numlockx &
sxhkd -f 100 &
exec bspwm
##exec /opt/kf5/bin/startkde
