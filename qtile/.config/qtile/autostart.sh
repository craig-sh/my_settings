#!/bin/bash

xss-lock /usr/local/bin/locksreen.sh &
dunst &
/usr/lib/kdeconnectd &
xautolock -time 15 -locker '/usr/local/bin/lock' &
