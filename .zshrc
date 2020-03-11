# Start-up  ------------------------------------------------------------------------------------------------------------
export PATH=$HOME/.nodebrew/current/bin:$HOME/.cargo/bin:$HOME/.original-scripts/bin:$HOME/.composer/vendor/bin:$HOME/bin:/usr/local/bin:$PATH.
export ZSH="/Users/memory/.oh-my-zsh"

ZSH_THEME="memory"
CASE_SENSITIVE="true"
FZF_DEFAULT_OPTS="--height=100% --reverse"

plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions enhancd fzf-zsh-completions)
source $ZSH/oh-my-zsh.sh

# Exports --------------------------------------------------------------------------------------------------------------
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_231`
export GOPATH=$HOME/.go
export GO111MOD=on
export LANG=en_US.UTF-8
export ENHANCD_FILTER="fzf --reverse"
export ENHANCD_DISABLE_DOT=1
export HISTCONTROL=erasedups
export HISTIGNORE="history*:cd*:ls*"

# Settings -------------------------------------------------------------------------------------------------------------
setopt NO_BEEP

HISTSIZE=10000
SAVEHIST=10000

brew-installed() {
    brew list | awk "{print $7}" >$HOME/.brew_installed
}

local fzf-files() {
  COMMAND=$(echo $LBUFFER | awk '{print $1}')
  FILE_TYPE="f"
  case "$COMMAND" in
    "cd")
        FILE_TYPE="d"
    ;;
    "ls")
        FILE_TYPE="d"
    ;;
  esac

  BUFFER=$LBUFFER$(fd -H -t $FILE_TYPE | fzf --height=100% --reverse --prompt "FILE> ")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf-files
bindkey '^f' fzf-files

local fzf-history() {
  BUFFER=$(history | awk -F ' ' '{for(i=2;i<NF;++i){printf("%s ",$i)}print $NF}' | awk '!a[$0]++' | sort -r | fzf --height=100% --reverse --prompt "HISTORY> ")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf-history
bindkey '^r' fzf-history

local fzf-git-branch() {
  git branch -a 1>/dev/null 2>&1
  if [ $? != 0 ]; then
    # Not found .git
    return
  fi
  BUFFER=$LBUFFER$(
    git branch -a |
    sed "s/^[ \*]*//g" |
    fzf --height=100% --reverse --prompt "GIT BRANCH> " |
    sed "s/remotes\/[^\/]*\/\(\S*\)/\1/"
  )
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf-git-branch
bindkey '^b' fzf-git-branch

# Aliases --------------------------------------------------------------------------------------------------------------
alias pip2='/usr/local/bin/pip'
alias pip='/usr/local/bin/pip3'
alias python2='/usr/local/bin/python'
alias python='/usr/local/bin/python3'
alias xxd='hexyl'
alias tree='tree -a'
alias sed='gsed'
alias ls='exa --color-scale -l --git-ignore -h --git -@ --time-style=iso --inode -T -F -L=1'
alias catx='bat'
alias p='pbcopy'
alias pp='pbpaste'
alias t='twterm'
alias grep='rg -n'
alias tkw='tmux kill-window'

# histories ------------------------------------------------------------------------------------------------------------
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}

    [[  ${cmd} != (l|l[sal]|ls|cd|';')
        && ${cmd} != (m|man)
        && ${cmd} != (r[mr])
    ]]
}

#
# Ref: https://gist.github.com/znppunfuv/060107438d8ea06d623f0cbcb019950f
#
add-zsh-hook preexec optimize_history_preexec
add-zsh-hook precmd optimize_history_precmd

optimize_history_preexec() {
    OPTIMIZE_HISTORY_CALLED=1
}

optimize_history_precmd() {
    local exit_status=$?
    local history_file="${HISTFILE-"${ZDOTDIR-"${HOME}"}/.zsh_history"}"
    # Exit Code 130: Script terminated by Ctrl-C
    if [[ ! ${exit_status} =~ ^(0|130)$ ]] && [[ "${OPTIMIZE_HISTORY_CALLED}" -eq 1 ]]; then
        # BSD || GNU
        command sed -i '' '$d' "${history_file}" 2>/dev/null || command sed -i '$d' "${history_file}"
    fi
    unset OPTIMIZE_HISTORY_CALLED
}

# Show memory-chan  ----------------------------------------------------------------------------------------------------
echo -e "\e[38;5;148m"
cat $HOME/.memory_chan
echo -e "\e[m"

eval $(gdircolors $HOME/dircolors-solarized/dircolors.256dark)

export LS_COLORS=${(pj;:;)$(< $HOME/.ls_colors)}
export EXA_COLORS=${(pj;:;)$(< $HOME/.exa_colors)}

# Envs  ----------------------------------------------------------------------------------------------------------------
export TSC_WATCHFILE=UseFsEventsWithFallbackDynamicPolling

# colors ---------------------------------------------------------------------------------------------------------------
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='none'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=148'
ZSH_HIGHLIGHT_STYLES[function]='fg=148'
ZSH_HIGHLIGHT_STYLES[command]='fg=148'
ZSH_HIGHLIGHT_STYLES[alias]='fg=148'

ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=bold'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=bold'

ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=253'

ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=220'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=220'

ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=220'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=220'

ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=220'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=220'

ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=141'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=141'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=141'

ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=141'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=141'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=141'

ZSH_HIGHLIGHT_STYLES[assign]='fg=116'

ZSH_HIGHLIGHT_STYLES[redirection]='fg=bold'
ZSH_HIGHLIGHT_STYLES[path]='none'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=bold'

ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=245'

# zstyle ---------------------------------------------------------------------------------------------------------------
zstyle ':completion:*' list-colors "${LS_COLORS}"
