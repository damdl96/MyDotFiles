#!/bin/bash

# Install a list of packages using whatever package manager is available.
# Package names happen to be identical across brew/apt/dnf/pacman here
# (neovim, ripgrep), so one helper covers every platform.
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

echo "Installing NeoVim and RipGrep..."
# brew calls neovim "nvim"; apt/dnf/pacman all call it "neovim".
if command -v brew >/dev/null 2>&1; then
  install_packages nvim ripgrep
else
  install_packages neovim ripgrep
fi

echo "Installing gems to satisfy nvim config requirements..."
if command -v gem >/dev/null 2>&1; then
  gem install solargraph rdoc irb rubocop yarn
else
  echo "  Ruby/gem not found. Install Ruby first, then run:"
  echo "    gem install solargraph rdoc irb rubocop yarn"
fi

echo "Linking nvim config from this repo into ~/.config/nvim..."
# Resolve the directory this script lives in, so it works from any clone location
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_SRC="$REPO_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"

mkdir -p "$HOME/.config"

if [ -L "$NVIM_DEST" ]; then
  echo "  ~/.config/nvim is already a symlink, replacing it."
  rm "$NVIM_DEST"
elif [ -e "$NVIM_DEST" ]; then
  BAK="$NVIM_DEST.bak-$(date +%Y%m%d-%H%M%S)"
  echo "  Existing ~/.config/nvim found, backing up to $BAK"
  mv "$NVIM_DEST" "$BAK"
fi

ln -s "$NVIM_SRC" "$NVIM_DEST"
echo "  Linked $NVIM_DEST -> $NVIM_SRC"

echo "Done. Launch nvim once to let lazy.nvim install the plugins."
