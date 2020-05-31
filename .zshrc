CASE_SENSITIVE="true"
FZF_DEFAULT_OPTS="--height=100% --reverse"

plugins=(zsh-syntax-highlighting zsh-completions zsh-autosuggestions enhancd fzf-zsh-completions)

alias fzf='fzf --ansi --height=100% --reverse --no-hscroll --no-multi'


source $HOME/scripts/exports.zsh
source $ZSH/oh-my-zsh.sh
source $HOME/scripts/settings.zsh
source $HOME/scripts/errors.zsh

eval $(gdircolors $HOME/dircolors-solarized/dircolors.256dark)

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
