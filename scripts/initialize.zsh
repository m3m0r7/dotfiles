RUNNING_PROCESS_NAME=""

tmux-running-process-name() {
  RUNNING_PROCESS_NAME=${(s: :)${1}}
  tmux-window-name
}

tmux-ran-process-name() {
  RUNNING_PROCESS_NAME=""
  tmux-window-name
}

tmux-window-name() {
  local newName maxSize left right
  maxSize=14
  newName=$(pwd | rev | cut -c 1-$maxSize | rev)

  if [[ $RUNNING_PROCESS_NAME != "" ]]; then
    newName=$(echo $RUNNING_PROCESS_NAME | cut -c 1-$maxSize)
  fi

  if [[ ${#newName} -lt $maxSize ]]; then
    left=$(( ($maxSize - ${#newName}) / 2 ))
    right=$left

    if [[ $(( $maxSize - (${#newName} + $left + $right) )) -gt 0 ]]; then
      right=$(( $right + 1 ))
    fi

    newName=$(printf "% ${left}s" "")"$newName"$(printf "% ${right}s" "")
  fi
  tmux rename-window -- "$newName"
}

tmux-window-name
add-zsh-hook preexec tmux-running-process-name
add-zsh-hook precmd tmux-ran-process-name
add-zsh-hook chpwd tmux-window-name
