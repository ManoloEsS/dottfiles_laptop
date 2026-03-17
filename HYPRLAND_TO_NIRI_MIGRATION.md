# Hyprland to Niri + Noctalia Migration Guide

## Overview
Migrate from Hyprland + hypridle + hyprsunset + wofi + hyprlock to:
- **Niri** (Window Manager)
- **Noctalia** (Central Controller + Launcher + Notifications + Lock Screen)
- **hypridle** (Keep existing idle management - easier to configure)
- **wlsunset** (Replace hyprsunset, managed by Noctalia Night Light)

## Prerequisites
- Backup current configs before proceeding
- Ensure all packages are installed
- Test each component individually before full migration

---

## Phase 1: Package Installation

### Install Required Packages
```bash
sudo pacman -S wlsunset
```

### Verify Installation
```bash
which niri hypridle wlsunset
```
*Note: hypridle should already be installed from your Hyprland setup*

---

## Phase 2: Directory Structure Setup

### Create New Config Directories
```bash
mkdir -p ~/.config/niri/colors
mkdir -p ~/.config/wlsunset
mkdir -p ~/.config/noctalia
```

### Backup Current Configuration
```bash
mkdir -p ~/.config/hypr_backup
cp -r ~/.config/hypr ~/.config/hypr_backup/hypr_$(date +%Y%m%d_%H%M%S)
```

---

## Phase 3: Color Scheme Migration

### Create Niri Color Configuration
**File: `~/.config/niri/colors/mocha.kdl`**
```kdl
// Catppuccin Mocha colors for Niri
$rosewater = "rgb(192, 202, 245)"
$flamingo = "rgb(255, 158, 100)"
$pink = "rgb(255, 121, 198)"
$mauve = "rgb(187, 154, 247)"
$red = "rgb(247, 118, 142)"
$maroon = "rgb(210, 109, 128)"
$peach = "rgb(255, 170, 86)"
$yellow = "rgb(224, 175, 104)"
$green = "rgb(158, 206, 106)"
$teal = "rgb(109, 201, 202)"
$sky = "rgb(125, 207, 255)"
$sapphire = "rgb(108, 190, 237)"
$blue = "rgb(122, 162, 247)"
$lavender = "rgb(180, 190, 254)"

$text = "rgb(192, 202, 245)"
$subtext1 = "rgb(169, 177, 214)"
$subtext0 = "rgb(144, 157, 186)"
$overlay2 = "rgb(110, 122, 147)"
$overlay1 = "rgb(86, 95, 137)"
$overlay0 = "rgb(65, 72, 104)"
$surface2 = "rgb(51, 70, 124)"
$surface1 = "rgb(40, 42, 54)"
$surface0 = "rgb(30, 31, 40)"
$base = "rgb(26, 27, 38)"
$mantle = "rgb(22, 23, 33)"
$crust = "rgb(17, 18, 27)"
```

---

## Phase 4: Niri Configuration

