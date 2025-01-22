#!/bin/zsh

. ./setup.sh
# Check if iTerm is installed
if [ -d "/Applications/iTerm.app" ]; then
    echo "Skipping iterm installation."
else
    brew install --cask iterm2
    brew install font-hack-nerd-font
    gem install colorls
fi
