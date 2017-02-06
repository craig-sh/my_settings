#!/bin/bash
# Taken from https://github.com/petvas/i3lock-blur
TMPBG=/tmp/screen.png
LOCK=/home/craig/my_settings/lock.png
RES=$(xrandr | grep 'current' | sed -E 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/')

ffmpeg -f x11grab -video_size $RES -y -i $DISPLAY -i $LOCK  -filter_complex "boxblur=5:1,overlay=(main_w-overlay_w)/4:(main_h-overlay_h)/2"  -vframes 1 $TMPBG -loglevel quiet
i3lock -i $TMPBG
rm $TMPBG
