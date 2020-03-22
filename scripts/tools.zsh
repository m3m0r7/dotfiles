make-brew-installed() {
  local path1 path2 oldpwd realpath
  realpath=$(readlink "$HOME/scripts")/..
  oldpwd=$(pwd)
  path1=$(echo $realpath/scripts/.brew_installed)
  path2=$(echo $realpath/scripts/.brew_cask_installed)
  brew list | awk "{print $7}" >"$path1"
  brew cask list | awk "{print $7}" >"$path2"
  cd $realpath
  git- add "$path1"
  git- add "$path2"
  git- commit -m "Update homebrew"
  git- push origin master
  cd $oldpwd
}
