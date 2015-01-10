#/usr/bin/VBoxClient-all
#xset +fp /usr/share/fonts/local/
#xset fp rehash
xrandr --output DVI-I-1 --auto --output DVI-D-0 --auto --left-of DVI-I-1
xrdb  ~/.Xresources
feh --bg-scale ~/my_settings/background.jpg
numlockx &
sxhkd &
exec bspwm
##exec /opt/kf5/bin/startkde
