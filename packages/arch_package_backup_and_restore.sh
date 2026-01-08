#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PKGLIST="pkglist.txt"
AURLIST="aurlist.txt"

SKIP_PKGS=(
  linux linux-lts linux-zen linux-hardened
  virtualbox-host-modules-arch
  linux-firmware
  nvidia nvidia-dkms nvidia-utils nvidia-settings nvidia-lts
  xf86-video-amdgpu vulkan-radeon
  xf86-video-intel vulkan-intel
  xf86-video-nouveau
  intel-ucode amd-ucode
  grub systemd-boot-pacman-hook refind lilo
  paru paru-debug
)

backup() {
  echo "📦 Backing up package lists..."

  pacman -Qqe > "$PKGLIST.all"
  pacman -Qm  > "$AURLIST.all"

  BASE_PKGS="$(comm -12 \
    <(pacman -Qq 2>/dev/null | sort) \
    <(pacman -Sgq base base-devel 2>/dev/null | sort) || true)"

  {
    printf "%s\n" $BASE_PKGS
    printf "%s\n" "${SKIP_PKGS[@]}"
  } | sort -u > /tmp/skip_all.txt

  grep -vxFf /tmp/skip_all.txt "$PKGLIST.all" \
    | grep -vxFf <(awk '{print $1}' "$AURLIST.all") \
    | grep -v -- '-debug$' \
    > "$PKGLIST"

  awk '{print $1}' "$AURLIST.all" \
    | grep -v -- '-debug$' \
    | grep -vE '^(paru|yay-debug)$' \
    > "$AURLIST"

  rm "$PKGLIST.all" "$AURLIST.all" /tmp/skip_all.txt

  echo "✅ Saved:"
  echo "  - $PKGLIST"
  echo "  - $AURLIST"
}

restore() {
  local dryrun="${1:-}"

  if [[ "$dryrun" != "--dry-run" ]]; then
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel git
  fi

  if [[ -f "$PKGLIST" ]]; then
    sed '/^[[:space:]]*$/d' "$PKGLIST" > "$PKGLIST.clean"
    if [[ "$dryrun" == "--dry-run" ]]; then
      cat "$PKGLIST.clean"
    else
      sudo pacman -S --needed --noconfirm - < "$PKGLIST.clean"
    fi
    rm "$PKGLIST.clean"
  fi

  if ! command -v yay &>/dev/null && [[ "$dryrun" != "--dry-run" ]]; then
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    (cd "$tmpdir" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
  fi

  if [[ -f "$AURLIST" ]]; then
    sed '/^[[:space:]]*$/d' "$AURLIST" > "$AURLIST.clean"
    if [[ "$dryrun" == "--dry-run" ]]; then
      cat "$AURLIST.clean"
    else
      yay -S --needed - < "$AURLIST.clean" || true
    fi
    rm "$AURLIST.clean"
  fi

  echo "✅ Restore complete"
}

case "${1:-}" in
  backup) backup ;;
  restore) restore ;;
  restore-dry) restore --dry-run ;;
  *) echo "Usage: $0 {backup|restore|restore-dry}" ;;
esac

