#!/usr/bin/env zsh

# Install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install git
brew install git

# Clone this repository
git clone --depth 1 git@github.com:memory-agape/dotfiles.git ~/dotfiles

# Move to current directory
cd ~/dotfiles

# Install brew packages
cat .brew_installed | brew install

# Remove already installed files
if [ -f ~/.zshrc ]; then
  rm ~/.zshrc
fi

if [ -f ~/.vimrc ]; then
  rm ~/.vimrc
fi

# Create symbolic links
ln ~s .memory_chan ~/.memory_chan
ln -s .zshrc ~/.zshrc
ln -s .vimrc ~/.vimrc
ln -s .gitignore_global ~/.gitignore_global
ln -s .fdignore ~/.fdignore
ln -s .original-scripts ~/.original-scripts
ln -s webpack.config.js ~/webpack.config.js

# Install theme
ln -s .oh-my-zsh/themes/memory.zsh-theme ~/.oh-my-zsh/themes/memory.zsh-theme

# Source
source ~/.zshrc
