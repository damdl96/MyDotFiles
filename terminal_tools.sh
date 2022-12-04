
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

echo "Installing nvm..."
brew install nvm

echo "Installing node LTS version..."
nvm install --lts

echo "Installing ngrok..."
brew install ngrok/ngrok/ngrok

echo "Installing rails..."
gem install rails
