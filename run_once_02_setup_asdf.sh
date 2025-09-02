#!/bin/zsh

echo "🔧 Setting up ASDF version manager..."

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

# Function to install asdf
function install_asdf() {
    echo "Installing asdf..."
    brew install asdf
    if [ $? -eq 0 ]; then
        echo "✅ asdf installation successful."
        
        # Add asdf to shell configuration
        ASDF_SH="$(brew --prefix asdf)/libexec/asdf.sh"
        if [ -f "$ASDF_SH" ]; then
            if ! grep -q "asdf.sh" ~/.zshrc; then
                echo "" >> ~/.zshrc
                echo "# ASDF version manager" >> ~/.zshrc
                echo ". \"$ASDF_SH\"" >> ~/.zshrc
                echo "Added asdf to ~/.zshrc"
            fi
            # Load asdf for this session
            . "$ASDF_SH"
        fi
    else
        echo "❌ asdf installation failed."
        exit 1
    fi
}

# Function to setup asdf plugins and versions
function setup_asdf_plugins() {
    echo "Setting up asdf plugins and versions..."
    
    # Ensure asdf is loaded
    if ! check_command_installed "asdf"; then
        ASDF_SH="$(brew --prefix asdf)/libexec/asdf.sh"
        if [ -f "$ASDF_SH" ]; then
            . "$ASDF_SH"
        else
            echo "❌ Could not load asdf"
            exit 1
        fi
    fi

    # Add Ruby plugin and install version
    echo "Setting up Ruby..."
    if ! asdf plugin list 2>/dev/null | grep -q "ruby"; then
        echo "Adding Ruby plugin..."
        asdf plugin add ruby
    fi
    
    if ! asdf list ruby 2>/dev/null | grep -q "3.3.3"; then
        echo "Installing Ruby 3.3.3..."
        asdf install ruby 3.3.3
    fi
    
    # Add Node.js plugin and install version  
    echo "Setting up Node.js..."
    if ! asdf plugin list 2>/dev/null | grep -q "nodejs"; then
        echo "Adding Node.js plugin..."
        asdf plugin add nodejs
    fi
    
    if ! asdf list nodejs 2>/dev/null | grep -q "22.3.0"; then
        echo "Installing Node.js 22.3.0..."
        asdf install nodejs 22.3.0
    fi

    # Set global versions in .tool-versions file
    echo "Setting global versions..."
    cat > ~/.tool-versions << EOF
ruby 3.3.3
nodejs 22.3.0
EOF
    
    # Also set asdf global versions
    asdf global ruby 3.3.3 2>/dev/null || true
    asdf global nodejs 22.3.0 2>/dev/null || true
    
    echo "✅ asdf plugins and versions setup complete."
}

# Check if asdf is installed
if check_command_installed "asdf"; then
    echo "✅ asdf is already installed, skipping installation."
else
    install_asdf
fi

# Set up asdf plugins and versions
setup_asdf_plugins

echo "✅ ASDF setup complete"
