fzf-checkout-histories() {
  local branches result target
  result=$(/usr/bin/git --no-pager reflog 2>/dev/null)
  if [[ ! $? =~ ^(0|130)$ ]]; then
    show-error
    echo
    return
  fi
  branches=$(echo $result | awk '$3 == "checkout:" && /moving from/ {print $8}')
  target=$(echo $branches | awk '$0 ~ /./{print $0}' | fzf --ansi --height=100% --reverse --prompt "HISTORY> ")
  /usr/bin/git checkout $target
}

fzf-checkout-files() {
  local result target
  ref=$(/usr/bin/git symbolic-ref HEAD 2> /dev/null)
  if [[ ${ref#refs/heads/} == 'master' ]]; then
    echo "No diff"
    return
  fi
  result=$(/usr/bin/git diff --name-only --diff-filter=ACMR origin/master...origin/${ref#refs/heads/})
  if [[ ! $? =~ ^(0|130)$ ]]; then
    show-error
    echo
    return
  fi
  target=$(echo $result | awk '$0 ~ /./{print $0}' | fzf --ansi --height=100% --reverse --prompt "FILE HISTORY> ")
  /usr/bin/git checkout -- $target
}

fzf-reset-files() {
  local result target
  ref=$(/usr/bin/git symbolic-ref HEAD 2> /dev/null)
  if [[ ${ref#refs/heads/} == 'master' ]]; then
    echo "No diff"
    return
  fi
  result=$(/usr/bin/git diff --name-only --diff-filter=ACMR origin/master...origin/${ref#refs/heads/})
  if [[ ! $? =~ ^(0|130)$ ]]; then
    show-error
    echo
    return
  fi
  target=$(echo $result | awk '$0 ~ /./{print $0}' | fzf --ansi --height=100% --reverse --prompt "FILE HISTORY> ")
  /usr/bin/git reset master -- $target
  /usr/bin/git checkout -- $target
}

enhanced-git-alias() {
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
  /usr/bin/git $(echo $@)
}

alias git='enhanced-git-alias'
