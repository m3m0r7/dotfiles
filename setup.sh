#!/usr/bin/env zsh

# Install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install git
brew install git

# Clone this repository
git clone --depth 1 git@github.com:m3m0r7/dotfiles.git $HOME/dotfiles

# Move to current directory
cd $HOME/dotfiles

# Update brew
brew tap homebrew/cask
brew tap homebrew/cask-fonts

# Install brew packages
cat .brew_installed | brew install
cat .brew_cask_installed | brew cask install

# Remove already installed files
if [ -f $HOME/.zshrc ]; then
  rm $HOME/.zshrc
fi

if [ -f $HOME/.vimrc ]; then
  rm $HOME/.vimrc
fi

# Create symbolic links
ln -nsf $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -nsf $HOME/dotfiles/.vimrc $HOME/.vimrc
ln -nsf $HOME/dotfiles/.gitignore_global $HOME/.gitignore_global
ln -nsf $HOME/dotfiles/.fdignore $HOME/.fdignore
ln -nsf $HOME/dotfiles/.original-scripts $HOME/.original-scripts
ln -nsf $HOME/dotfiles/webpack.config.js $HOME/webpack.config.js
ln -nsf $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -nsf $HOME/dotfiles/scripts $HOME/scripts

git clone https://github.com/seebi/dircolors-solarized.git $HOME/.oh-my-zsh/plugins/dircolors-solarized
$(brew --prefix)/opt/fzf/install

git clone https://github.com/chitoku-k/fzf-zsh-completions $HOME/.oh-my-zsh/plugins/fzf-zsh-completions
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

git clone git@github.com:b4b4r07/enhancd.git $HOME/.oh-my-zsh/plugins/enhancd
git clone git@github.com:chitoku-k/fzf-zsh-completions.git $HOME/.oh-my-zsh/plugins/fzf-zsh-completions

# Source
source $HOME/.zshrc

defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 5
