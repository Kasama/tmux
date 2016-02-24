#!/bin/bash

WEEK_DAY=$(date +%a)
FULL_DATE=$(date +%d/%m/%Y)
TIME=$(date +%k:%M)

echo "#[fg=colour237, bg=colour235]#[default]#[fg=default, bg=colour237] $WEEK_DAY #[default]#[fg=colour239, bg=colour237]#[default]#[fg=default, bg=colour239] $FULL_DATE #[default]#[fg=colour241, bg=colour239]#[default]#[fg=default, bg=colour241] $TIME #[default]"
