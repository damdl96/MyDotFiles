#!/bin/bash

echo "Installing tmux on your computer"
brew install tmux

echo "Adding tmux configuration file on your computer"
cp -R .tmux.conf ~

echo "Adding tmux plugins..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
