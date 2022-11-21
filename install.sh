#!/bin/bash

if type xcode-select >&- && xpath=$( xcode-select --print-path ) && test -d "${xpath}" && test -x "${xpath}" ; 
then
  echo "Installing Xcode command line tools"
  xcode-select --install
  echo "basic git setup..."
  sh git_setup.sh
else
  echo "basic git setup..."
  sh git_setup.sh
fi

echo "Installing github CLI..."
brew install gh

echo "configuring your terminal with zsh..."
sh zsh_setup.sh

echo "configuring tmux on your computer..."
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