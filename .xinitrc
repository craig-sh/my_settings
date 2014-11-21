/usr/bin/VBoxClient-all
xset +fp /usr/share/fonts/local/
xset fp rehash
xrdb  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
xrandr --output VBOX0 --auto --output VBOX1 --auto --left-of VBOX0
sxhkd &
exec bspwm
##exec /opt/kf5/bin/startkde
