#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting dotfiles deployment...${NC}"

# Install required packages
echo -e "${GREEN}Installing required packages...${NC}"
sudo pacman -S --needed --noconfirm \
    git \
    zsh \
    stow

# Create necessary directories
echo -e "${GREEN}Creating necessary directories...${NC}"
mkdir -p ~/.local/share
mkdir -p ~/.config

# Copy the .dotfiles directory to the new system
echo -e "${GREEN}Copying dotfiles repository...${NC}"
cp -r .dotfiles $HOME/

# Define the alias in the current shell
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Add the alias to .bashrc for persistence
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc

# Configure git to not show untracked files
dotfiles config --local status.showUntrackedFiles no

# Checkout the actual content from the bare repository to your $HOME
echo -e "${GREEN}Checking out dotfiles...${NC}"
dotfiles checkout

# If there are conflicts, backup the existing files
if [ $? = 0 ]; then
    echo -e "${GREEN}Checked out dotfiles successfully.${NC}"
else
    echo -e "${RED}Backing up pre-existing dot files...${NC}"
    mkdir -p .dotfiles-backup
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
    dotfiles checkout
fi

# Set up zsh as default shell
echo -e "${GREEN}Setting up zsh as default shell...${NC}"
chsh -s $(which zsh)

echo -e "${GREEN}Deployment completed!${NC}"
echo -e "${GREEN}Please restart your shell or run 'source ~/.bashrc' to use the dotfiles command.${NC}" 