#!/bin/zsh

# Shared utility functions for dotfiles setup
# This script runs first (00) to establish common functions

# Function to check if a command is installed
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

# Function to check if a directory exists
function check_directory_exists() {
    local dir_path=$1
    if [ -d "$dir_path" ]; then
        echo "Directory $dir_path exists."
        return 0
    else
        echo "Directory $dir_path does not exist."
        return 1
    fi
}

# Function to add a line to a file if it doesn't exist
function add_line_to_file_if_not_exists() {
    local line="$1"
    local file="$2"
    
    if [ ! -f "$file" ]; then
        echo "Creating $file"
        touch "$file"
    fi
    
    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
        echo "Added '$line' to $file"
    else
        echo "'$line' already exists in $file"
    fi
}

echo "✅ Utility functions loaded"
