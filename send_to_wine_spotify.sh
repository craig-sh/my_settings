#! /bin/bash
# Usage: send_to_wine_spotify.sh key
#   `key`: any key/key combination that xdotool recoginizes
# Ex. end_to_wine_spotify.sh space
#   This will acticate the spotify window running under wine,
# send it space (play/pause)  and then reactive the previous window
# Not sure why the xdotool key --window doesn't work for this which
# is why it activates the spotify window before sending the command


cur=`xdotool getactivewindow`
# switch too the left monitor
bspc monitor -f DVI-I-1
left_cur=`xdotool getactivewindow`
spot=`xdotool search --classname "spotify.exe"|head -n1`
xdotool windowactivate $spot
# Doesn't work w/o sleeping for some reason
sleep 0.1
xdotool key $1
sleep 0.1
xdotool windowactivate $left_cur
xdotool windowactivate $cur