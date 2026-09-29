# Hyprland Configuration

This directory contains the main Hyprland window manager configuration.

## Files

- `hyprland.conf` - Main Hyprland configuration file

## Overview

Hyprland is a dynamic tiling Wayland compositor that provides beautiful animations and customization options.

## Key Features Configured

- **Monitor Setup**: Auto-configured with preferred resolution
- **Input Configuration**: Keyboard and touchpad settings
- **Appearance**: 
  - Custom gaps and borders
  - Rounded corners (10px)
  - Blur effects
  - Drop shadows
  - Smooth animations
- **Layouts**: Dwindle layout enabled
- **Autostart Applications**:
  - Waybar (status bar)
  - Mako (notification daemon)
  - Hyprpaper (wallpaper manager)

## Keybindings

The main modifier key is `SUPER` (Windows/Command key).

### Application Shortcuts
- `SUPER + Q` - Launch Kitty terminal
- `SUPER + C` - Close active window
- `SUPER + M` - Exit Hyprland
- `SUPER + E` - Open file manager (Thunar)
- `SUPER + V` - Toggle floating mode
- `SUPER + R` - Open Rofi application launcher
- `SUPER + J` - Toggle split

### Window Management
- `SUPER + Arrow Keys` - Move focus between windows
- `SUPER + [1-9,0]` - Switch to workspace 1-10
- `SUPER + SHIFT + [1-9,0]` - Move window to workspace 1-10
- `SUPER + Mouse Scroll` - Cycle through workspaces
- `SUPER + LMB Drag` - Move window
- `SUPER + RMB Drag` - Resize window

## Customization

Edit `hyprland.conf` to customize:
- Colors and appearance
- Keybindings
- Monitor configuration
- Animation settings
- Startup applications

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
