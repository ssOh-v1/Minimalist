#!/bin/bash

# Minimalist — установка окружения
# Автор: ssOh-v1

set -euo pipefail

# Определяем директорию скрипта (для запуска из любого места)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Проверка sudo (запрашиваем пароль один раз, дальше кэшируется)
if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}Для установки нужен sudo. Введи пароль:${NC}"
    sudo -v || { echo -e "${RED}sudo не работает — выход${NC}"; exit 1; }
fi

# Обновляем sudo timestamp в фоне, чтобы долгая установка не прервалась
( while true; do sudo -n true 2>/dev/null; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &

echo -e "${GREEN}=== Minimalist: установка ===${NC}"

# 1. Проверка, что мы на Arch
if ! command -v pacman &>/dev/null; then
    echo -e "${RED}Ошибка: этот скрипт только для Arch Linux и производных.${NC}"
    exit 1
fi

# 2. Проверка интернета
if ! ping -c 1 -W 3 archlinux.org &>/dev/null; then
    echo -e "${RED}Ошибка: нет интернета. Проверь соединение.${NC}"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/configs" ]; then
    echo -e "${RED}Ошибка: запустите скрипт из папки Minimalist.${NC}"
    exit 1
fi

# 3. Бэкап старых конфигов (ДО копирования новых)
echo -e "${YELLOW}=== Резервное копирование старых конфигов ===${NC}"
if [ -d ~/.config ]; then
    BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r ~/.config/* "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}Старые конфиги сохранены в $BACKUP_DIR${NC}"
fi

# 4. Обновление зеркал
echo -e "${YELLOW}=== Обновление зеркал ===${NC}"
if command -v reflector &>/dev/null; then
    sudo reflector --country Russia --latest 20 --sort rate --save /etc/pacman.d/mirrorlist 2>/dev/null || true
fi

# 4.5. Включение multilib (нужен для 32-битных Steam-библиотек)
echo -e "${YELLOW}=== Проверка репозитория multilib ===${NC}"
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,+1s/^#//" /etc/pacman.conf
    sudo pacman -Sy
fi

# 5. Установка базовых пакетов
echo -e "${YELLOW}=== Установка базовых пакетов ===${NC}"
sudo pacman -S --needed --noconfirm \
    batsignal hyprpicker pamixer brightnessctl jq nemo fzf \
    ttf-nerd-fonts-symbols ttf-font-awesome noto-fonts noto-fonts-emoji \
    hyprland hyprpaper hyprlock hypridle hyprpolkitagent \
    xdg-desktop-portal-hyprland \
    waybar rofi kitty swaync cliphist fastfetch \
    sddm qt6-5compat qt6-shadertools qt6-declarative \
    pipewire pipewire-pulse pipewire-alsa wireplumber \
    pavucontrol network-manager-applet blueman bluez bluez-utils \
    fuzzel wl-clipboard grim slurp \
    gamemode lib32-gamemode \
    weston \
    base-devel git wget curl reflector

# Обновляем кэш шрифтов
echo -e "${YELLOW}=== Обновление кэша шрифтов ===${NC}"
fc-cache -fv

# 5.5. NVIDIA — драйвер и PRIME render offload (только если карта реально есть)
if lspci -k | grep -qi nvidia; then
    echo -e "${YELLOW}=== Обнаружена NVIDIA — ставим драйвер и Vulkan ===${NC}"
    sudo pacman -S --needed --noconfirm \
        nvidia-dkms nvidia-utils nvidia-settings opencl-nvidia \
        lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader

    if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uevent nvidia_drm)/' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
    fi

    if [ -f /etc/default/grub ] && ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
fi

# 6. Установка yay
if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}=== Установка yay ===${NC}"
    cd /tmp
    git clone https://aur.archlinux.org/yay.git 2>/dev/null || {
        echo -e "${RED}Ошибка: не удалось склонировать yay.${NC}"
        exit 1
    }
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
fi

# 7. Установка AUR-пакетов
echo -e "${YELLOW}=== Установка AUR-пакетов ===${NC}"
yay -S --needed --noconfirm wallust matugen bibata-cursor-theme-bin python-spotipy 2>/dev/null || {
    echo -e "${YELLOW}Предупреждение: не все AUR-пакеты установились.${NC}"
}

# 8. Выбор версии окружения (fzf с превью отличий)
echo -e "${YELLOW}=== Выбор версии окружения ===${NC}"
VERSION_CHOICE=$(printf "🟢 Полная версия\n🟡 Облегчённая версия" | fzf --height=40% --reverse \
    --preview "bash configs/hypr/scripts/version-preview.sh {}" \
    --preview-window=right:60%) || true
if [[ -z "$VERSION_CHOICE" ]]; then
    echo -e "${YELLOW}Выбор не сделан — установлена полная версия по умолчанию.${NC}"
fi
if [[ "$VERSION_CHOICE" == *"Облегчённая"* ]]; then
    cp "$SCRIPT_DIR/configs/hypr/hyprland-lite.conf" configs/hypr/hyprland.conf.selected
else
    cp configs/hypr/hyprland.conf configs/hypr/hyprland.conf.selected
fi

# 9. Копирование конфигов
echo -e "${YELLOW}=== Копирование конфигов ===${NC}"
mkdir -p ~/.config
for dir in hypr waybar rofi kitty swaync fastfetch; do
    if [ -d "configs/$dir" ]; then
        cp -r "configs/$dir" ~/.config/
    fi
done

# Применяем выбранную версию hyprland.conf
if [ -f configs/hypr/hyprland.conf.selected ]; then
    cp "$SCRIPT_DIR/configs/hypr/hyprland.conf.selected" ~/.config/hypr/hyprland.conf
    rm -f configs/hypr/hyprland.conf.selected
fi

# 9.1 Копируем конфиг hyprpaper (обои)
mkdir -p ~/.config/hypr
if [ -f configs/hypr/hyprpaper.conf ]; then
    cp "$SCRIPT_DIR/configs/hypr/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf
    echo -e "${GREEN}hyprpaper.conf установлен${NC}"
else
    echo -e "${YELLOW}configs/hypr/hyprpaper.conf не найден — пропускаем${NC}"
fi

# 10. Установка темы SDDM
echo -e "${YELLOW}=== Установка темы SDDM (ii-sddm-theme) ===${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/3d3f/ii-sddm-theme/main/setup.sh)"

# 11. Копирование конфигов SDDM
echo -e "${YELLOW}=== Настройка SDDM ===${NC}"
sudo mkdir -p /etc/sddm.conf.d

# Копируем конфиги SDDM (не темы)
if [ -f configs/sddm/10-wayland.conf ]; then
    sudo cp configs/sddm/10-wayland.conf /etc/sddm.conf.d/ 2>/dev/null || true
fi
if [ -f configs/sddm/ii-sddm-theme.conf ]; then
    sudo cp configs/sddm/ii-sddm-theme.conf /etc/sddm.conf.d/ 2>/dev/null || true
fi
if [ -f configs/sddm/sddm.conf ]; then
    sudo cp configs/sddm/sddm.conf /etc/sddm.conf.d/ 2>/dev/null || true
fi

# Копируем конфиг темы ii-sddm-theme (если тема установлена)
if [ -d /usr/share/sddm/themes/ii-sddm-theme/Themes ]; then
    sudo cp configs/sddm/ii-sddm.conf /usr/share/sddm/themes/ii-sddm-theme/Themes/ 2>/dev/null || true
fi

# 12. Копирование скриптов
echo -e "${YELLOW}=== Копирование скриптов ===${NC}"
mkdir -p ~/.local/bin
mkdir -p ~/.config/hypr/scripts
if [ -f scripts/restore-wallpaper.sh ] && [ -f scripts/change-wallpaper.sh ]; then
    cp scripts/restore-wallpaper.sh scripts/change-wallpaper.sh ~/.local/bin/
    chmod +x ~/.local/bin/restore-wallpaper.sh ~/.local/bin/change-wallpaper.sh
fi

# 7.6 Выбор обоев (опционально)
echo -e "${YELLOW}=== Хочешь ли ты скачать обои? ===${NC}"
WALLPAPERS_CHOICE=$(printf "🎨 Да, скачать обои (670 шт.)\\n🚫 Нет, без обоев" | fzf --height=30% --reverse)

if [[ "$WALLPAPERS_CHOICE" == *"Да"* ]]; then
    echo -e "${YELLOW}Скачиваем обои из Minimalist-Wallpapers...${NC}"
    cd ~
    git clone --depth 1 https://github.com/ssOh-v1/Minimalist-Wallpapers.git minimal-wallpapers 2>/dev/null
    
    if [ -d ~/minimal-wallpapers ]; then
        # Создаём папку для обоев
        sudo mkdir -p /usr/share/sddm/themes/ii-sddm-theme/Backgrounds
        
        # Копируем все обои
        sudo cp ~/minimal-wallpapers/*.png /usr/share/sddm/themes/ii-sddm-theme/Backgrounds/ 2>/dev/null
        sudo cp ~/minimal-wallpapers/*.jpg /usr/share/sddm/themes/ii-sddm-theme/Backgrounds/ 2>/dev/null
        
        # Берём первую обоину и делаем её background.png
        FIRST_WALLPAPER=$(ls /usr/share/sddm/themes/ii-sddm-theme/Backgrounds/ | head -1)
        if [ -n "$FIRST_WALLPAPER" ]; then
            sudo cp "/usr/share/sddm/themes/ii-sddm-theme/Backgrounds/$FIRST_WALLPAPER" \
                    /usr/share/sddm/themes/ii-sddm-theme/Backgrounds/background.png
            echo -e "${GREEN}Обои установлены! (${FIRST_WALLPAPER} → background.png)${NC}"
        fi
        
        rm -rf ~/minimal-wallpapers
    else
        echo -e "${RED}Не удалось скачать обои. Пропускаем.${NC}"
    fi
else
    echo -e "${YELLOW}Обои не скачаны — можно добавить позже.${NC}"
fi

# Перезапускаем hyprpaper, чтобы обои применились СРАЗУ
if command -v hyprpaper &>/dev/null; then
    pkill hyprpaper
    sleep 1
    hyprpaper &
    echo -e "${GREEN}hyprpaper перезапущен — обои применены.${NC}"
fi

# 14. Настройка sudoers
echo -e "${YELLOW}=== Настройка sudoers ===${NC}"
sudo tee /usr/local/bin/set-sddm-wallpaper.sh > /dev/null <<'EOF'
#!/bin/bash
set -euo pipefail
cp "$1" "/usr/share/sddm/themes/ii-sddm-theme/Backgrounds/background.png"
EOF
sudo chmod 755 /usr/local/bin/set-sddm-wallpaper.sh
echo "$USER ALL=(ALL) NOPASSWD: /usr/local/bin/set-sddm-wallpaper.sh" | sudo tee /etc/sudoers.d/wallpaper-change > /dev/null
sudo chmod 440 /etc/sudoers.d/wallpaper-change

# 15. Автозапуск PipeWire
echo -e "${YELLOW}=== Включение PipeWire ===${NC}"
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

# 16. Включение SDDM
echo -e "${YELLOW}=== Включение SDDM ===${NC}"
sudo systemctl enable sddm

# 17. Установка темы GRUB
echo -e "${YELLOW}=== Установка темы GRUB ===${NC}"
if [ -d "$SCRIPT_DIR/configs/grub/themes" ]; then
    sudo mkdir -p /usr/share/grub/themes
    sudo cp -r "$SCRIPT_DIR/configs/grub/themes/"* /usr/share/grub/themes/
    
    # Используем тему catppuccin-mocha-grub-theme (как у автора)
    GRUB_THEME_NAME="catppuccin-mocha-grub-theme"
    
    if [ -d "/usr/share/grub/themes/$GRUB_THEME_NAME" ]; then
        # Прописываем тему в /etc/default/grub
        if grep -q "^GRUB_THEME=" /etc/default/grub; then
            sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"/usr/share/grub/themes/$GRUB_THEME_NAME/theme.txt\"|" /etc/default/grub
        else
            echo "GRUB_THEME=\"/usr/share/grub/themes/$GRUB_THEME_NAME/theme.txt\"" | sudo tee -a /etc/default/grub
        fi
        
        # Убеждаемся, что GRUB_TERMINAL_OUTPUT=gfxterm
        if grep -q "^GRUB_TERMINAL_OUTPUT=" /etc/default/grub; then
            sudo sed -i 's|^GRUB_TERMINAL_OUTPUT=.*|GRUB_TERMINAL_OUTPUT="gfxterm"|' /etc/default/grub
        else
            echo 'GRUB_TERMINAL_OUTPUT="gfxterm"' | sudo tee -a /etc/default/grub
        fi
        
        echo -e "${GREEN}Тема GRUB установлена: $GRUB_THEME_NAME${NC}"
        
        # Пересобираем конфиг GRUB
        echo -e "${YELLOW}Пересобираем конфиг GRUB...${NC}"
        # grub-mkconfig может вернуть non-zero, если нет других ОС — это не ошибка
        set +e
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        GRUB_RC=$?
        set -e
        if [ $GRUB_RC -ne 0 ]; then
            echo -e "${YELLOW}grub-mkconfig вернул код $GRUB_RC — проверь вручную: sudo grub-mkconfig -o /boot/grub/grub.cfg${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Тема GRUB не найдена в репозитории — пропускаем.${NC}"
fi

echo ""
echo -e "${GREEN}=== Установка завершена! ===${NC}"
echo -e "${GREEN}Перезагрузитесь: sudo reboot${NC}"
