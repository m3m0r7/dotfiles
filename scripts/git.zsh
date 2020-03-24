_GIT_DIFF_FILES=
_get_git_diff_files() {
  ref=$(/usr/bin/git symbolic-ref HEAD 2> /dev/null)
  if [[ ${ref#refs/heads/} == 'master' ]]; then
    return 1
  fi
  _GIT_DIFF_FILES=$(/usr/bin/git diff --name-only --diff-filter=ACMR origin/master...HEAD)
  if [[ ! $? =~ ^(0|130)$ ]]; then
    return 1
  fi
  return 0
}

fzf-checkout-histories() {
  local branches result target current
  result=$(/usr/bin/git --no-pager reflog 2>/dev/null)
  current=${$(/usr/bin/git symbolic-ref HEAD 2> /dev/null)#refs/heads/}
  if [[ ! $? =~ ^(0|130)$ ]]; then
    return 1
  fi
  branches=$(
    echo "$result" |
    awk '$3 == "checkout:" && !a[$8]++ && NR>1 && $8 != "'"$current"'" && /moving from/ {print $8}'
  )
  target=$(
    echo $branches |
    awk '$0 ~ /./{print $0}' |
    fzf --prompt "HISTORY> "
  )
  /usr/bin/git checkout "$target"
}

fzf-checkout-files() {
  local target
  _get_git_diff_files
  if [[ $? == 1 ]]; then
    return 1
  fi
  target=$(echo "$_GIT_DIFF_FILES" | awk '$0 ~ /./{print $0}' | fzf --prompt "FILE HISTORY> ")
  /usr/bin/git checkout -- "$target"
}

fzf-reset-files() {
  local target
  _get_git_diff_files
  if [[ $? == 1 ]]; then
    return 1
  fi
  target=$(echo "$_GIT_DIFF_FILES" | awk '$0 ~ /./{print $0}' | fzf --prompt "FILE HISTORY> ")
  /usr/bin/git reset master -- "$target"
  /usr/bin/git checkout -- "$target"
}

enhanced-/usr/bin/gitalias() {
  if [[ $1 == 'checkout' ]]; then
    case "$2" in
      "-")
        fzf-checkout-histories
        return
      ;;
      "--")
        if [[ $3 == '' ]]; then
          fzf-checkout-files
          return
        fi
      ;;
    esac
  fi
  if [[ $1 == 'reset' ]] && [[ $2 == 'master' ]]; then
    case "$3" in
      "--")
        if [[ $4 == '' ]]; then
          fzf-reset-files
          return
        fi
      ;;
    esac
  fi

  # shellcheck disable=SC2068
  /usr/bin/git $@
}

alias git='enhanced-/usr/bin/gitalias'
