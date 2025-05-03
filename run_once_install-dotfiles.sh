#!/bin/zsh

# This script runs the install.sh script which sets up the entire environment
# It's designed to be self-contained and not rely on external sources

echo "==== Starting dotfiles installation with run_once_install-dotfiles.sh ===="

# Get the directory where this script is located
SCRIPT_DIR="$(chezmoi source-path)"
echo "Source directory: $SCRIPT_DIR"
cd "$SCRIPT_DIR"

# Make sure install.sh is executable
echo "Making install.sh executable..."
chmod +x "$SCRIPT_DIR/install.sh"

# Run the install script
echo "Running install.sh..."
"$SCRIPT_DIR/install.sh"

echo "==== Completed dotfiles installation ====" 