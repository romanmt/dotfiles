#!/bin/zsh

# Secrets Management Setup Script
# This script sets up encrypted secrets support using Keeper Security Manager

echo "==== Setting up Secrets Management ===="

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

# Ensure Homebrew is available first
if ! check_command_installed "brew"; then
    echo "❌ Homebrew is required for installing Keeper CLI. Please install Homebrew first."
    exit 1
fi

# Install Keeper CLI if not already installed
if check_command_installed "keeper"; then
    echo "✅ Keeper CLI is already installed."
    keeper --version 2>/dev/null || echo "  (Version info not available)"
else
    echo "Installing Keeper CLI..."
    
    # Install via Homebrew using the correct formula name
    echo "Installing Keeper CLI via Homebrew..."
    brew install keeper-commander
    
    # Verify installation worked
    if check_command_installed "keeper"; then
        echo "✅ Keeper CLI installed via Homebrew."
    else
        echo "❌ Homebrew installation failed, trying pip fallback..."
        # Fallback: Install via pip (Keeper's Python package)
        if check_command_installed "pip"; then
            pip install keepercommander
            echo "✅ Keeper CLI installed via pip."
        elif check_command_installed "pip3"; then
            pip3 install keepercommander
            echo "✅ Keeper CLI installed via pip3."
        else
            echo "❌ Could not install Keeper CLI. Please install manually:"
            echo "   Option 1: pip install keepercommander"
            echo "   Option 2: Download from https://keeper.io/commander"
            exit 1
        fi
    fi
fi

# Verify Keeper CLI installation
if check_command_installed "keeper"; then
    echo "✅ Keeper CLI installation verified."
    echo ""
    echo "Next steps for using Keeper with chezmoi:"
    echo "1. Login to Keeper: keeper shell"
    echo "2. Configure chezmoi to use Keeper in ~/.config/chezmoi/chezmoi.toml:"
    echo ""
    echo "[keeper]"
    echo "    command = \"keeper\""
    echo "    args = [\"get\", \"--format=password\", \"{{ .keeper.record }}\"]"
    echo ""
    echo "3. Use in templates like: {{ (keeper \"my-api-key-record\").password }}"
    echo ""
else
    echo "❌ Keeper CLI installation failed."
    exit 1
fi

echo "==== Secrets Management setup complete! ====" 
