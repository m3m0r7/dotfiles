local get_current_time() {
    date +"%H:%M:%S"
}
function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [ $? != 0 ]; then
    echo "\u2212"
    return
  fi
  echo "${ref#refs/heads/}"
}

PROMPT='%K{148}%F{236} \$ %{$reset_color%}%F{148}$(echo "\ue0b0")%f%k%{$reset_color%} '

RPROMPT='%F{205}%(?..%?) %{$reset_color%}%F{234}$(echo "\ue0b2")%K{234}%F{250} $(git_prompt_info) %{$reset_color%}%K{234}%F{236}$(echo "\ue0b2")%K{236}%F{250} $(get_current_time) %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"
