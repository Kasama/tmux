#!/bin/bash

# separator char: 
# charging char: ⚡

BATPATH=/sys/class/power_supply/BAT0
if [ ! -d $BATPATH ]; then
	BATPATH=/sys/class/power_supply/BAT1
	if [ ! -d $BATPATH ]; then
		BATTERY_PRESENT="false"
	fi
fi

BAT_STAT=$(cat $BATPATH/status)

BAT_FULL=$BATPATH/charge_full
if [ ! -r $BAT_FULL ]; then
	BAT_FULL=$BATPATH/energy_full
fi

BAT_NOW=$BATPATH/charge_now
if [ ! -r $BAT_NOW ]; then
	BAT_NOW=$BATPATH/energy_now
fi

bf=$(cat $BAT_FULL)
bn=$(cat $BAT_NOW)
BAT_PERCENT=$(( 100 * $bn / $bf ))
BAT_CHARGE=""
if [ "Charging" = "$BAT_STAT" ]; then
	BAT_CHARGE="! "
fi

BATTERY_COLOR="colour9"
BATTERY_FOREGROUND="default"
if [ "$BAT_PERCENT" -gt "95" ]; then
	BATTERY_COLOR="colour2"
	BATTERY_FOREGROUND="default"
elif [ "$BAT_PERCENT" -gt "60" ]; then
	BATTERY_COLOR="colour24"
	BATTERY_FOREGROUND="default"
elif [ "$BAT_PERCENT" -gt "20" ]; then
	BATTERY_COLOR="colour11"
	BATTERY_FOREGROUND="colour0"
fi

BATTERY_TEXT="$BAT_CHARGE$BAT_PERCENT%"
BATTERY_TEXT="#[default]#[fg=$BATTERY_FOREGROUND, bg=$BATTERY_COLOR] $BATTERY_TEXT #[default]#[fg=$BATTERY_COLOR, bg=default]"

if [ "false" = "$BATTERY_PRESENT" ]; then
	BATTERY_TEXT=""
	BATTERY_COLOR="colour235"
fi

HOST_TEXT=$(cat /etc/hostname)


echo "#[fg=colour255, bg=colour0] $HOST_TEXT #[fg=colour0, bg=$BATTERY_COLOR]#[default]$BATTERY_TEXT#[bg=colour235]"
