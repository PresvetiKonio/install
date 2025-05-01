#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print with color
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    print_error "This script is intended for Arch Linux only!"
    exit 1
fi

# Create backup directory
backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
print_status "Creating backup directory at $backup_dir"
mkdir -p "$backup_dir"

# Function to backup and create symlink
deploy_dotfile() {
    source="$1"
    target="$2"
    
    # Create target directory if it doesn't exist
    target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    
    # Backup existing file/directory if it exists
    if [ -e "$target" ]; then
        print_warning "Backing up existing $target to $backup_dir/"
        cp -r "$target" "$backup_dir/"
        rm -rf "$target"
    fi
    
    # Create symlink
    print_status "Creating symlink for $target"
    ln -sf "$source" "$target"
}

# Install required packages
print_status "Installing required packages..."
sudo pacman -S --needed zsh git base-devel

# Deploy dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.dotfiles"

# Deploy .zshenv
deploy_dotfile "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"

# Deploy .config directory
deploy_dotfile "$DOTFILES_DIR/.config" "$HOME/.config"

# Deploy .local directory
deploy_dotfile "$DOTFILES_DIR/.local" "$HOME/.local"

# Deploy games directory
deploy_dotfile "$DOTFILES_DIR/games" "$HOME/games"

# Set zsh as default shell if it isn't already
if [[ $SHELL != "/bin/zsh" ]]; then
    print_status "Setting zsh as default shell..."
    chsh -s /bin/zsh
fi

print_status "Dotfiles deployment complete!"
print_status "Please log out and log back in for all changes to take effect." 