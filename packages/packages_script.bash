#!/bin/bash
set -euo pipefail

PKGLIST="pkglist.txt"
AURLIST="aurlist.txt"

# Hardware-specific packages to skip
SKIP_PKGS=(
  # Kernels
  "linux" "linux-lts" "linux-zen" "linux-hardened"

  # Firmware
  "linux-firmware"

  # NVIDIA
  "nvidia" "nvidia-dkms" "nvidia-utils" "nvidia-settings" "nvidia-lts"

  # AMD
  "xf86-video-amdgpu" "vulkan-radeon"

  # Intel
  "xf86-video-intel" "vulkan-intel"

  # Other GPUs
  "xf86-video-nouveau"

  # Microcode
  "intel-ucode" "amd-ucode"

  # Bootloaders
  "grub" "systemd-boot-pacman-hook" "refind" "lilo"
)

backup() {
    echo "📦 Backing up package lists..."

    pacman -Qqe > "$PKGLIST".tmp

    BASE_PKGS=$(comm -12 <(pacman -Qq | sort) <(pacman -Sgq base base-devel | sort))

    grep -vxFf <(printf "%s\n" $BASE_PKGS "${SKIP_PKGS[@]}") "$PKGLIST".tmp > "$PKGLIST"

    pacman -Qm > "$AURLIST"

    rm "$PKGLIST".tmp

    echo "✅ Package lists saved:"
    echo "  - $(wc -l < "$PKGLIST") pacman packages (user only) → $PKGLIST"
    echo "  - $(wc -l < "$AURLIST") AUR packages                → $AURLIST"
}

restore() {
    local dryrun="${1:-}"

    if [[ "$dryrun" == "--dry-run" ]]; then
        echo "🔍 Dry run: packages that would be installed"
    else
        echo "🔄 Restoring packages..."
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm base-devel git
    fi

    if [[ -f "$PKGLIST" ]]; then
        echo "📥 Pacman packages:"
        if [[ "$dryrun" == "--dry-run" ]]; then
            pacman -S --needed --print-format "%n" - < "$PKGLIST" || true
        else
            sudo pacman -S --needed - < "$PKGLIST"
        fi
    fi

    if ! command -v yay &>/dev/null; then
        if [[ "$dryrun" == "--dry-run" ]]; then
            echo "📥 Would install yay (AUR helper)"
        else
            echo "📥 Installing yay..."
            tmpdir=$(mktemp -d)
            git clone https://aur.archlinux.org/yay.git "$tmpdir"
            (cd "$tmpdir" && makepkg -si --noconfirm)
            rm -rf "$tmpdir"
        fi
    fi

    if [[ -f "$AURLIST" ]]; then
        echo "📥 AUR packages:"
        if [[ "$dryrun" == "--dry-run" ]]; then
            cat "$AURLIST"
        else
            yay -S --needed - < "$AURLIST"
        fi
    fi

    if [[ "$dryrun" == "--dry-run" ]]; then
        echo "✅ Dry run complete (no changes made)"
    else
        echo "✅ Restore complete!"
    fi
}

case "${1:-}" in
    backup) backup ;;
    restore) restore ;;
    restore-dry) restore --dry-run ;;
    *)
        echo "Usage: $0 {backup|restore|restore-dry}"
        exit 1
        ;;
esac

