if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d /opt/homebrew/share/zsh/site-functions ]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

export PATH="$HOME/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export DOCKER_HOST="unix:///$HOME/Library/Containers/com.docker.docker/Data/docker.raw.sock"
