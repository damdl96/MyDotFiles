#!/bin/bash

# Install a package using whatever package manager is available.
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

echo "Installing tmux..."
install_packages tmux

echo "Linking tmux configuration from this repo into ~/.tmux.conf..."
# Resolve the directory this script lives in, so it works from any clone location
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TMUX_SRC="$REPO_DIR/.tmux.conf"
TMUX_DEST="$HOME/.tmux.conf"

if [ -L "$TMUX_DEST" ]; then
  echo "  ~/.tmux.conf is already a symlink, replacing it."
  rm "$TMUX_DEST"
elif [ -e "$TMUX_DEST" ]; then
  BAK="$TMUX_DEST.bak-$(date +%Y%m%d-%H%M%S)"
  echo "  Existing ~/.tmux.conf found, backing up to $BAK"
  mv "$TMUX_DEST" "$BAK"
fi

ln -s "$TMUX_SRC" "$TMUX_DEST"
echo "  Linked $TMUX_DEST -> $TMUX_SRC"

echo "Adding tmux plugin manager (TPM)..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "  TPM already present at ~/.tmux/plugins/tpm, skipping clone."
else
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Done. Start tmux and press PREFIX + I (Ctrl-a then Shift-i) to install plugins."
