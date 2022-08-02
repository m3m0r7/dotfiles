login-docker-hub() {
  echo $GITHUB_TOKEN | docker login ghcr.io -u ${GITHUB_USER} --password-stdin
}

alias ldh='login-docker-hub'
