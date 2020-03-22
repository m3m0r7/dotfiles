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
    fzf --prompt "PULL REQUEST> "
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

  BUFFER=$LBUFFER$(fd -H -t $file_type | fzf --prompt "FILE> ")
  CURSOR=$#BUFFER
}
zle -N fzf-files
bindkey '^f' fzf-files

fzf-history() {
  BUFFER=$(history | awk -F ' ' '{for(i=2;i<NF;++i){printf("%s ",$i)}print $NF}' | awk '!a[$0]++' | sort -r | fzf --prompt "HISTORY> ")
  CURSOR=$#BUFFER
}
zle -N fzf-history
bindkey '^r' fzf-history

fzf-git-branch() {
  git branch 1>/dev/null 2>&1
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
    (echo "$branches"; echo "$tags") | awk '$0 ~ /./{print $0}' |
    fzf --prompt "GIT BRANCH> ") || return

  BUFFER=$LBUFFER$(awk '{print $2}' <<<"$target" )
  CURSOR=$#BUFFER
}
zle -N fzf-git-branch
bindkey '^b' fzf-git-branch
