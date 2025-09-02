# Detailed Setup Guide

This guide provides comprehensive information about the chezmoi-managed dotfiles setup with Oh My Zsh and automatic tool installation.

## How it works

The setup uses chezmoi's `run_once_` scripts that execute automatically when you run `chezmoi apply`. These scripts ensure all required tools and configurations are installed:

1. **`run_once_setup_homebrew.sh`** - Installs Homebrew package manager
2. **`run_once_setup_asdf.sh`** - Installs ASDF version manager with Ruby/Node.js
3. **`run_once_setup_iterm.sh`** - Installs iTerm2 terminal emulator
4. **`run_once_setup_emacs.sh`** - Installs Emacs and Doom Emacs configuration
5. **`run_once_setup_ohmyzsh.sh`** - Installs Oh My Zsh and custom plugins
6. **`install.sh`** - Legacy setup script for additional tools

## Usage

### First time setup on a new machine:

```bash
# Install chezmoi if not already installed
brew install chezmoi

# Initialize and apply your dotfiles
chezmoi init --apply romanmt

# That's it! All setup scripts will run automatically in order.
```

### After making changes to your dotfiles:

```bash
# Apply any changes
chezmoi apply

# If you need to re-run setup scripts, clear chezmoi's state:
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Preview changes before applying:

```bash
# See what would change without actually changing anything
chezmoi diff

# See what scripts would run
chezmoi apply --dry-run --verbose
```

## What was fixed

- ❌ **Removed**: Duplicate and conflicting scripts
- ❌ **Removed**: Broken script dependencies (missing `setup.sh`)
- ❌ **Removed**: The monolithic `install.sh` approach
- ✅ **Added**: Proper execution order with numbered prefixes
- ✅ **Added**: Self-contained scripts with inline utility functions
- ✅ **Added**: Better error handling and status messages
- ✅ **Added**: Proper dependency checking between scripts
- ✅ **Added**: Support for Apple Silicon Macs

## Script Features

Each script now:
- ✅ Checks for required dependencies (like Homebrew)
- ✅ Has proper error handling and exits on failure
- ✅ Shows clear status messages with emojis
- ✅ Skips installation if already installed
- ✅ Is self-contained (no external script dependencies)

## Troubleshooting

If you encounter issues:

1. **Check individual script logs**: Each script shows clear status messages
2. **Run specific script manually**: `./run_once_01_setup_homebrew.sh`
3. **Reset chezmoi state**: `chezmoi state delete-bucket --bucket=scriptState`
4. **Check chezmoi status**: `chezmoi status`

The setup is now much more reliable and easier to debug!

## Colorls Aliases

After setup, you'll have these enhanced directory listing commands:

- `ls` - Enhanced colorful directory listing (replaces standard ls)
- `lc` - Long listing with directories first, sorted
- `la` - Show all files including hidden ones
- `ll` - Long listing format
- `tree` - Tree view of directories

Colorls provides:
- 🎨 **Color-coded file types** (executables, images, documents, etc.)
- 📁 **Enhanced directory highlighting**
- 🔗 **Symlink visualization**
- ⚡ **Git status integration**
- 📊 **File size formatting**
