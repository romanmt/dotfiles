#!/bin/zsh

# Secrets tooling
#   - Keeper Commander: CLI for my personal password manager
#   - OpenBao (bao): CLI for the work secrets manager
#
# Neither is wired into chezmoi templates: no secret is ever rendered into a
# dotfile. Work settings for bao (BAO_ADDR, CA bundle) go in ~/.zshrc.local,
# which is not managed by this public repo.

echo "==== Setting up secrets tooling ===="

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

if ! check_command_installed "brew"; then
    echo "❌ Homebrew is required. Please install Homebrew first."
    exit 1
fi

# Keeper Commander (password manager CLI)
if ! check_command_installed "keeper"; then
    echo "Installing Keeper Commander..."
    if ! brew install keeper-commander; then
        echo "❌ Keeper Commander installation failed."
        exit 1
    fi
    echo "✅ Keeper Commander installed. Log in with: keeper shell"
fi

# OpenBao CLI (work secrets manager)
if ! check_command_installed "bao"; then
    echo "Installing OpenBao CLI..."
    if ! brew install openbao; then
        echo "❌ OpenBao installation failed."
        exit 1
    fi
    echo "✅ OpenBao installed. Set BAO_ADDR in ~/.zshrc.local before using it."
fi

echo "==== Secrets tooling setup complete! ===="
