#!/bin/zsh

echo "🌈 Setting up colorls..."

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

# Ensure Ruby is available via ASDF
if ! check_command_installed "ruby"; then
    echo "❌ Ruby is required but not found. Please ensure Ruby is installed via ASDF first."
    exit 1
fi

# Check if gem command is available
if ! check_command_installed "gem"; then
    echo "❌ gem command not found. Ruby installation may be incomplete."
    exit 1
fi

# Function to install colorls gem
function install_colorls() {
    echo "Installing colorls gem..."
    
    # Install colorls gem
    gem install colorls
    
    if [ $? -eq 0 ]; then
        echo "✅ colorls gem installation successful."
    else
        echo "❌ colorls gem installation failed."
        exit 1
    fi
}

# Check if colorls is already installed
if gem list colorls | grep -q "colorls"; then
    echo "✅ colorls gem is already installed."
else
    install_colorls
fi

# Add colorls configuration to .zshrc if not already present
echo "Adding colorls configuration to .zshrc..."

ZSHRC_FILE="$HOME/.zshrc"

# Create backup of .zshrc
cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Add colorls configuration section if not present
if ! grep -q "# colorls configuration" "$ZSHRC_FILE"; then
    cat >> "$ZSHRC_FILE" << 'EOF'

# colorls configuration
if command -v colorls &> /dev/null; then
    # Load colorls tab completion if available
    if gem which colorls &> /dev/null; then
        COLORLS_TAB_COMPLETE="$(dirname $(gem which colorls))/tab_complete.sh"
        if [ -f "$COLORLS_TAB_COMPLETE" ]; then
            source "$COLORLS_TAB_COMPLETE"
        fi
    fi
    
    # colorls aliases
    alias ls='colorls --light'
    alias lc='colorls -lA --sd --light'
    alias la='colorls -la --light'
    alias ll='colorls -l --light'
    alias tree='colorls --tree --light'
fi
EOF
    
    echo "✅ Added colorls configuration to .zshrc"
else
    echo "✅ colorls configuration already exists in .zshrc"
fi

# Update chezmoi source to include the modified .zshrc
if command -v chezmoi &> /dev/null; then
    echo "Updating chezmoi source with modified .zshrc..."
    chezmoi add ~/.zshrc
    echo "✅ Updated chezmoi source"
fi

echo "✅ colorls setup complete"
echo ""
echo "🎨 Available colorls aliases:"
echo "  ls  - colorls with light theme"
echo "  lc  - long listing with directories first"
echo "  la  - show all files including hidden"
echo "  ll  - long listing format"
echo "  tree - tree view"
echo ""
echo "📝 Note: Restart your shell or run 'source ~/.zshrc' to use the new aliases"
