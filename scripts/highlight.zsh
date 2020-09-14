typeset -A ZSH_HIGHLIGHT_STYLES

_zsh_highlight_style_inactive() {
  ZSH_HIGHLIGHT_STYLES[default]='fg=239'

  ZSH_HIGHLIGHT_STYLES[unknown-token]='none'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=239'
  ZSH_HIGHLIGHT_STYLES[function]='fg=239'
  ZSH_HIGHLIGHT_STYLES[command]='fg=239'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=239'

  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=bold'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=bold'

  ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=239'

  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=239'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=239'

  ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=239'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=239'

  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=239'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=239'

  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=239'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=239'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=239'

  ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=239'
  ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=239'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=239'

  ZSH_HIGHLIGHT_STYLES[assign]='fg=239'

  ZSH_HIGHLIGHT_STYLES[redirection]='fg=bold'
  ZSH_HIGHLIGHT_STYLES[path]='none'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=bold'

  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=239'
}

_zsh_highlight_style_defaults() {
  ZSH_HIGHLIGHT_STYLES[default]='none'

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
}

_zsh_highlight_style_defaults
