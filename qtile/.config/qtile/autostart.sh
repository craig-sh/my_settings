#!/bin/bash

xss-lock /usr/local/bin/locksreen.sh &
dunst &
<<<<<<< Updated upstream
/usr/lib/kdeconnectd &
xautolock -time 15 -locker '/usr/local/bin/lock' &
=======
keepassxc &
#/usr/lib/kdeconnectd &
#xautolock -time 15 -locker '/usr/local/bin/lock' &
>>>>>>> Stashed changes
