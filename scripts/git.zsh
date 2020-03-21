enhanced-git-alias() {
  local cmd_result
  cmd_result=$(echo $@ | sed 's/\s+/ /')
  if [[ ${cmd_result} == 'checkout -' ]]; then
    fzf-checkout-histories
    return
  fi
  /usr/bin/git $(echo $@)
}

