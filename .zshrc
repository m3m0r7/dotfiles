# Start-up  ------------------------------------------------------------------------------------------------------------
export DISABLE_AUTO_UPDATE=true
export PATH=$HOME/.nodebrew/current/bin:$HOME/.cargo/bin:$HOME/.original-scripts/bin:$HOME/.composer/vendor/bin:$HOME/bin:/usr/local/bin:$PATH.
export ZSH="$HOME/.oh-my-zsh"

CASE_SENSITIVE="true"
FZF_DEFAULT_OPTS="--height=100% --reverse"

plugins=(zsh-syntax-highlighting zsh-completions zsh-autosuggestions enhancd fzf-zsh-completions)

# Exports --------------------------------------------------------------------------------------------------------------
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_231`
export GOPATH=$HOME/.go
export GO111MOD=on
export LANG=en_US.UTF-8
export ENHANCD_FILTER="fzf --reverse --ansi"
export ENHANCD_DISABLE_DOT=1
export HISTCONTROL=erasedups
export HISTIGNORE="history*:cd*:ls*"

source $ZSH/oh-my-zsh.sh

# Settings -------------------------------------------------------------------------------------------------------------
setopt NO_BEEP

HISTSIZE=10000
SAVEHIST=10000

show-error() {
  echo
  /bin/cat $HOME/.error_cat
}

make-brew-installed() {
  brew list | awk "{print $7}" >$HOME/.brew_installed
}

fzf-pr() {
  # gh_result=$(gh pr list -a $(git config --get user.name) 2>/dev/null)
  local gh_result result
  gh_result=$(gh pr list --limit 100 2>/dev/null)
  if [ $? != 0 ]; then
    show-error
    echo
    zle reset-prompt
    return
  fi

  result=$(
    echo $gh_result |
    awk '$0 ~ /./{print $0}' |
    awk '{ printf "%s %s ", $1, $NF; $1 = $NF = ""; print }' |
    _fzf_complete_tabularize $fg[blue] $reset_color |
    fzf --ansi --height=100% --reverse --prompt "PULL REQUEST> "
  )
  BUFFER=$LBUFFER$(echo $result | awk '{ print $2 }')
  CURSOR=$#BUFFER
}
zle -N fzf-pr
bindkey '^g' fzf-pr

fzf-files() {
  local command file_type
  command=$(echo $LBUFFER | awk '{print $1}')
  file_type="f"
  case "$command" in
    "cd")
        file_type="d"
    ;;
    "ls")
        file_type="d"
    ;;
  esac

  BUFFER=$LBUFFER$(fd -H -t $file_type | fzf --height=100% --reverse --prompt "FILE> ")
  CURSOR=$#BUFFER
}
zle -N fzf-files
bindkey '^f' fzf-files

fzf-history() {
  BUFFER=$(history | awk -F ' ' '{for(i=2;i<NF;++i){printf("%s ",$i)}print $NF}' | awk '!a[$0]++' | sort -r | fzf --height=100% --reverse --prompt "HISTORY> ")
  CURSOR=$#BUFFER
}
zle -N fzf-history
bindkey '^r' fzf-history

fzf-git-branch() {
  git branch -a 1>/dev/null 2>&1
  if [ $? != 0 ]; then
    show-error
    echo
    zle reset-prompt
    return
  fi

  local tags branches target
  branches=$(
    git --no-pager branch \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 --ansi --height=100% --reverse --prompt "GIT BRANCH> ") || return

  BUFFER=$LBUFFER$(awk '{print $2}' <<<"$target" )
  CURSOR=$#BUFFER
}
zle -N fzf-git-branch
bindkey '^b' fzf-git-branch

# Aliases --------------------------------------------------------------------------------------------------------------
alias pip='/usr/local/bin/pip3'
alias python='/usr/local/bin/python3'
alias xxd='hexyl'
alias tree='tree -a'
alias sed='gsed'
alias ls='exa --color-scale -l --git-ignore -h --git -@ --time-style=iso -T -F -L=1'
alias cat='bat'
alias q='pbcopy'
alias qq='pbpaste'
alias t='twterm'
alias grep='rg -n'
alias tkw='tmux kill-window'
alias p='pwd | q'
alias pp='cd $(qq) && p'

# Use defaults runtime (suffix added with -)
alias ls-='/bin/ls'
alias grep-='/usr/bin/grep'
alias xxd-='/usr/bin/xxd'
alias python-='/usr/local/bin/python'
alias pip-='/usr/local/bin/pip'
alias cat-='/bin/cat'

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

# Optimize oh-my-zsh ---------------------------------------------------------------------------------------------------
# Optimize copy & paste
# see: https://github.com/zsh-users/zsh-autosuggestions/issues/238#issuecomment-389324292
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish


autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit;
else
  compinit -C;
fi;

# Show memory-chan  ----------------------------------------------------------------------------------------------------
echo -e "\e[38;5;148m"
cat- $HOME/.memory_chan
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


# Theme ----------------------------------------------------------------------------------------------------------------
get_current_time() {
    date +"%H:%M:%S"
}
git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [ $? != 0 ]; then
    echo "\u2212"
    return
  fi
  echo "${ref#refs/heads/}"
}

PROMPT='$(print -n "\n%{%f%}")%K{148}%F{236} \$ %{$reset_color%}%F{148}$(echo "\ue0b0")%f%k%{$reset_color%} '
RPROMPT='%F{205}%(?..%?) %{$reset_color%}%F{234}$(echo "\ue0b2")%K{234}%F{250} $(git_prompt_info) %{$reset_color%}%K{234}%F{236}$(echo "\ue0b2")%K{236}%F{250} $(get_current_time) %{$reset_color%}'


