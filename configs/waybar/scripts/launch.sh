#!/bin/zsh

pkill waybar; waybar &
pkill swaync; swaync &
hyprctl reload
