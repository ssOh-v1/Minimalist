#!/bin/bash

# Проверяем, запущена ли панель
if pgrep -f "power-panel.py" > /dev/null; then
    # Если запущена — убиваем (скрываем)
    pkill -f "power-panel.py"
else
    # Если не запущена — показываем
    python3 ~/.config/hypr/scripts/power-panel.py &
fi
