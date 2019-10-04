#!/bin/bash

# separator char: 
# charging char: ⚡

BATPATH=/sys/class/power_supply/BAT0
if [ ! -d $BATPATH ]; then
	BATPATH=/sys/class/power_supply/BAT1
  if command -v pmset &> /dev/null; then
    MACOS="false"
  fi
	if [ ! -d $BATPATH ]; then
		BATTERY_PRESENT="false"
	fi
fi

if [ "true" = "$MACOS" ]; then
  BAT_PERCENT=$(pmset -g batt | grep -oE '\d+%' | grep -o '\d+')
  BAT_STAT=$(pmset -g batt | grep -o 'charging')
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
BATTERY_TEXT="#[default]#[fg=$BATTERY_FOREGROUND, bg=$BATTERY_COLOR] $BATTERY_TEXT"

if [ "false" = "$BATTERY_PRESENT" ]; then
	BATTERY_TEXT=""
	BATTERY_COLOR="colour235"
fi

CURRENT_SESSION=$(tmux display-message -p '#S')

KUBE_TEXT=""
if command -v kubectl &> /dev/null; then
  KUBE_CONTEXT=$(kubectl config current-context | sed 's/.k8s.tfgco.com//g')
  KUBE_COLOR="colour239"
  KUBE_FOREGROUND="default"
  if echo "$KUBE_CONTEXT" | grep "prod" &> /dev/null; then
  # KUBE_COLOR="colour198"
    KUBE_COLOR="colour181"
    KUBE_FOREGROUND="colour0"
  fi
  if [ -n "$KUBE_CONTEXT" ]; then
    KUBE_TEXT="#[default]#[fg=$KUBE_FOREGROUND, bg=$KUBE_COLOR] $KUBE_CONTEXT #[default]#[fg=$KUBE_COLOR, bg=default]"
  fi
fi

FIRST_SEP_COLOR=$BATTERY_COLOR
if [ ! "false" = "$BATTERY_PRESENT" ]; then
  BATTERY_SEPARATOR="#[default]#[fg=$BATTERY_COLOR, bg=$KUBE_COLOR]"
else
  FIRST_SEP_COLOR=$KUBE_COLOR
fi



echo "#[fg=colour255, bg=colour0] $CURRENT_SESSION #[fg=colour0, bg=$FIRST_SEP_COLOR]#[default]${BATTERY_TEXT}${BATTERY_SEPARATOR}#[bg=colour235]#[default]$KUBE_TEXT#[bg=colour235]"
