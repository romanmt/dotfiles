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

# Install asdf. Shell integration (shims on PATH) comes from the Oh My Zsh
# asdf plugin in dot_zshrc, so this script never edits ~/.zshrc.
if check_command_installed "asdf"; then
    echo "✅ asdf is already installed, skipping installation."
else
    echo "Installing asdf..."
    if ! brew install asdf; then
        echo "❌ asdf installation failed."
        exit 1
    fi
    echo "✅ asdf installation successful."
fi

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Plugin source URLs for tools that are not in the default asdf plugin index
typeset -A PLUGIN_URLS
PLUGIN_URLS[java]="https://github.com/halcyon/asdf-java.git"
PLUGIN_URLS[erlang]="https://github.com/asdf-vm/asdf-erlang.git"
PLUGIN_URLS[elixir]="https://github.com/asdf-vm/asdf-elixir.git"

# ~/.tool-versions (managed by chezmoi as dot_tool-versions) is the single
# source of truth for versions. Add a plugin for every tool it lists, then
# install the pinned versions.
TOOL_VERSIONS="$HOME/.tool-versions"
if [ ! -f "$TOOL_VERSIONS" ]; then
    echo "❌ $TOOL_VERSIONS not found. Run 'chezmoi apply' so it is created first."
    exit 1
fi

for tool in $(awk '!/^#/ && NF {print $1}' "$TOOL_VERSIONS"); do
    if asdf plugin list 2>/dev/null | grep -qx "$tool"; then
        echo "✅ asdf plugin $tool already added."
    else
        echo "Adding asdf plugin $tool..."
        asdf plugin add "$tool" ${PLUGIN_URLS[$tool]}
    fi
done

echo "Installing versions pinned in $TOOL_VERSIONS..."
(cd "$HOME" && asdf install)

echo "✅ ASDF setup complete"
