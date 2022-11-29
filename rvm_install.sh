#!/bin/bash

echo "Installing GnuPG"
brew install gnupg

echo "Setting keys for instalation"
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

echo "Installing RVM"
\curl -sSL https://get.rvm.io | bash

