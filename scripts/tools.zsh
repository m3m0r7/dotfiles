make-brew-installed() {
  local path1 path2 oldpwd realpath
  realpath=$(readlink "$HOME/scripts")/..
  oldpwd=$(pwd)
  path1=$(echo $realpath/scripts/.brew_installed)
  path2=$(echo $realpath/scripts/.brew_cask_installed)
  brew list --formula | awk "{print $7}" >"$path1"
  brew list --cask | awk "{print $7}" >"$path2"
  cd $realpath
  \git add "$path1"
  \git add "$path2"
  \git commit -m "Update homebrew"
  \git push origin master
  cd $oldpwd
}

alias mbi='make-brew-installed'

login-docker-hub() {
  echo $GITHUB_TOKEN | docker login https://docker.pkg.github.com -u ${GITHUB_USER} --password-stdin
}

alias ldh='login-docker-hub'
