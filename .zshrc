# Start-up  ------------------------------------------------------------------------------------------------------------
export PATH=$HOME/.original-scripts/bin:$HOME/.composer/vendor/bin:$HOME/bin:/usr/local/bin:$PATH.
export ZSH="/Users/memory/.oh-my-zsh"

ZSH_THEME="memory"
CASE_SENSITIVE="true"

plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# Exports --------------------------------------------------------------------------------------------------------------
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_231`
export GOPATH=$HOME/.go
export GO111MOD=on
export LSCOLORS=ExFxCxdxBxegedabagacad
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export LANG=en_US.UTF-8

# Settings -------------------------------------------------------------------------------------------------------------
setopt NO_BEEP

HISTSIZE=10000
SAVEHIST=10000

chpwd() {
    echo "\e[1m\e[4m"
    pwd
    echo "\e[m"
    ls
}

brew-installed() {
    brew list | awk "{print $7}" >~/.brew_installed
}

# Change key binds -----------------------------------------------------------------------------------------------------
local peco-select-history() {
  BUFFER=$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" --prompt "HISTORY>")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

local peco-files() {
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

  BUFFER=$LBUFFER$(fd -H -t $FILE_TYPE | peco --prompt "FILE>")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-files
bindkey '^f' peco-files

local peco-git-branch() {
  git branch -a 1>/dev/null 2>&1
  if [ $? != 0 ]; then
    # Not found .git
    return
  fi
  BUFFER=$LBUFFER$(
    git branch -a |
    peco --prompt "GIT BRANCH>" |
    sed "s/^[ \*]*//g" |
    sed "s/remotes\/[^\/]*\/\(\S*\)/\1/"
  )
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-git-branch
bindkey '^b' peco-git-branch

# Aliases --------------------------------------------------------------------------------------------------------------
alias xxd='xxd -u -g 1'
alias tree='tree -a'
alias ls='ls -a -G'

# zstyle ---------------------------------------------------------------------------------------------------------------
zstyle ':completion:*' list-colors "${LS_COLORS}"

# histories ------------------------------------------------------------------------------------------------------------
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}

    [[  ${cmd} != (l|l[sal])
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
echo -e "\e[32;1m"
cat ~/.memory_chan
echo -e "\e[m"
