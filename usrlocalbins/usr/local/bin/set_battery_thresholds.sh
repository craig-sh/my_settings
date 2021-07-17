#!/usr/bin/bash

CHARGE_END_THRESHOLD=80
CHARGE_START_THRESHOLD=75

echo $CHARGE_START_THRESHOLD > /sys/class/power_supply/BAT0/charge_control_start_threshold
echo $CHARGE_END_THRESHOLD > /sys/class/power_supply/BAT0/charge_control_end_threshold


