#!/bin/bash
set -Eeuo pipefail

PKGLIST="pkglist.txt"
AURLIST="aurlist.txt"
LOGFILE="restore.log"

SKIP_PKGS=(
  linux linux-lts linux-zen linux-hardened
  linux-firmware
  nvidia nvidia-dkms nvidia-utils nvidia-settings nvidia-lts
  xf86-video-amdgpu vulkan-radeon
  xf86-video-intel vulkan-intel
  xf86-video-nouveau
  intel-ucode amd-ucode
  grub systemd-boot-pacman-hook refind lilo
  paru paru-debug yay-debug
)

log() { echo -e "$@" | tee -a "$LOGFILE"; }

ensure_keyring() {
  if ! pacman-key --list-keys &>/dev/null; then
    log "🔑 Initializing pacman keyring..."
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
    sudo pacman -Sy --noconfirm archlinux-keyring
  fi
}

ensure_base_tools() {
  log "🧰 Ensuring base-devel & git..."
  sudo pacman -S --needed --noconfirm base-devel git
}

ensure_yay() {
  if yay -Y --version &>/dev/null; then
    log "✅ yay is available"
    return
  fi

  log "📦 Installing yay..."
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp"
  (cd "$tmp" && makepkg -si --noconfirm)
  rm -rf "$tmp"
}

restore_repo_packages() {
  [[ ! -f "$PKGLIST" ]] && return

  log "📥 Installing repo packages..."

  comm -12 \
    <(sort "$PKGLIST") \
    <(pacman -Slq | sort) \
    | sudo pacman -S --needed --noconfirm - \
    || log "⚠️ Some repo packages failed (see pacman output)"
}

restore_aur_packages() {
  [[ ! -f "$AURLIST" ]] && return
  [[ ! -s "$AURLIST" ]] && return

  log "📥 Installing AUR packages..."
  yay -S --needed --noconfirm - < "$AURLIST" \
    || log "⚠️ Some AUR packages failed"
}

backup() {
  log "📦 Backing up package lists..."

  pacman -Qqe > "$PKGLIST.all"
  pacman -Qm > "$AURLIST.all"

  BASE_PKGS=$(comm -12 \
    <(pacman -Qq | sort) \
    <(pacman -Sgq base base-devel | sort))

  grep -vxFf <(printf "%s\n" $BASE_PKGS "${SKIP_PKGS[@]}") "$PKGLIST.all" \
    | grep -vxFf <(pacman -Qm | awk '{print $1}') \
    | grep -v -- '-debug$' \
    > "$PKGLIST"

  awk '{print $1}' "$AURLIST.all" \
    | grep -v -- '-debug$' \
    | grep -vE '^(paru|yay-debug)$' \
    > "$AURLIST"

  rm "$PKGLIST.all" "$AURLIST.all"

  log "✅ Backup complete:"
  log "  - $(wc -l < "$PKGLIST") repo packages"
  log "  - $(wc -l < "$AURLIST") AUR packages"
}

restore() {
  : > "$LOGFILE"
  log "🔄 Starting restore..."

  ensure_keyring
  sudo pacman -Syu --noconfirm
  ensure_base_tools
  restore_repo_packages
  ensure_yay
  restore_aur_packages

  log "✅ Restore finished"
}

dryrun() {
  log "🔍 Dry run (repo packages that exist):"
  comm -12 <(sort "$PKGLIST") <(pacman -Slq | sort)

  log "🔍 AUR packages:"
  cat "$AURLIST" 2>/dev/null || true
}

case "${1:-}" in
  backup) backup ;;
  restore) restore ;;
  restore-dry) dryrun ;;
  *)
    echo "Usage: $0 {backup|restore|restore-dry}"
    exit 1
    ;;
esac


