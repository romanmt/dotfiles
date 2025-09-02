# 🏠 Personal Dotfiles

A comprehensive development environment setup using [chezmoi](https://chezmoi.io/) to manage dotfiles and automate system configuration.

## ✨ What's Included

### 🐚 Shell Configuration
- **[Oh My Zsh](https://ohmyz.sh/)** with 14 carefully selected plugins
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** theme for a beautiful and informative prompt
- **Enhanced plugins** for productivity and development workflow

### 🛠 Development Tools
- **[ASDF](https://asdf-vm.com/)** version manager (Ruby 3.3.3, Node.js 22.3.0)
- **[Doom Emacs](https://github.com/doomemacs/doomemacs)** configuration
- **Git integration** with enhanced Git workflows
- **[colorls](https://github.com/athityakumar/colorls)** for beautiful directory listings

### 🖥 Applications & Tools
- **iTerm2** terminal emulator
- **Homebrew** package manager
- **Graphviz** and **Aspell** for documentation and spell checking
- **Docker CLI** completions (when Docker Desktop is installed)
- **VS Code** integration

## 🚀 Quick Start

### First-time setup on a new machine:

```bash
# Install chezmoi
brew install chezmoi

# Initialize and apply dotfiles (replace 'mattroman' with your GitHub username)
chezmoi init --apply mattroman

# Restart your terminal or source your new shell configuration
source ~/.zshrc
```

That's it! The setup scripts will automatically:
- Install Oh My Zsh and custom plugins
- Set up ASDF with Ruby and Node.js
- Install development tools and applications
- Configure your shell with all the plugins and aliases

## 🔧 Oh My Zsh Plugin Configuration

Your shell comes pre-configured with these plugins:

### Core Development
- **`git`** - Git aliases and functions
- **`gitfast`** - Enhanced Git tab completion
- **`gh`** - GitHub CLI integration
- **`asdf`** - Version manager support

### Language Support  
- **`python`** - Python development utilities
- **`pip`** - Python package manager enhancements
- **`mix`** - Elixir build tool support
- **`ruby`** - Ruby development utilities

### Productivity Boosters
- **`fzf`** - Fuzzy finder integration
- **`z`** - Smart directory jumping
- **`copypath`** - Copy current path to clipboard
- **`copyfile`** - Copy file contents to clipboard  
- **`extract`** - Extract any archive format
- **`web-search`** - Search from terminal

### System Integration
- **`macos`** - macOS-specific enhancements
- **`brew`** - Homebrew integration
- **`vscode`** - VS Code integration

### Enhanced Shell Experience
- **`zsh-autosuggestions`** - Fish-like autosuggestions
- **`zsh-syntax-highlighting`** - Real-time syntax highlighting

## 📁 Enhanced Directory Listings

The setup includes `colorls` with these aliases:
- **`ls`** - Colorful directory listing (replaces standard ls)
- **`lc`** - Long format with directories first
- **`la`** - Show all files including hidden ones  
- **`ll`** - Detailed long listing
- **`tree`** - Tree view of directory structure

## 🔄 Managing Your Dotfiles

### Apply changes
```bash
# Preview what would change
chezmoi diff

# Apply all changes
chezmoi apply
```

### Update configuration
```bash
# Edit a file and automatically update chezmoi
chezmoi edit ~/.zshrc

# Add a new file to chezmoi management
chezmoi add ~/.newconfig
```

### Sync across machines
```bash
# Push changes to your dotfiles repository
chezmoi git add .
chezmoi git commit -m "Update configuration"
chezmoi git push

# Pull changes on another machine
chezmoi update
```

## 📋 Requirements

- **macOS** (tested on Apple Silicon and Intel Macs)
- **Homebrew** (automatically installed if missing)
- **Git** (for cloning repositories)
- **Internet connection** (for downloading tools and themes)

## 🗂 Project Structure

```
~/.local/share/chezmoi/
├── README.md                           # This file
├── docs/                               # Documentation
│   ├── README_SETUP.md                 # Detailed setup guide
│   └── ZSHRC_FIXES.md                  # Shell configuration fixes
├── dot_zshrc                           # Oh My Zsh configuration
├── dot_p10k.zsh                       # Powerlevel10k theme config
├── dot_tool-versions                   # ASDF version specifications
├── dot_config/                         # Application configurations
│   └── doom/                           # Doom Emacs config
├── run_once_setup_ohmyzsh.sh          # Oh My Zsh & plugins installer
├── run_once_setup_asdf.sh             # ASDF version manager setup
├── run_once_setup_emacs.sh            # Emacs and Doom setup
├── run_once_setup_homebrew.sh         # Homebrew installer
├── run_once_setup_iterm.sh            # iTerm2 setup
└── install.sh                         # Legacy setup script
```

## 🛠 Troubleshooting

### Shell plugins not working
```bash
# Reload shell configuration
source ~/.zshrc

# Or restart your terminal
```

### Missing Oh My Zsh plugins
```bash
# Re-run the Oh My Zsh setup
~/.local/share/chezmoi/run_once_setup_ohmyzsh.sh
```

### Reset chezmoi state
```bash
# Clear script execution state and re-run setup scripts
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Check setup status
```bash
# See what chezmoi would change
chezmoi status

# See current plugin status
echo $plugins
```

## 📚 Additional Documentation

- **[Setup Guide](docs/README_SETUP.md)** - Detailed installation and configuration guide
- **[Shell Fixes](docs/ZSHRC_FIXES.md)** - Documentation of shell configuration fixes

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. The modular script approach makes it easy to add or remove components.

---

**Happy coding!** 🎉
