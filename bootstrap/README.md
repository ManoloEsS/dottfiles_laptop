# Bootstrap Instructions

Run these scripts in order on a fresh Arch Linux install:

## Prerequisites
- Fresh Arch Linux installation (archinstall with Hyprland profile works great)
- Network access
- A non-root user account with sudo privileges
- This repo cloned to `~/dottfiles_laptop`

## Steps

```bash
# Clone this repo first
cd ~
git clone <your-repo-url> dottfiles_laptop
cd dottfiles_laptop

# 1. Install base requirements (git, stow, zsh, base-devel)
./bootstrap/001.sh

# 2. Install packages from package lists
./bootstrap/002.sh

# 3. Set up user environment and dotfiles
./bootstrap/003.sh
```

## What Each Script Does

### 001.sh - Base System
- Installs essential tools: git, stow, zsh, curl, base-devel
- Required before other scripts

### 002.sh - Package Installation
- Installs yay AUR helper
- Restores packages from pkglist.txt and aurlist.txt
- May skip some packages not available in vanilla Arch

### 003.sh - User Environment
- Installs Oh My Zsh and plugins
- Stows dotfiles to home directory
- Backs up any conflicting existing config files to `~/.dotfiles_backup`

## Notes
- Scripts are idempotent and can be re-run safely
- Change shell manually after completion: `chsh -s /bin/zsh`
- Conflicting config files are backed up, not overwritten
