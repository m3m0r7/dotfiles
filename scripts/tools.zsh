make-brew-installed() {
  brew list | awk "{print $7}" >$HOME/scripts/.brew_installed
  brew cask list | awk "{print $7}" >$HOME/scripts/.brew_cask_installed
}
