#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles_arch_hypr"
STOW_DIRS=(fontconfig hypr pl10k tmux waybar wezterm wofi zsh)

echo "==> Setting up user environment"

### Shell
if [[ "$(command -v zsh)" != "$SHELL" ]]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
  echo "Default shell changed to zsh (relogin required)"
fi

### Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
fi

### Plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

clone() {
  [[ -d "$2" ]] || git clone --depth=1 "$1" "$2"
}

clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-completions \
  "$ZSH_CUSTOM/plugins/zsh-completions"
clone https://github.com/Aloxaf/fzf-tab \
  "$ZSH_CUSTOM/plugins/fzf-tab"
clone https://github.com/romkatv/powerlevel10k \
  "$ZSH_CUSTOM/themes/powerlevel10k"

### Stow (NO DELETION)
cd "$DOTFILES"

for dir in "${STOW_DIRS[@]}"; do
  echo "Stowing $dir"
  stow -R "$dir"
done

### Verification
REQ_FILES=(
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.config/hypr/hyprland.conf"
)

for f in "${REQ_FILES[@]}"; do
  [[ -e "$f" ]] || { echo "❌ Missing $f"; exit 1; }
done

echo "==> User environment ready"

