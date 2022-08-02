CASE_SENSITIVE="true"
FZF_DEFAULT_OPTS="--height=100% --reverse"

plugins=(zsh-syntax-highlighting zsh-completions zsh-autosuggestions enhancd fzf-zsh-completions forgit)

alias fzf='fzf --ansi --height=100% --reverse --no-hscroll --no-multi'


source $HOME/scripts/exports.zsh
source $ZSH/oh-my-zsh.sh
source $HOME/scripts/settings.zsh
source $HOME/scripts/errors.zsh

eval $(gdircolors $HOME/.oh-my-zsh/plugins/dircolors-solarized/dircolors.256dark)

export LS_COLORS=${(pj;:;)$(< $HOME/scripts/.ls_colors)}
export EXA_COLORS=${(pj;:;)$(< $HOME/scripts/.exa_colors)}
source $HOME/scripts/zstyle.zsh

source $HOME/scripts/fzf.zsh
source $HOME/scripts/git.zsh
source $HOME/scripts/theme.zsh
source $HOME/scripts/optimizer.zsh
source $HOME/scripts/highlight.zsh
source $HOME/scripts/aliases.zsh
source $HOME/scripts/tools.zsh
source $HOME/scripts/initialize.zsh
source $HOME/scripts/aws.zsh
export OPENSSH="/usr/local/opt/openssh"
export VOLTA_HOME="$HOME/.volta"
export PATH="$OPENSSH/bin:$VOLTA_HOME/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
