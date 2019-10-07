#!/bin/bash

# separator char:  
# charging char: ⚡

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

FIRST_SEP_COLOR=$KUBE_COLOR

echo "#[fg=colour255, bg=colour0] $CURRENT_SESSION #[fg=colour0, bg=$FIRST_SEP_COLOR]#[default]${BATTERY_TEXT}${BATTERY_SEPARATOR}#[bg=colour235]#[default]$KUBE_TEXT#[bg=colour235]"
