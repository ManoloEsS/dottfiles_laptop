#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dottfiles_laptop"
STOW_DIRS=(fontconfig hypr pl10k tmux waybar wezterm wofi zsh)

# Warn about potential stow conflicts
echo "⚠️  Checking for conflicting files..."
for dir in "${STOW_DIRS[@]}"; do
  if [[ -d "$DOTFILES/$dir" ]]; then
    while IFS= read -r -d '' file; do
      target="${file#$DOTFILES/$dir}"
      if [[ -e "$HOME$target" ]] && [[ ! -L "$HOME$target" ]]; then
        echo "⚠️  Conflict: $HOME$target exists (will be backed up)"
        mkdir -p "$HOME/.dotfiles_backup"
        mv "$HOME$target" "$HOME/.dotfiles_backup/$(basename "$target").$(date +%s)"
      fi
    done < <(find "$DOTFILES/$dir" -type f -print0 2>/dev/null)
  fi
done

echo "==> Setting up user environment"

# --------------------------------------------------------------------
# SAFETY GUARDS
# --------------------------------------------------------------------
if [[ "$EUID" -eq 0 ]]; then
  echo "❌ Do NOT run this script as root"
  exit 1
fi

if [[ ! -d "$DOTFILES" ]]; then
  echo "❌ Dotfiles directory not found: $DOTFILES"
  exit 1
fi

# --------------------------------------------------------------------
# SHELL (INTENTIONALLY NOT CHANGED)
# --------------------------------------------------------------------
echo "ℹ️  Skipping shell change (recommended)"
echo "   You can change to zsh later with: chsh -s /bin/zsh"

# --------------------------------------------------------------------
# OH MY ZSH (SAFE — NO LOGIN MODIFICATION)
# --------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "📥 Installing Oh My Zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  echo "✅ Oh My Zsh already installed"
fi

# --------------------------------------------------------------------
# ZSH PLUGINS / THEME (CLONE-ONLY, NO SYSTEM TOUCH)
# --------------------------------------------------------------------
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

clone() {
  local repo="$1"
  local target="$2"

  if [[ ! -d "$target" ]]; then
    echo "📥 Cloning $(basename "$repo")"
    git clone --depth=1 "$repo" "$target"
  else
    echo "✅ $(basename "$repo") already present"
  fi
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

# --------------------------------------------------------------------
# STOW DOTFILES (NO DELETIONS, SAFE RE-RUN)
# --------------------------------------------------------------------
cd "$DOTFILES"

for dir in "${STOW_DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "📦 Stowing $dir"
    stow -R "$dir"
  else
    echo "⚠️  Skipping missing stow dir: $dir"
  fi
done

# --------------------------------------------------------------------
# VERIFICATION (NON-DESTRUCTIVE)
# --------------------------------------------------------------------
REQ_FILES=(
  "$HOME/.zshrc"
  "$HOME/.config/hypr/hyprland.conf"
)

echo "🔍 Verifying critical files"
for f in "${REQ_FILES[@]}"; do
  [[ -e "$f" ]] || { echo "❌ Missing $f"; exit 1; }
done

echo "==> User environment ready"
echo "ℹ️  When ready, switch shell manually with:"
echo "   chsh -s /bin/zsh"


