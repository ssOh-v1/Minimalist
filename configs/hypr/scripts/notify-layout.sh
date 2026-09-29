#!/bin/bash

# Получаем активную раскладку
layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Отправляем уведомление через hyprctl
hyprctl notify 2 2000 "rgb(88c0d0)" "Layout: $layout"
