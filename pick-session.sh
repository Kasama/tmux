#!/bin/bash

if [ -z "$TMUX" ]; then
  echo "Should only be used from tmux"
  echo ""
  echo "Example tmux.conf configuration"
  echo "bind s run-shell \"$0\""
  exit 1
fi

if [ -z "$1" ]; then
  tmux display-popup -E -T 'Pick a Session' "$0 bypass"
  exit 0
fi

input() {
  if [ -x "$(command -v gum)" ]; then
    gum input --prompt "$1: "
  else
    echo -n "$1: " >&2
    local var
    read -r var
    echo "$var"
  fi
}

export NEW_SESSION_KEY="--- New Session ---"

# Shellcheck is tricked by the `unset` command below into thinking that this function is unused
# shellcheck disable=2317
fzfpreviewfunction() {
  local selected=$1

  if [ "$selected" = "$NEW_SESSION_KEY" ]; then
    echo "Prompts for a name and creates a new session"
    return
  fi

  for window in $(tmux list-windows -t "$selected" -F "#W"); do
    printf "%s\t" "$window"
  done
}
export -f fzfpreviewfunction

# shellcheck disable=2317
fzfconfirmkill() {
  if [ -x "$(command -v gum)" ]; then
    if gum confirm --prompt.padding "5 32" --prompt.align bottom "Close $(gum style --underline "$1")?"; then
      tmux kill-session -t "$@"
    fi
  else
    read -r opt
    if [ "$opt" = "y" ]; then
      tmux kill-session -t "$@"
    fi
  fi
  exit 130
}
export -f fzfconfirmkill

selected=$( (echo "$NEW_SESSION_KEY"; tmux list-sessions -F "#S") | fzf --tac --bind='ctrl-q:become(bash -c "fzfconfirmkill {}")' --preview-window=top,1 --preview='bash -c "fzfpreviewfunction {}"' )
action=$?

# 0 action indicates successful fzf seleciton.
# 1 action indicates no match
# 2 action indicates error
# 130 action indicates cancel
if [ "$action" -ne 0 ]; then
  exit "$action"
fi

# check if selected is new session key
if [ "$selected" = "$NEW_SESSION_KEY" ]; then
  session_name=$(input "Session Name")
  tmux new-session -d -s "$session_name"
  selected=$session_name
fi

unset fzfconfirmkill
unset fzfpreviewfunction
unset NEW_SESSION_KEY

tmux switch-client -t "$selected"
