#!/usr/bin/env zsh

# Definition of download versions
FONT_VERSION_0xProto="1.602"
DOWNLOAD_NAME_0xProto="0xProto_1_602"

FONT_VERSION_HackGen="v2.9.0"
DOWNLOAD_NAME_HackGen="HackGen_NF_v2.9.0"

FONT_VERSION_SourceHanCodeJP="2.012R"
DOWNLOAD_NAME_SourceHanCodeJP="SourceHanCodeJP.ttc"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install git
brew install git

# Clone this repository
git clone --recurse-submodules git@github.com:m3m0r7/dotfiles.git /Volumes/develop/dotfiles

# Move to current directory
cd /Volumes/develop/dotfiles

# Update brew
brew tap homebrew/cask
brew tap homebrew/cask-fonts

# Install brew packages
brew bundle

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Create symbolic links
ln -nsf $HOME/dotfiles/.procs.toml $HOME/.procs.toml
ln -nsf $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -nsf $HOME/dotfiles/.vimrc $HOME/.config/nvim/init.vim
mkdir -p $HOME/.config/git/ignore && ln -nsf $HOME/dotfiles/.gitignore_global $HOME/.config/git/ignore
ln -nsf $HOME/dotfiles/.fdignore $HOME/.fdignore
ln -nsf $HOME/dotfiles/.original-scripts $HOME/.original-scripts
ln -nsf $HOME/dotfiles/webpack.config.js $HOME/webpack.config.js
ln -nsf $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -nsf $HOME/dotfiles/scripts $HOME/scripts
ln -nsf $HOME/dotfiles/.alacritty.toml $HOME/.alacritty.toml
ln -nsf $HOME/dotfiles/.zshenv $HOME/.zshenv

# Install claude settings
mkdir -p $HOME/.claude
ln -nsf $HOME/dotfiles/.claude/CLAUDE.md $HOME/.claude/CLAUDE.md
ln -nsf $HOME/dotfiles/.claude/agents $HOME/.claude/agents
cp ./mcp/.env.example ./mcp/.env || true
npm --prefix ./mcp install
npm install -g @anthropic-ai/claude-code@latest

claude mcp add default-memory-mcp tsx $HOME/dotfiles/mcp/src/index.ts

# Install codex
npm install -g @openai/codex@latest

# Make sublime text settings
mkdir $HOME/Library/Application Support/Sublime Text 3/Packages/Default
ln -nsf "$HOME/dotfiles/theme/sublimetext3/Default (OSX).sublime-keymap" "$HOME/Library/Application Support/Sublime Text 3/Packages/Default/"

git clone https://github.com/wfxr/forgit.git $HOME/.oh-my-zsh/plugins/forgit

git clone https://github.com/seebi/dircolors-solarized.git $HOME/.oh-my-zsh/plugins/dircolors-solarized
$(brew --prefix)/opt/fzf/install

git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

git clone git@github.com:b4b4r07/enhancd.git $HOME/.oh-my-zsh/plugins/enhancd
git clone git@github.com:chitoku-k/fzf-zsh-completions.git $HOME/.oh-my-zsh/plugins/fzf-zsh-completions

git clone git@github.com:zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
git clone git@github.com:zsh-users/zsh-completions $HOME/.oh-my-zsh/plugins/zsh-completions
git clone git@github.com:zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting

# Install rust packages (no brewed)
cargo install cpz

# Install fonts (0xProto)
wget https://github.com/0xType/0xProto/releases/download/$FONT_VERSION_0xProto/$DOWNLOAD_NAME_0xProto.zip && \
  unzip $DOWNLOAD_NAME_0xProto.zip && \
  cd $DOWNLOAD_NAME_0xProto && \
  cp ./* ~/Library/Fonts/


# Install fonts (HackGen)
wget https://github.com/yuru7/HackGen/releases/download/$FONT_VERSION_HackGen/$DOWNLOAD_NAME_HackGen.zip && \
  unzip $DOWNLOAD_NAME_HackGen.zip && \
  cd $DOWNLOAD_NAME_HackGen && \
  cp ./* ~/Library/Fonts/


# Install fonts (Source Han Code JP)
wget -O ~/Library/Fonts/$DOWNLOAD_NAME_SourceHanCodeJP https://github.com/adobe-fonts/source-han-code-jp/releases/download/$FONT_VERSION_SourceHanCodeJP/$DOWNLOAD_NAME_SourceHanCodeJP

# Source
source $HOME/.zshrc

defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 5
defaults write com.apple.desktopservices DSDontWriteNetworkStores True
killall Finder

# Private setup
private/setup.sh

# Install coderabbit
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