### Create Main Niri Configuration
**File: `~/.config/niri/config.kdl`**
```kdl
// Include color scheme
include "colors/mocha.kdl"

// Input configuration
input {
    keyboard {
        xkb {
            layout = "us"
        }
    }
    touchpad {
        natural-scroll = false
    }
    mouse {
        sensitivity = -0.5
    }
}

// Output configuration
output "LVDS-1" {
    mode = "1366x768@60Hz"
    position = { x = 0, y = 0 }
}

// General layout settings
layout {
    gaps = 1 // 1px gaps
    border {
        width = 1
        active-color = $blue
        inactive-color = $overlay0
        focused-window = $blue
    }
    focus-ring {
        width = 4
        active-color = $mauve
        inactive-color = $overlay0
    }
    preset-column-widths = [
        { proportion = 0.33333333 },
        { proportion = 0.5 },
        { proportion = 0.66666667 }
    ]
    default-preset-column-width = { proportion = 0.5 }
}

// Window rules
window-rule {
    geometry-corner-radius = 10
    clip-to-geometry = true
    draw-border-with-background = true
    paint-interior-bg = true
    interior-bg = { color = $base }
}

// Workspaces
workspace "1" { }
workspace "2" { }
workspace "3" { }
workspace "4" { }
workspace "5" { }
workspace "6" { }
workspace "7" { }
workspace "8" { }
workspace "9" { }
workspace "10" { }

// Keybindings
spawn-at-startup "wezterm"
spawn-at-startup "zen-browser"
spawn-at-startup "hypridle"
# Note: wlsunset will be started/managed by Noctalia Night Light
spawn-at-startup "qs --config noctalia-shell"

let mod = "Super"

// Application launcher (Noctalia built-in)
bind "Super Space" { spawn "qs" "--config" "noctalia-shell" "ipc" "call" "launcher" "toggle" }

// Window management
bind "Super Return" { spawn "wezterm" }
bind "Super C" { close-window }
bind "Super V" { toggle-float }

// Focus movement (vi-style)
bind "Super H" { focus-column-left }
bind "Super L" { focus-column-right }
bind "Super K" { focus-window-up }
bind "Super J" { focus-window-down }

// Window movement
bind "Super Shift H" { move-column-left }
bind "Super Shift L" { move-column-right }
bind "Super Shift K" { move-window-up }
bind "Super Shift J" { move-window-down }

// Workspace switching
bind "Super 1" { focus-workspace "1" }
bind "Super 2" { focus-workspace "2" }
bind "Super 3" { focus-workspace "3" }
bind "Super 4" { focus-workspace "4" }
bind "Super 5" { focus-workspace "5" }
bind "Super 6" { focus-workspace "6" }
bind "Super 7" { focus-workspace "7" }
bind "Super 8" { focus-workspace "8" }
bind "Super 9" { focus-workspace "9" }
bind "Super 0" { focus-workspace "10" }

// Move window to workspace
bind "Super Shift 1" { move-column-to-workspace "1" }
bind "Super Shift 2" { move-column-to-workspace "2" }
bind "Super Shift 3" { move-column-to-workspace "3" }
bind "Super Shift 4" { move-column-to-workspace "4" }
bind "Super Shift 5" { move-column-to-workspace "5" }
bind "Super Shift 6" { move-column-to-workspace "6" }
bind "Super Shift 7" { move-column-to-workspace "7" }
bind "Super Shift 8" { move-column-to-workspace "8" }
bind "Super Shift 9" { move-column-to-workspace "9" }
bind "Super Shift 0" { move-column-to-workspace "10" }

// Layout controls
bind "Super P" { switch-preset-layout }
bind "Super Slash" { switch-layout-between "splitv" "splith" }

// Multimedia keys
bind "XF86AudioRaiseVolume" { spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+" }
bind "XF86AudioLowerVolume" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" }
bind "XF86AudioMute" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" }
bind "XF86AudioMicMute" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" }
bind "XF86MonBrightnessUp" { spawn "brightnessctl" "-e4" "-n2" "set" "5%+" }
bind "XF86MonBrightnessDown" { spawn "brightnessctl" "-e4" "-n2" "set" "5%-" }

// Media controls
bind "XF86AudioPlay" { spawn "playerctl" "play-pause" }
bind "XF86AudioPause" { spawn "playerctl" "play-pause" }
bind "XF86AudioNext" { spawn "playerctl" "next" }
bind "XF86AudioPrev" { spawn "playerctl" "previous" }

// System controls
bind "Super B" { spawn "qs" "--config" "noctalia-shell" "ipc" "call" "lockScreen" "lock" }
bind "Super W" { spawn "zen-browser" }
bind "Super E" { spawn "wezterm" "-e" "yazi" }
bind "Super Q" { spawn "~/.config/hypr/toggle_bluetooth.sh" }

// Resize mode
bind "Super R" { enter-mode "resize" }

mode "resize" {
    bind "H" { resize-column "-10" }
    bind "L" { resize-column "+10" }
    bind "K" { resize-row "+10" }
    bind "J" { resize-row "-10" }
    bind "Escape" { leave-mode }
}

// Environment variables
environment {
    XCURSOR_SIZE = "24"
    ELECTRON_ENABLE_FRACTIONAL_SCALING = "true"
}
```

---

## Phase 5: hypridle Configuration

### Update hypridle Configuration for Noctalia Integration
Update your existing `~/.config/hypr/hypridle.conf` to use Noctalia's lock screen:

