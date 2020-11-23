show-error() {
  echo >&2
  # /bin/cat $HOME/scripts/.error_cat >&2
}

error_catcher_preexec() {
  ERROR_CATCHER_CALLED=1
}

error_catcher_precmd() {
  local exit_status=$?
  if [[ ! ${exit_status} =~ ^(0|130)$ ]] && [[ "${ERROR_CATCHER_CALLED}" -eq 1 ]]; then
    show-error
  fi
  unset ERROR_CATCHER_CALLED
}

add-zsh-hook preexec error_catcher_preexec
add-zsh-hook precmd error_catcher_precmd
