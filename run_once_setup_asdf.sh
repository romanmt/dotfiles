#!/bin/zsh

# Function to install asdf
function install_asdf {
    echo "Installing asdf..."
    brew install asdf
    if [ $? -eq 0 ]; then
        echo "asdf installation successful."
    else
        echo "asdf installation failed."
        exit 1
    fi
}

. ./setup.sh
# Check if asdf is installed
if check_command_installed "asdf"; then
    echo "Skipping asdf installation."
else
    install_asdf
fi

#!/bin/zsh

function setup_asdf_plugins {
    echo "Setting up asdf plugins..."

    # Add Ruby plugin and install version
    if ! asdf plugin-list | grep -q "ruby"; then
        asdf plugin-add ruby
    fi
    asdf install ruby 3.3.3
    asdf global ruby 3.3.3

    # Add Node.js plugin and install version
    if ! asdf plugin-list | grep -q "nodejs"; then
        asdf plugin-add nodejs
    fi
    asdf install nodejs 22.3.0
    asdf global nodejs 22.3.0

    echo "ruby 3.3.3" > ~/.tool-versions
    echo "nodejs 22.3.0" >> ~/.tool-versions

    echo "asdf plugins setup complete."
}

# Set up asdf plugins and versions
setup_asdf_plugins
