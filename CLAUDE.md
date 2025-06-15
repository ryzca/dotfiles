# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for macOS that provides automated setup and configuration for a development environment. It uses a modular installation system with backup capabilities.

## Installation Architecture

The repository uses a two-layer installation system:
1. **Makefile** - Entry point that calls initialization scripts
2. **Shell scripts in .bin/** - Modular scripts for each component

Each installation:
- Creates timestamped backups in `.bak/` before making changes
- Logs all operations to `.bak/{timestamp}/init.log`
- Uses color-coded output (info, warn, error)

## Commands

```bash
# Install everything (homebrew, zsh, git, vim, mise, ghostty, tmux)
make all

# Install individual components
make homebrew  # Install Homebrew and packages from Brewfile
make zsh       # Configure Zsh with Zinit, Powerlevel10k, and plugins (depends on misc)
make git       # Set up Git configuration
make vim       # Configure Vim
make mise      # Install and configure mise (development environment manager)
make ghostty   # Configure Ghostty terminal emulator
make tmux      # Configure tmux terminal multiplexer
make misc      # Miscellaneous configurations (bat, directories, XDG setup)

# Installation always creates backups and logs
# Backups are stored in: .bak/{timestamp}/{component}/
```

## Key Configuration Details

### Environment Variables (XDG Compliance)
The setup follows XDG Base Directory specification:
- `XDG_CONFIG_HOME`: ~/.config
- `XDG_DATA_HOME`: ~/.local/share
- `XDG_STATE_HOME`: ~/.local/state
- `XDG_CACHE_HOME`: ~/.cache

### Zsh Configuration
- **Plugin Manager**: Zinit
- **Theme**: Powerlevel10k
- **Plugins**: fast-syntax-highlighting, zsh-autosuggestions, zsh-completions
- **Config files**: Located in `configs/zsh/`
- **Custom aliases**: eza (with icons) for enhanced ls commands

### Directory Structure
The installation creates the following development directories:
- `~/dev/_arch`
- `~/dev/res/configs`
- `~/dev/res/docs`
- `~/dev/res/libs`
- `~/dev/res/scripts`

### Tool Integrations
- **mise**: For managing runtime versions (replaces asdf/nvm/rbenv)
- **fzf**: Fuzzy finder integration
- **bat**: Enhanced cat with syntax highlighting
- **eza**: Modern ls replacement with icons
- **Ghostty**: Fast GPU-accelerated terminal emulator
- **tmux**: Terminal multiplexer with custom configuration
- **iTerm2**: Configuration profiles included (JSON and plist)

## Development Notes

When modifying configurations:
1. Each tool's config stays in `configs/{tool}/`
2. Installation scripts must handle macOS-specific requirements
3. Always create backups before overwriting existing configs
4. The `common.sh` provides shared functions: `log()` and `backup()`
5. No test or lint infrastructure exists - manually verify changes work as expected