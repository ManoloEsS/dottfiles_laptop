#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dottfiles_laptop"

echo "==> Installing packages"

if ! command -v yay &>/dev/null; then
  echo "Installing yay"
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

cd "$DOTFILES/packages"
./arch_package_backup_and_restore.sh restore

echo "==> Packages installed"

