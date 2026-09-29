# Waybar Configuration

This directory contains the Waybar status bar configuration for Hyprland, inspired by [z3nity/dotfiles](https://github.com/z3nity/dotfiles).

## Files

- `config` - Waybar configuration (JSONC format)
- `style.css` - Waybar styling and appearance
- `colors/colors.css` - Catppuccin Mocha color definitions
- `scripts/get_weather.sh` - Weather data fetching script (via wttr.in)
- `scripts/launch.sh` - Script to restart Waybar and swaync

## Overview

Waybar is a highly customizable status bar for Wayland compositors. This configuration uses a transparent background with rounded pill-shaped modules and smooth transitions.

## Modules

### Left Side
- **Notification** (`custom/notification`): swaync notification center toggle
- **Clock**: Shows current time in 12-hour format with icon
- **Weather** (`custom/weather`): Live weather via wttr.in

### Center
- **Workspaces**: Hyprland workspaces with icon-based display and 5 persistent workspaces

### Right Side
- **PulseAudio**: Volume control (click to open pavucontrol)
- **Battery**: Battery level and charging status with icons
- **Network**: WiFi/Ethernet status (click to open nm-connection-editor)
- **Tray**: System tray icons
- **Power**: Power menu (click to open wlogout)

## Styling

The configuration uses Catppuccin Mocha colors with:
- Transparent bar background
- Rounded pill-shaped modules (`border-radius: 50px`)
- Smooth CSS transitions on all modules
- Blinking animation for critical battery
- Color-coded modules (blue=clock/notification, green=battery, aqua=network, orange=audio)

## Customization

### Setting Your City for Weather
Edit the `custom/weather` section in `config` and set your city:
```jsonc
"exec": "${HOME}/.config/waybar/scripts/get_weather.sh London+UK"
```
Replace spaces in city/country names with `+` (e.g., `New+York+USA`, `Berlin+Germany`).

### Changing Timezone
Edit the `clock` section in `config`:
```jsonc
"timezone": "Your/Timezone"
```

### Modifying Modules
Add or remove modules by editing the `modules-left`, `modules-center`, and `modules-right` arrays in `config`.

### Adjusting Colors
Edit `colors/colors.css` to customize the color palette, then `style.css` for per-module color assignments.

### Font Requirements
The configuration uses "JetBrainsMono Nerd Font". Install it for proper icon display:
```bash
yay -S ttf-jetbrains-mono-nerd
```

### Notification Support
The `custom/notification` module requires `swaync`:
```bash
yay -S swaync
```

## Resources

- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [Waybar GitHub](https://github.com/Alexays/Waybar)
- [z3nity/dotfiles](https://github.com/z3nity/dotfiles)
