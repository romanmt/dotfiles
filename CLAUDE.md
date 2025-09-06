# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository using chezmoi to manage system configuration and development environment setup. The repository includes Agent OS integration with specialized agents for different project types, particularly Elixir/Phoenix development.

## Key Commands

### Dotfiles Management
- `chezmoi diff` - Preview what would change before applying
- `chezmoi apply` - Apply all dotfile changes and run setup scripts
- `chezmoi edit ~/.zshrc` - Edit a managed file and update chezmoi
- `chezmoi add ~/.newconfig` - Add a new file to chezmoi management
- `chezmoi status` - Check current status and pending changes

### Reset and Troubleshooting
- `chezmoi state delete-bucket --bucket=scriptState` - Reset script execution state to re-run setup scripts
- `chezmoi apply --dry-run --verbose` - Preview what scripts would run

### Git Operations (via chezmoi)
- `chezmoi git add .` - Stage changes in the dotfiles repo
- `chezmoi git commit -m "message"` - Commit changes
- `chezmoi git push` - Push to remote
- `chezmoi update` - Pull and apply changes from remote

## Architecture and Structure

### Setup Script System
The repository uses chezmoi's `run_once_*` script pattern for automated system setup:

- **Numbered execution order**: `run_once_00_*`, `run_once_01_*`, etc. ensure proper dependency order
- **Self-contained scripts**: Each script includes all necessary utility functions
- **Idempotent**: Scripts check if tools are already installed before attempting installation
- **Error handling**: Scripts exit on failure with clear status messages

Key setup scripts:
- `run_once_00_setup_utils.sh` - Basic utilities
- `run_once_01_setup_homebrew.sh` - Homebrew package manager
- `run_once_02_setup_asdf.sh` - ASDF version manager with Ruby 3.3.3 and Node.js 22.3.0
- `run_once_03_setup_iterm.sh` - iTerm2 terminal emulator
- `run_once_06_setup_colorls.sh` - Enhanced directory listings
- `run_once_07_setup_fonts.sh` - Font installation
- `run_once_setup_ohmyzsh.sh` - Oh My Zsh with 14 plugins
- `run_once_setup_secrets.sh` - Secret management setup

### Agent OS Integration
The repository includes Agent OS configuration (`dot_agent-os/config.yml`) with:

- **Specialized agents**: OTP architect, DevOps engineer, DevSecOps engineer, testing specialist, UX designer
- **Auto-assignment**: Keywords automatically trigger appropriate specialized agents
- **Project type detection**: Elixir/Phoenix projects get enhanced agent support
- **Fallback**: General-purpose agent for unmatched tasks

### Shell Configuration
- **Oh My Zsh** with Powerlevel10k theme
- **14 curated plugins**: git, gitfast, gh, asdf, python, pip, mix, ruby, fzf, z, copypath, copyfile, extract, web-search
- **Enhanced plugins**: zsh-autosuggestions, zsh-syntax-highlighting
- **macOS integration**: macos, brew, vscode plugins
- **Colorls aliases**: `ls`, `lc`, `la`, `ll`, `tree` with enhanced directory listings

## File Patterns and Structure

### Chezmoi Conventions
- `dot_*` files become `.*` in home directory (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_dot_*` files are encrypted/private (e.g., SSH configs)
- `run_once_*` scripts execute once during `chezmoi apply`

### Agent OS Structure
- `dot_agent-os/config.yml` - Main Agent OS configuration
- `dot_agent-os/standards/` - Development standards and best practices
- `dot_agent-os/project-types/` - Project-specific configurations
- `dot_agent-os/claude-code/agents/` - Specialized agent definitions

### Documentation
- `docs/README_SETUP.md` - Detailed setup and troubleshooting guide
- `docs/ZSHRC_FIXES.md` - Shell configuration fixes
- `docs/SECRETS_MANAGEMENT.md` - Secret handling documentation

## Development Environment

### Tool Versions (managed by ASDF)
- Ruby 3.3.3
- Node.js 22.3.0
- Additional tools as specified in `dot_tool-versions`

### Package Management
- **Primary**: Homebrew for system packages
- **Languages**: ASDF for language version management
- **Shell enhancement**: Oh My Zsh plugin ecosystem

## Important Notes

- This repository manages the development environment, not application code
- Changes to setup scripts require `chezmoi state delete-bucket --bucket=scriptState` to re-execute
- The Agent OS integration provides specialized assistance for Elixir/Phoenix development
- All setup scripts are designed for macOS (both Intel and Apple Silicon)