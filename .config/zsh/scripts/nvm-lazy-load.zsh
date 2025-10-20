#!/usr/bin/env zsh
# NVM Lazy Loading for Mac
# This speeds up shell startup by ~1.8 seconds by deferring NVM initialization
# until Node.js tools are actually needed

if [[ "$OSTYPE" == "darwin"* ]]; then
  export NVM_DIR="$HOME/.nvm"

  # Function to load NVM when needed
  lazy_load_nvm() {
    # Remove the wrapper functions
    unset -f node npm npx pnpm nvm netlify aigc codex

    # Load NVM
    if [ -f /opt/homebrew/opt/nvm/nvm.sh ]; then
      source /opt/homebrew/opt/nvm/nvm.sh

      # Load NVM bash completion if available
      if [ -f /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm ]; then
        source /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm
      fi
    fi
  }

  # Create wrapper functions for Node.js commands
  # These will trigger NVM loading on first use
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

  # Codex wrapper
  codex() {
    lazy_load_nvm
    codex "$@"
  }
fi