#!/bin/bash
# Скрывает служебные .desktop-пункты из меню приложений (rofi drun),
# не трогая сами пакеты — через XDG-переопределение NoDisplay=true.

PATTERNS=("Avahi.*Browser" "Hardware Locality")

mkdir -p ~/.local/share/applications

for f in /usr/share/applications/*.desktop; do
    name_line=$(grep -m1 "^Name=" "$f")
    for pattern in "${PATTERNS[@]}"; do
        if echo "$name_line" | grep -qE "$pattern"; then
            base=$(basename "$f")
            cat > ~/.local/share/applications/"$base" << OVERRIDE
[Desktop Entry]
NoDisplay=true
OVERRIDE
            echo "Скрыт: $base ($name_line)"
        fi
    done
done
