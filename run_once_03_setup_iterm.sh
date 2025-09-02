#!/bin/zsh

echo "💻 Setting up iTerm2..."

# Function to check if a command is installed (inline for this script)
function check_command_installed() {
    local command_name=$1
    if command -v $command_name &> /dev/null; then
        echo "$command_name is already installed."
        return 0
    else
        echo "$command_name is not installed."
        return 1
    fi
}

# Ensure Homebrew is available
if ! check_command_installed "brew"; then
    echo "❌ Homebrew is required but not found. Please install Homebrew first."
    exit 1
fi

# Check if iTerm2 is installed by checking for the app
if [ -d "/Applications/iTerm.app" ]; then
    echo "✅ iTerm2 is already installed, skipping installation."
else
    echo "Installing iTerm2..."
    brew install --cask iterm2
    if [ $? -eq 0 ]; then
        echo "✅ iTerm2 installation successful."
    else
        echo "❌ iTerm2 installation failed."
        exit 1
    fi
fi

echo "✅ iTerm2 setup complete"
