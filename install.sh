#!/bin/zsh

# Function to check if a command is installed
function check_command_installed {
    local command_name=$1
    if command -v $command_name &> /dev/null; then
        echo "$command_name is already installed."
        return 0
    else
        echo "$command_name is not installed."
        return 1
    fi
}

# Install Homebrew if needed
if check_command_installed "brew"; then
    echo "Homebrew is already installed."
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install iTerm2 if needed
if [ -d "/Applications/iTerm.app" ]; then
    echo "iTerm2 is already installed."
else
    echo "Installing iTerm2..."
    brew install --cask iterm2
fi

# Install Emacs if needed
if check_command_installed "emacs"; then
    echo "Emacs is already installed."
else
    echo "Installing Emacs..."
    brew install emacs
fi

# Install Graphviz
echo "Installing Graphviz..."
brew install graphviz

# Install Aspell
echo "Installing Aspell..."
brew install aspell

# Install ASDF if needed
if check_command_installed "asdf"; then
    echo "ASDF is already installed."
else
    echo "Installing ASDF..."
    brew install asdf
    
    # Add to shell config if needed
    if ! grep -q "asdf.sh" ~/.zshrc; then
        echo -e "\n# ASDF version manager" >> ~/.zshrc
        echo '. "$(brew --prefix asdf)/libexec/asdf.sh"' >> ~/.zshrc
    fi
    
    # Source ASDF now so we can use it in this script
    . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Set up ASDF plugins
echo "Setting up ASDF plugins..."

# Make sure ASDF is loaded
if ! command -v asdf &> /dev/null; then
    echo "Loading ASDF..."
    . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Add Ruby plugin and install version
if ! asdf plugin list 2>/dev/null | grep -q "ruby"; then
    echo "Adding Ruby plugin..."
    asdf plugin add ruby
fi
echo "Installing Ruby 3.3.3..."
asdf install ruby 3.3.3 || true

# Add Node.js plugin and install version
if ! asdf plugin list 2>/dev/null | grep -q "nodejs"; then
    echo "Adding NodeJS plugin..."
    asdf plugin add nodejs
fi
echo "Installing NodeJS 22.3.0..."
asdf install nodejs 22.3.0 || true

# Set global versions
echo "Setting global versions..."
echo "ruby 3.3.3" > ~/.tool-versions
echo "nodejs 22.3.0" >> ~/.tool-versions

# Install Doom Emacs if needed
if [ -d "$HOME/.emacs.d" ]; then
    echo "Doom Emacs is already installed."
else
    echo "Installing Doom Emacs..."
    git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
    ~/.emacs.d/bin/doom install --yes
fi

# Link Doom Emacs configuration
echo "Linking Doom Emacs configuration..."
mkdir -p ~/.config/doom

# Use chezmoi to get the dot_config directory
if check_command_installed "chezmoi"; then
    DOOM_CONFIG_DIR=$(chezmoi source-path)/dot_config/doom
    if [ -d "$DOOM_CONFIG_DIR" ]; then
        echo "Found Doom config directory at $DOOM_CONFIG_DIR"
        for file in "$DOOM_CONFIG_DIR"/*.el; do
            if [ -f "$file" ]; then
                FILENAME=$(basename "$file")
                echo "Linking $FILENAME to ~/.config/doom/"
                ln -sf "$file" ~/.config/doom/
            fi
        done
        echo "Doom Emacs configuration linked successfully."
    else
        echo "Could not find Doom Emacs config directory at $DOOM_CONFIG_DIR"
        echo "Checking current directory..."
        if [ -d "./dot_config/doom" ]; then
            echo "Found Doom config in ./dot_config/doom"
            for file in ./dot_config/doom/*.el; do
                if [ -f "$file" ]; then
                    FILENAME=$(basename "$file")
                    echo "Linking $FILENAME to ~/.config/doom/"
                    ln -sf "$(realpath "$file")" ~/.config/doom/
                fi
            done
            echo "Doom Emacs configuration linked successfully."
        else
            echo "Could not find Doom Emacs config in ./dot_config/doom either"
            ls -la
        fi
    fi
else
    echo "Chezmoi not found, trying with relative paths..."
    if [ -d "./dot_config/doom" ]; then
        echo "Found Doom config in ./dot_config/doom"
        for file in ./dot_config/doom/*.el; do
            if [ -f "$file" ]; then
                FILENAME=$(basename "$file")
                echo "Linking $FILENAME to ~/.config/doom/"
                ln -sf "$(realpath "$file")" ~/.config/doom/
            fi
        done
        echo "Doom Emacs configuration linked successfully."
    else
        echo "Could not find Doom Emacs config in ./dot_config/doom"
        ls -la
    fi
fi

echo "Setup complete!" 