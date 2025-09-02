#!/bin/zsh

echo "🔠 Setting up fonts and Powerlevel10k..."

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

# Install Powerlevel10k
echo "Installing Powerlevel10k..."
if brew list powerlevel10k &>/dev/null; then
    echo "✅ Powerlevel10k is already installed."
else
    brew install romkatv/powerlevel10k/powerlevel10k
    if [ $? -eq 0 ]; then
        echo "✅ Powerlevel10k installation successful."
        
        # Add to zshrc if not already there
        if ! grep -q "powerlevel10k" ~/.zshrc; then
            echo "" >> ~/.zshrc
            echo "# Powerlevel10k theme" >> ~/.zshrc
            echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc
            echo "Added Powerlevel10k to ~/.zshrc"
        fi
    else
        echo "❌ Powerlevel10k installation failed."
        exit 1
    fi
fi

# Install Nerd Fonts
echo "Setting up Nerd Fonts..."

# Tap the Homebrew Fonts Cask if not already tapped
if ! brew tap | grep -q "homebrew/cask-fonts"; then
    echo "Tapping homebrew/cask-fonts..."
    brew tap homebrew/cask-fonts
fi

# Install Meslo LG Nerd Font (recommended for Powerlevel10k)
if brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
    echo "✅ Meslo LG Nerd Font is already installed."
else
    echo "Installing Meslo LG Nerd Font..."
    brew install --cask font-meslo-lg-nerd-font
    if [ $? -eq 0 ]; then
        echo "✅ Meslo LG Nerd Font installation successful."
        echo "📝 Remember to configure your terminal to use 'MesloLGS NF' font."
    else
        echo "❌ Meslo LG Nerd Font installation failed."
        exit 1
    fi
fi

echo "✅ Fonts and Powerlevel10k setup complete"
