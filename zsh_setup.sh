#!/bin/bash

echo "Adding oh-my-zsh to your environment..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Adding homebrew to your environment..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


echo "Moving .zshrc file to your home directory..."
cp -fr .zshrc ~

echo "Adding font-jetbrains-mono to your environment..."
brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font

echo "Moving aliases to your home directory..."
cp -R .zsh ~

echo "Adding zsh plugins..."

echo "Adding fast-syntax-highlighting..."
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.zsh

echo "Adding zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh
