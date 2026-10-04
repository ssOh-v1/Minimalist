#!/bin/bash
# Меню управления Spotify через rofi, в стиле Spotify-панели

track=$(playerctl --player=spotify metadata --format '{{title}} — {{artist}}' 2>/dev/null)
[ -z "$track" ] && track="Spotify не играет"

options="⏮  Предыдущий трек\n⏯  Пауза / Воспроизведение\n⏭  Следующий трек\n🔉  Тише\n🔊  Громче"

chosen=$(echo -e "$options" | rofi -dmenu -p "🎵 Spotify" -mesg "$track" -theme ~/.config/rofi/spotify.rasi)

case "$chosen" in
    "⏮  Предыдущий трек") playerctl --player=spotify previous ;;
    "⏯  Пауза / Воспроизведение") playerctl --player=spotify play-pause ;;
    "⏭  Следующий трек") playerctl --player=spotify next ;;
    "🔉  Тише") playerctl --player=spotify volume 0.1- ;;
    "🔊  Громче") playerctl --player=spotify volume 0.1+ ;;
esac
