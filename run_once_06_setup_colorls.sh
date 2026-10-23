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

# The colorls aliases and tab completion live in dot_zshrc, and the color
# schemes in dot_config/colorls/. This script only installs the gem.

echo "✅ colorls setup complete"
echo ""
echo "🎨 Available colorls aliases:"
echo "  ls  - colorls with dark theme"
echo "  lc  - long listing with directories first"
echo "  la  - show all files including hidden"
echo "  ll  - long listing format"
echo "  tree - tree view"
echo ""
echo "📝 Note: Restart your shell or run 'source ~/.zshrc' to use the new aliases"