**Updated File: `~/.config/hypr/hypridle.conf`**
```ini
general {
    lock_cmd = qs --config noctalia-shell ipc call lockScreen lock
    before_sleep_cmd = qs --config noctalia-shell ipc call lockScreen lock
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 10
    on-timeout = brightnessctl -s set 10
    on-resume = brightnessctl -r
}

listener {
    timeout = 10
    on-timeout = brightnessctl -sd rgb:kbd_backlight set 0
    on-resume = brightnessctl -rd rgb:kbd_backlight
}

listener {
    timeout = 300
    on-timeout = qs --config noctalia-shell ipc call lockScreen lock
}

listener {
    timeout = 30
    on-timeout = qs --config noctalia-shell ipc call brightness set 0
    on-resume = qs --config noctalia-shell ipc call brightness set 50 && brightnessctl -r
}

listener {
    timeout = 1800
    on-timeout = systemctl suspend
}
```

### Verify hypridle Configuration
```bash
# Test the updated config
hypridle --dry-run
```

---

## Phase 6: wlsunset Configuration

### wlsunset Configuration Note
wlsunset will be managed directly by Noctalia's Night Light feature - no standalone configuration or service needed. Noctalia will handle:
- Starting/stopping wlsunset
- Setting temperature schedules (day: 6500K, night: 4000K)
- Managing transition times (7:30 AM sunrise, 6:30 PM sunset)

---

## Phase 7: Noctalia Configuration

### Noctalia Core Features
Noctalia will handle:
- **App Launcher** (replaces wofi) - Built-in, triggered by Super+Space
- **Notifications** (replaces dunst/mako) - Native notification daemon
- **Lock Screen** (replaces hyprlock) - Native locking mechanism
- **Night Light** (manages wlsunset) - Blue light control interface
- **Complement to hypridle** - Adds Stay-Awake and additional features

### Configure Noctalia Components
1. **Launcher**: Use `qs --config noctalia-shell ipc call launcher toggle`
2. **Lock Screen**: Use `qs --config noctalia-shell ipc call lockScreen lock`
3. **Night Light**: Noctalia controls wlsunset automatically via `nightLight` target
4. **Notifications**: Built-in notification daemon with `notifications` target
5. **Stay-Awake**: Optional override for hypridle when needed

### Key IPC Commands
```bash
# App launcher
qs --config noctalia-shell ipc call launcher toggle

# Lock screen
qs --config noctalia-shell ipc call lockScreen lock

# Optional: Stay-Awake toggle (overrides hypridle when enabled)
qs --config noctalia-shell ipc call idleInhibitor enable
qs --config noctalia-shell ipc call idleInhibitor disable

# Night Light
qs --config noctalia-shell ipc call nightLight toggle

# Notifications
qs --config noctalia-shell ipc call notifications toggleDND
```

### Noctalia Settings
Configure through Noctalia UI (already configured in your settings.json):
- **Night Light**: Auto-schedule enabled, day temp 6500K, night temp 4000K
- **Notifications**: Already enabled, top-right location with appropriate timeouts
- **Lock Screen**: Configured with avatar, countdown, and session buttons
- **hypridle Integration**: Keep hypridle as primary, Noctalia's idleInhibitor for temporary overrides

### Integration Notes
- hypridle remains your primary idle manager (familiar, easy to configure)
- Noctalia's `idleInhibitor` can temporarily override hypridle when needed
- Night Light automatically manages wlsunset backend
- Lock screen integration works seamlessly with hypridle
- All components work through unified IPC interface but respect hypridle's primary role

---

## Phase 8: System Integration

### Configure Lid Handling

#### Edit systemd-logind Configuration
**Edit `/etc/systemd/logind.conf`** (requires sudo):
```bash
sudo nano /etc/systemd/logind.conf
```

