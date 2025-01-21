#!/bin/zsh

# Function to install Emacs
function install_emacs {
    echo "Installing Emacs..."
    brew tap jimeh/emacs-builds
    brew install --cask emacs-app-good
    if [ $? -eq 0 ]; then
        echo "Emacs installation successful."
    else
        echo "Emacs installation failed."
        exit 1
    fi
}

# Function to install Doom Emacs
function install_doom_emacs {
    echo "Installing Doom Emacs..."
    git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
    ~/.emacs.d/bin/doom install
    if [ $? -eq 0 ]; then
        echo "Doom Emacs installation successful."
    else
        echo "Doom Emacs installation failed."
        exit 1
    fi
}

# Function to install Graphviz
function install_graphviz {
    echo "Installing Graphviz..."
    brew install graphviz
    if [ $? -eq 0 ]; then
        echo "Graphviz installation successful."
    else
        echo "Graphviz installation failed."
        exit 1
    fi
}

# Function to install Aspell
function install_aspell {
    echo "Installing Aspell..."
    brew install aspell
    #brew install aspell-en
    if [ $? -eq 0 ]; then
        echo "Aspell installation successful."
    else
        echo "Aspell installation failed."
        exit 1
    fi
}

# Function to create symlinks for Doom Emacs configuration
function link_doom_emacs_config {
    echo "Linking Doom Emacs configuration..."
    mkdir -p ~/.config/doom
    for file in ./emacs/*.el; do
        ln -sf $(realpath "$file") ~/.config/doom/
    done

    if [ $? -eq 0 ]; then
        echo "Doom Emacs configuration linked successfully."
    else
        echo "Failed to link Doom Emacs configuration."
        exit 1
    fi
}

. ./setup.sh
# Check if Emacs is installed
if check_command_installed "emacs"; then
    echo "Skipping Emacs installation."
else
    install_emacs
fi

# Install Graphviz
install_graphviz

# Install Aspell
install_aspell

# Check if Doom Emacs is installed
if [ -d "$HOME/.config/doom" ]; then
    echo "Doom Emacs is already installed."
else
    install_doom_emacs
fi

# link Doom Emacs configuration
#link_doom_emacs_config
