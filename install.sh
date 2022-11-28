#!/bin/bash

echo "Adding basic tools and dependencies..."
sh terminal_tools.sh

echo "Configuring your terminal with zsh..."
sh zsh_setup.sh

echo "Configuring tmux on your computer..."
sh tmux_setup.sh

echo "Installing Visual Studio Code..."
brew install --cask visual-studio-code

echo "Finished! 🎉"

echo "\nFINAL ACTIONS REQUIRED\!\!👀
||==============================================================================================================||
||                                                                                                              ||
|| 👉 Set the new font in your terminal by selecting it in the terminal settings/font/change \"jetbrains-mono\"   ||
|| 👉 Once you have started tmux you have to execute the comand \"PREFIX + I\" to install the plugins             ||
||                                                                                                              ||
||==============================================================================================================||
"