Find and update these lines (remove the # comment):
```ini
HandleLidSwitch=suspend
HandleLidSwitchExternalMonitor=ignore
HandleLidSwitchDocked=ignore
```

#### Restart systemd-logind
```bash
sudo systemctl restart systemd-logind
```

#### Test Lid Behavior
```bash
# Check current settings
loginctl show-session "$(loginctl | grep $(whoami) | head -1 | awk '{print $1}')" -p HandleLidSwitch

# Verify logind is running
systemctl status systemd-logind
```

---

## Phase 9: Migration Script

### Create Migration Script
**File: `~/.config/migrate-to-niri.sh`**
```bash
#!/bin/bash

echo "Starting migration to Niri + Noctalia..."

# Create directories
mkdir -p ~/.config/niri/colors
mkdir -p ~/.config/wlsunset
mkdir -p ~/.config/noctalia

# Backup current config
BACKUP_DIR="$HOME/.config/hypr_backup/hypr_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.config/hypr "$BACKUP_DIR/"

echo "Configuration backed up to: $BACKUP_DIR"

# Stop current services (keep hypridle!)
pkill hyprsunset
pkill wofi

# Note: wlsunset will be started/managed by Noctalia, hypridle stays
echo "Keeping hypridle, Noctalia will manage wlsunset automatically"

echo "Migration complete! Restart your session to use Niri."
```

### Make Migration Script Executable
```bash
chmod +x ~/.config/migrate-to-niri.sh
```

---

## Phase 10: Testing and Validation

### Test Individual Components
```bash
# Test Niri configuration
niri --verify

# Test hypridle (should already work)
hypridle --dry-run

# Test wlsunset
wlsunset -h

# Test Noctalia components
qs --config noctalia-shell ipc call launcher toggle      # Test launcher
qs --config noctalia-shell ipc call lockScreen lock      # Test lock screen
qs --config noctalia-shell ipc call nightLight toggle    # Test night light
qs --config noctalia-shell ipc show                       # Show all available targets
```

### Validate Migration
1. Check that all keybinds work
2. Verify Noctalia app launcher functions (Super+Space)
3. Test Noctalia lock screen (Super+B) 
4. Verify Noctalia notifications work
5. Confirm hypridle timeouts still work (familiar behavior)
6. Confirm Noctalia's Night Light controls wlsunset
7. **Test lid behavior**: Close lid → should suspend. Open lid → should wake on Noctalia lock screen
8. Optional: Test Stay-Awake override with `qs --config noctalia-shell ipc call idleInhibitor toggle`

---

## Phase 11: Cleanup

### Remove Hyprland Dependencies
```bash
# Optionally remove Hyprland packages (keep hypridle!)
sudo pacman -Rs hyprland hyprpaper hyprsunset hyprlock

# Keep hypridle for easier idle management
```

### Update Display Manager
If using a display manager (SDDM, GDM, etc.), update the session to use Niri.

---

## Troubleshooting

### Common Issues

1. **Keybinds not working**: Check Niri config syntax with `niri --verify`
2. **Idle management not working**: Ensure hypridle is running and lock screen commands work
3. **Night Light not working**: Check Noctalia Night Light settings - wlsunset should be managed automatically
4. **App launcher not working**: Check Noctalia is running and `qs --config noctalia-shell ipc call launcher toggle` works
5. **Lock screen not working**: Verify `qs --config noctalia-shell ipc call lockScreen lock` works from terminal
6. **Notifications not working**: Check Noctalia is running and notification daemon is enabled
7. **hypridle conflicts**: Ensure no other idle managers are running
8. **Lid not working**: Check `/etc/systemd/logind.conf` settings and restart systemd-logind
9. **Lid not locking on open**: Verify `before_sleep_cmd` in hypridle.conf is set correctly

### Useful Commands
```bash
# Check running processes
ps aux | grep -E "(niri|hypridle|wlsunset|noctalia)"

# Check Noctalia status
qs --config noctalia-shell ipc call state all

# Test keybinds
niri --debug

# Check Noctalia integration
qs --config noctalia-shell ipc call launcher toggle  # Test launcher
qs --config noctalia-shell ipc call lockScreen lock  # Test lock
ps aux | grep wlsunset   # Verify wlsunset running (managed by Noctalia)
```

---

## Rollback Plan

If migration fails, restore backup:
```bash
# Restore Hyprland config
cp -r ~/.config/hypr_backup/hypr_YYYYMMDD_HHMMSS/hypr ~/.config/

# Stop new services (don't stop hypridle!)
pkill wlsunset

# Restart session
```

---

## Post-Migration Optimizations

1. **Performance**: Monitor CPU/memory usage of new components
2. **Battery Life**: Compare power consumption
3. **Usability**: Fine-tune timeouts and behaviors
4. **Integration**: Enhance Noctalia customizations

---

**Migration Complete!** 🎉

You now have a Niri + Noctalia setup with:
- Modern Wayland compositor (Niri)
- Centralized system control (Noctalia)
- Familiar idle management (hypridle + Noctalia lock screen integration)
- Built-in app launcher, notifications, lock screen (Noctalia)
- Automatic blue light management (Noctalia + wlsunset)
- Optional Stay-Awake override when needed
- Easy configuration with your existing hypridle knowledge
