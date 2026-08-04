#!/bin/bash

# Install packages using whatever package manager is available.
install_packages() {
  if command -v brew >/dev/null 2>&1; then
    brew install "$@"
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$@"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm "$@"
  else
    echo "  No supported package manager found (brew/apt/dnf/pacman)."
    echo "  Please install manually: $*"
    return 1
  fi
}

# Resolve the repo location so the bootstrap works from any clone path.
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing zsh..."
install_packages zsh

echo "Adding oh-my-zsh to your environment..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  oh-my-zsh already installed, skipping."
else
  # --unattended: don't chsh or launch a new shell.
  # --keep-zshrc: do NOT overwrite ~/.zshrc; this script manages it below.
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

echo "Installing a Nerd Font (Hack)..."
if command -v brew >/dev/null 2>&1; then
  brew install --cask font-hack-nerd-font
else
  # Linux: drop the font into the user font dir and refresh the cache.
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if command -v curl >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
    curl -fsSL -o /tmp/Hack.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    unzip -o /tmp/Hack.zip -d "$FONT_DIR" >/dev/null
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$FONT_DIR"
    echo "  Installed Hack Nerd Font to $FONT_DIR"
  else
    echo "  Please install a Nerd Font manually (needs curl + unzip)."
  fi
fi

echo "Adding zsh plugins into ~/.zsh..."
mkdir -p "$HOME/.zsh"
if [ -d "$HOME/.zsh/fast-syntax-highlighting" ]; then
  echo "  fast-syntax-highlighting already present, skipping."
else
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting \
    "$HOME/.zsh/fast-syntax-highlighting"
fi
if [ -d "$HOME/.zsh/zsh-autosuggestions" ]; then
  echo "  zsh-autosuggestions already present, skipping."
else
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.zsh/zsh-autosuggestions"
fi

echo "Setting up your ~/.zshrc..."
# The repo holds the SHARED config. The machine-local ~/.zshrc is a small
# bootstrap that (1) sources the shared repo config and (2) sources a
# git-ignored ~/.zshrc.local for machine-specific paths and SECRETS.
if [ -e "$HOME/.zshrc" ]; then
  echo "  ~/.zshrc already exists - leaving it untouched."
  echo "  Make sure it contains:  source \"$REPO_DIR/.zshrc\""
else
  cat > "$HOME/.zshrc" <<EOF
# Shared config (tracked in the dotfiles repo)
source "$REPO_DIR/.zshrc"

# Machine-specific paths and secrets (NOT tracked by git)
[ -f "\$HOME/.zshrc.local" ] && source "\$HOME/.zshrc.local"
EOF
  echo "  Wrote bootstrap ~/.zshrc that sources the repo + ~/.zshrc.local"
fi

# Seed a private local file for secrets / machine config if none exists.
if [ ! -e "$HOME/.zshrc.local" ]; then
  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-specific config and secrets. NOT tracked by git.
# Examples:
#   export GITHUB_TOKEN="..."
#   eval "$(rbenv init -)"
#   export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
EOF
  chmod 600 "$HOME/.zshrc.local"
  echo "  Created ~/.zshrc.local (chmod 600) for your secrets and machine paths."
fi

echo "Done. Restart your shell or run: source ~/.zshrc"
