#!/usr/bin/env zsh

if [[ "$OSTYPE" == "darwin"* ]]; then
  export NVM_DIR="$HOME/.nvm"

  lazy_load_nvm() {
    local cmd

    for cmd in node npm npx pnpm nvm netlify aigc; do
      (( $+functions[$cmd] )) && unset -f "$cmd"
    done

    if [ -f /opt/homebrew/opt/nvm/nvm.sh ]; then
      source /opt/homebrew/opt/nvm/nvm.sh

      if [ -f /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm ]; then
        source /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm
      fi
    fi
  }

  node() {
    lazy_load_nvm
    node "$@"
  }

  npm() {
    lazy_load_nvm
    npm "$@"
  }

  npx() {
    lazy_load_nvm
    npx "$@"
  }

  pnpm() {
    lazy_load_nvm
    pnpm "$@"
  }

  nvm() {
    lazy_load_nvm
    nvm "$@"
  }

  netlify() {
    lazy_load_nvm
    netlify "$@"
  }

  # Git auto-commit with oco (replaces alias from .aliases)
  aigc() {
    lazy_load_nvm
    git add . && oco --yes --no-verify
  }
fi
