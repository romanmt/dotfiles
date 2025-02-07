#!/bin/zsh

. ./setup.sh
# Check if iTerm is installed
if check_command_installed "open -a iTerm"; then
    echo "Skipping asdf installation."
else
    brew install --cask iterm2
fi
