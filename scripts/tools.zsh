login-docker-hub() {
  echo $GITHUB_TOKEN | docker login ghcr.io -u ${GITHUB_USER} --password-stdin
}

alias ldh='login-docker-hub'

kill_unnecessary_processes() {
  echo "Kill targets: $1"
  \ps ax | \rg -i $1 | awk '{ print $1 }' | xargs -I{} sh -c 'sudo kill "$1"' _ {}
}

cw() {
  git worktree list | awk 'NR > 1 { print $1 }' | xargs -I{} git worktree remove --force {}
}

alias ka="kill_unnecessary_processes '[c]hromium_headless|[a]gent-browser|[c]odex|[c]laude'"
