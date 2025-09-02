#!/bin/zsh

echo "🎯 Setting up Emacs and Doom Emacs..."

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

# Function to install Emacs
function install_emacs() {
    echo "Installing Emacs..."
    brew install emacs
    if [ $? -eq 0 ]; then
        echo "✅ Emacs installation successful."
    else
        echo "❌ Emacs installation failed."
        exit 1
    fi
}

# Function to install Emacs dependencies
function install_emacs_dependencies() {
    echo "Installing Emacs dependencies..."
    
    # Install Graphviz for org-roam graphs
    if ! check_command_installed "dot"; then
        echo "Installing Graphviz..."
        brew install graphviz
    else
        echo "✅ Graphviz already installed."
    fi
    
    # Install Aspell for spell checking
    if ! check_command_installed "aspell"; then
        echo "Installing Aspell..."
        brew install aspell
    else
        echo "✅ Aspell already installed."
    fi
    
    echo "✅ Emacs dependencies installed."
}

# Function to install Doom Emacs
function install_doom_emacs() {
    echo "Installing Doom Emacs..."
    if [ -d "$HOME/.emacs.d" ]; then
        echo "Removing existing Emacs configuration..."
        rm -rf "$HOME/.emacs.d"
    fi
    
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
    ~/.emacs.d/bin/doom install --yes
    
    if [ $? -eq 0 ]; then
        echo "✅ Doom Emacs installation successful."
    else
        echo "❌ Doom Emacs installation failed."
        exit 1
    fi
}

# Function to link Doom Emacs configuration
function link_doom_emacs_config() {
    echo "Setting up Doom Emacs configuration..."
    mkdir -p ~/.config/doom
    
    # Get the chezmoi source path
    SOURCE_PATH="$(chezmoi source-path 2>/dev/null || echo ".")"
    
    # Look for doom config files in various possible locations
    DOOM_CONFIG_DIRS=(
        "$SOURCE_PATH/dot_config/doom"
        "$SOURCE_PATH/emacs" 
        "./dot_config/doom"
        "./emacs"
    )
    
    FOUND_CONFIG=false
    for config_dir in "${DOOM_CONFIG_DIRS[@]}"; do
        if [ -d "$config_dir" ] && [ -n "$(find "$config_dir" -name '*.el' -print -quit)" ]; then
            echo "Found Doom config in $config_dir"
            for file in "$config_dir"/*.el; do
                if [ -f "$file" ]; then
                    filename=$(basename "$file")
                    echo "Linking $filename to ~/.config/doom/"
                    ln -sf "$(realpath "$file")" ~/.config/doom/
                fi
            done
            FOUND_CONFIG=true
            break
        fi
    done
    
    if [ "$FOUND_CONFIG" = true ]; then
        echo "✅ Doom Emacs configuration linked successfully."
        
        # Sync Doom configuration
        if [ -x "$HOME/.emacs.d/bin/doom" ]; then
            echo "Syncing Doom Emacs configuration..."
            ~/.emacs.d/bin/doom sync
        fi
    else
        echo "⚠️ No Doom Emacs configuration found. You may need to configure it manually."
        echo "Checked directories: ${DOOM_CONFIG_DIRS[*]}"
    fi
}

# Check if Emacs is installed
if check_command_installed "emacs"; then
    echo "✅ Emacs is already installed, skipping installation."
else
    install_emacs
fi

# Install Emacs dependencies
install_emacs_dependencies

# Check if Doom Emacs is installed
if [ -d "$HOME/.emacs.d" ] && [ -f "$HOME/.emacs.d/bin/doom" ]; then
    echo "✅ Doom Emacs is already installed, skipping installation."
else
    install_doom_emacs
fi

# Link Doom Emacs configuration
link_doom_emacs_config

echo "✅ Emacs and Doom Emacs setup complete"
