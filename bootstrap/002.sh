#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dottfiles_laptop"

echo "==> Installing packages"

if ! command -v yay &>/dev/null; then
  echo "Installing yay"
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir"
  (cd "$tmpdir" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

cd "$DOTFILES/packages"
./arch_package_backup_and_restore.sh restore

echo "==> Packages installed"

