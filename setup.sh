#!/usr/bin/env zsh

# Install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install git
brew install git

# Clone this repository
git clone --depth 1 git@github.com:m3m0r7/dotfiles.git ~/dotfiles

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
ln -nsf ~/dotfiles/.memory_chan ~/.memory_chan
ln -nsf ~/dotfiles/.zshrc ~/.zshrc
ln -nsf ~/dotfiles/.vimrc ~/.vimrc
ln -nsf ~/dotfiles/.gitignore_global ~/.gitignore_global
ln -nsf ~/dotfiles/.fdignore ~/.fdignore
ln -nsf ~/dotfiles/.original-scripts ~/.original-scripts
ln -nsf ~/dotfiles/webpack.config.js ~/webpack.config.js

# Install theme
ln -nsf ~/dotfiles/.oh-my-zsh/themes/memory.zsh-theme /Users/memory/.oh-my-zsh/themes/memory.zsh-theme

# Source
source ~/.zshrc
