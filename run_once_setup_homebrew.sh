#!/bin/zsh

# Function to install Homebrew
function install_homebrew {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -eq 0 ]; then
        echo "Homebrew installation successful."
    else
        echo "Homebrew installation failed."
        exit 1
    fi
}

. ./setup.sh
# Check if Homebrew is installed
if check_command_installed "brew"; then
    echo "Skipping Homebrew installation."
else
    install_homebrew
fi
