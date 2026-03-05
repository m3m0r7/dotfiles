CASE_SENSITIVE="true"
FZF_DEFAULT_OPTS="--height=100% --reverse"
TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"

plugins=(zsh-syntax-highlighting zsh-completions zsh-autosuggestions enhancd fzf-zsh-completions forgit)

alias c='claude --dangerously-skip-permissions'
alias x='codex --dangerously-bypass-approvals-and-sandbox'

alias t='llm-translator-rust'
alias fzf='fzf --ansi --height=100% --reverse --no-hscroll --no-multi'
alias zi='osascript -e '\''tell application "System Events" to key code 24 using {command down, option down}'\'''
alias zo='osascript -e '\''tell application "System Events" to key code 27 using {command down, option down}'\'''
alias ze='osascript -e '\''tell application "System Events" to key code 28 using {command down, option down}'\'''
alias zoom-in='zi'
alias zoom-out='zo'
alias zoom-end='ze'

source $DOTFILES_DIR/scripts/exports.zsh

is_jetbrains_terminal() {
  [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]]
}

if is_jetbrains_terminal; then
  return
fi

source $ZSH/oh-my-zsh.sh
source $DOTFILES_DIR/scripts/settings.zsh
source $DOTFILES_DIR/scripts/errors.zsh

eval $(gdircolors $HOME/.oh-my-zsh/plugins/dircolors-solarized/dircolors.256dark)

#source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source $HOME/enhancd/init.sh

export LS_COLORS=${(pj;:;)$(< $DOTFILES_DIR/scripts/.ls_colors)}
source $DOTFILES_DIR/scripts/zstyle.zsh

source $DOTFILES_DIR/scripts/fzf.zsh
source $DOTFILES_DIR/scripts/git.zsh
source $DOTFILES_DIR/scripts/theme.zsh
source $DOTFILES_DIR/scripts/optimizer.zsh
source $DOTFILES_DIR/scripts/highlight.zsh
source $DOTFILES_DIR/scripts/aliases.zsh
source $DOTFILES_DIR/scripts/tools.zsh
source $DOTFILES_DIR/scripts/initialize.zsh
source $DOTFILES_DIR/scripts/aws.zsh
export OPENSSH="/usr/local/opt/openssh"
export VOLTA_HOME="$HOME/.volta"
export PATH="$OPENSSH/bin:$VOLTA_HOME/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
