get_current_time() {
  date +"%H:%M:%S"
}
git_prompt_info() {
  ref=$(\git symbolic-ref HEAD 2> /dev/null)
  if [ $? != 0 ]; then
    echo "\u2212"
    return
  fi
  echo "${ref#refs/heads/}"
}

# @ref https://github.com/chitoku-k/dotfiles/blob/5b383d2b672635212fc3d75bafe7ea0f3ecb9e0b/config/zsh/plugins/prompt.zsh#L7
typeset -gA _zsh_prompt_format

_prompt_format() {
  local bg1=$1
  local fg1=$2
  local type=$3
  local append=$4
  _zsh_prompt_format[$type-prefix]='$(print -n "\n%{%f%}")%K{'$bg1'}%F{'$fg1'} \$ %{$reset_color%}%F{'$bg1'}$(echo "\ue0b0")%f%k%{$reset_color%} '$append

}

_right_prompt_format() {
  local bg1=$1
  local fg1=$2
  local bg2=$3
  local fg2=$4
  local code=$5
  local type=$6
  _zsh_prompt_format[$type-right]='%F{'$code'}%(?..%?) %{$reset_color%}%F{'$bg1'}$(echo "\ue0b2")%K{'$bg1'}%F{'$fg1'} $(git_prompt_info) %{$reset_color%}%K{'$bg1'}%F{'$bg2'}$(echo "\ue0b2")%K{'$bg2'}%F{'$fg2'} $(get_current_time) %{$reset_color%}'
}

_prompt_format 148 236 normal
_prompt_format 235 244 finish
_right_prompt_format 234 250 236 250 205 normal
_right_prompt_format 232 238 233 239 239 finish

_zsh_prompt_redraw() {
  if [[ $1 = '0' ]] || [[ $WIDGET =~ finish ]]; then
    _zsh_highlight_style_inactive
    _zsh_prompt 'finish'
    return
  fi

  _zsh_highlight_style_defaults
  _zsh_prompt 'normal'
}

_zsh_prompt() {
  local prefix=${_zsh_prompt_format[$1-prefix]}
  local right=${_zsh_prompt_format[$1-right]}
  PROMPT=$prefix
  RPROMPT=$right
  zle reset-prompt
}

zle -N zle-line-init _zsh_prompt_redraw
zle -N zle-line-finish _zsh_prompt_redraw
zle -N zle-keymap-select _zsh_prompt_redraw

# Set the default value
PROMPT=${_zsh_prompt_format[normal-prefix]}
RPROMPT=${_zsh_prompt_format[normal-right]}
