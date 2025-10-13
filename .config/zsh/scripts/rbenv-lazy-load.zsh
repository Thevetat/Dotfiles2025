#!/usr/bin/env zsh
# Rbenv Lazy Loading
# This speeds up shell startup by ~350ms by deferring rbenv initialization
# until Ruby tools are actually needed

# Only set up lazy loading if rbenv is installed
if [ -d "$HOME/.rbenv" ] || command -v rbenv >/dev/null 2>&1; then
  # Add rbenv to PATH (lightweight, no execution)
  export PATH="$HOME/.rbenv/bin:$PATH"

  # Function to initialize rbenv when needed
  lazy_load_rbenv() {
    # Remove the wrapper functions (skip rake as it's an alias)
    unset -f ruby gem bundle rails rbenv

    # Initialize rbenv
    if command -v rbenv >/dev/null 2>&1; then
      eval "$(rbenv init - zsh)"
    fi
  }

  # Create wrapper functions for Ruby commands
  # These will trigger rbenv initialization on first use
  # Note: rake is handled by Prezto as an alias, so we skip it

  ruby() {
    lazy_load_rbenv
    ruby "$@"
  }

  gem() {
    lazy_load_rbenv
    gem "$@"
  }

  bundle() {
    lazy_load_rbenv
    bundle "$@"
  }

  # Skip rake - it's already defined as an alias by Prezto
  # When rbenv loads, it will handle rake properly

  rails() {
    lazy_load_rbenv
    rails "$@"
  }

  rbenv() {
    lazy_load_rbenv
    rbenv "$@"
  }
fi