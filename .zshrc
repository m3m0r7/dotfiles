CASE_SENSITIVE="true"
FZF_DEFAULT_OPTS="--height=100% --reverse"
TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"

plugins=(zsh-syntax-highlighting zsh-completions zsh-autosuggestions enhancd fzf-zsh-completions forgit)

alias fzf='fzf --ansi --height=100% --reverse --no-hscroll --no-multi'

source $HOME/dotfiles/scripts/exports.zsh

if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]]; then
  return
fi

source $ZSH/oh-my-zsh.sh
source $HOME/dotfiles/scripts/settings.zsh
source $HOME/dotfiles/scripts/errors.zsh

eval $(gdircolors $HOME/.oh-my-zsh/plugins/dircolors-solarized/dircolors.256dark)

#source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source $HOME/enhancd/init.sh

export LS_COLORS=${(pj;:;)$(< $HOME/dotfiles/scripts/.ls_colors)}
source $HOME/dotfiles/scripts/zstyle.zsh

source $HOME/dotfiles/scripts/fzf.zsh
source $HOME/dotfiles/scripts/git.zsh
source $HOME/dotfiles/scripts/theme.zsh
source $HOME/dotfiles/scripts/optimizer.zsh
source $HOME/dotfiles/scripts/highlight.zsh
source $HOME/dotfiles/scripts/aliases.zsh
source $HOME/dotfiles/scripts/tools.zsh
source $HOME/dotfiles/scripts/initialize.zsh
source $HOME/dotfiles/scripts/aws.zsh
export OPENSSH="/usr/local/opt/openssh"
export VOLTA_HOME="$HOME/.volta"
export PATH="$OPENSSH/bin:$VOLTA_HOME/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
