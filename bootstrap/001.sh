#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking base requirements"

if [[ $EUID -eq 0 ]]; then
  echo "❌ Do not run as root"
  exit 1
fi

sudo -v

BASE_PKGS=(git stow zsh curl)

for pkg in "${BASE_PKGS[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    echo "Installing $pkg"
    sudo pacman -S --noconfirm "$pkg"
  fi
done

echo "==> Base system ready"

