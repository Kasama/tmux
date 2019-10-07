#!/bin/bash

WEEK_DAY=$(date +%A)
FULL_DATE=$(date +%d/%m/%Y)
TIME=$(date +%k:%M)

WEEK_TEXT="#[fg=colour237, bg=colour235]#[default]#[fg=default, bg=colour237] $WEEK_DAY #[default]"
DATE_TEXT="#[fg=colour239, bg=colour237]#[default]#[fg=default, bg=colour239] $FULL_DATE #[default]"
TIME_TEXT="#[fg=colour241, bg=colour239]#[default]#[fg=default, bg=colour241] $TIME #[default]"

BATPATH=/sys/class/power_supply/BAT0
if [ ! -d $BATPATH ]; then
  BATPATH=/sys/class/power_supply/BAT1
  if command -v pmset &> /dev/null; then
    MACOS="true"
  else
    if [ ! -d $BATPATH ]; then
      BATTERY_PRESENT="false"
    fi
  fi
fi

if [ "true" = "$MACOS" ]; then
  BAT_PERCENT=$(pmset -g batt | grep -oE '\d+%' --color=never | grep -oE '\d+' --color=never)
  BAT_STAT=$(pmset -g batt | grep -o ' charging')
  BAT_CHARGE=""
  if [ "charging" = "$BAT_STAT" ]; then
    BAT_CHARGE="! "
  fi
else
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
BATTERY_TEXT="#[fg=$BATTERY_COLOR, bg=colour241]#[default]#[fg=$BATTERY_FOREGROUND, bg=$BATTERY_COLOR] $BATTERY_TEXT "

if [ "false" = "$BATTERY_PRESENT" ]; then
  BATTERY_TEXT=""
  BATTERY_COLOR="colour235"
fi

echo "${WEEK_TEXT}${DATE_TEXT}${TIME_TEXT}${BATTERY_TEXT}"
