#!/bin/zsh

# Oh My Zsh and plugins setup script
# This script ensures Oh My Zsh and required custom plugins are installed

echo "==== Setting up Oh My Zsh and plugins ===="

# Function to check if a command is installed
function check_command_installed {
    local command_name=$1
    if command -v $command_name &> /dev/null; then
        echo "✅ $command_name is already installed."
        return 0
    else
        echo "❌ $command_name is not installed."
        return 1
    fi
}

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installed successfully."
else
    echo "✅ Oh My Zsh is already installed."
fi

# Ensure custom plugins directory exists
mkdir -p "$HOME/.oh-my-zsh/custom/plugins"

# Install zsh-autosuggestions plugin
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions plugin installed successfully."
else
    echo "✅ zsh-autosuggestions plugin is already installed."
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    echo "✅ zsh-syntax-highlighting plugin installed successfully."
else
    echo "✅ zsh-syntax-highlighting plugin is already installed."
fi

# Install Powerlevel10k theme via Homebrew (as per your current setup)
if check_command_installed "brew"; then
    if brew list | grep -q powerlevel10k; then
        echo "✅ Powerlevel10k is already installed via Homebrew."
    else
        echo "Installing Powerlevel10k via Homebrew..."
        brew install powerlevel10k
        echo "✅ Powerlevel10k installed successfully."
    fi
else
    echo "⚠️  Homebrew not found. Please install Homebrew first."
fi

echo "==== Oh My Zsh setup complete! ===="
echo "Configured plugins:"
echo "  - git, gitfast, gh"
echo "  - asdf"
echo "  - python, pip, mix, ruby" 
echo "  - fzf, z, copypath, copyfile, extract"
echo "  - macos, brew, vscode"
echo "  - zsh-autosuggestions (custom)"
echo "  - zsh-syntax-highlighting (custom)"
echo "  - web-search"
