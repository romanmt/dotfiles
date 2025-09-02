#!/bin/zsh

echo "🍺 Setting up Homebrew..."

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

# Function to install Homebrew
function install_homebrew() {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -eq 0 ]; then
        echo "✅ Homebrew installation successful."
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "❌ Homebrew installation failed."
        exit 1
    fi
}

# Check if Homebrew is installed
if check_command_installed "brew"; then
    echo "✅ Homebrew is already installed, skipping installation."
else
    install_homebrew
fi

echo "✅ Homebrew setup complete"
