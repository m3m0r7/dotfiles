export HISTCONTROL=erasedups
export HISTIGNORE="history*:cd*:ls*"

zshaddhistory() {
  local line=${1%%$'\n'}
  local cmd=${line%% *}

  [[  ${cmd} != (l|l[sal]|ls|cd|';')
    && ${cmd} != (m|man)
    && ${cmd} != (r[mr])
  ]]
}

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


#
# Ref: https://gist.github.com/znppunfuv/060107438d8ea06d623f0cbcb019950f
#
add-zsh-hook preexec optimize_history_preexec
add-zsh-hook precmd optimize_history_precmd


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
