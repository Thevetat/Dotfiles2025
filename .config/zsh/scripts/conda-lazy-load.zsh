#!/usr/bin/env zsh
# Conda Lazy Loading for Mac
# This speeds up shell startup by ~60ms by deferring Conda initialization
# until Python/Conda tools are actually needed

if [[ "$OSTYPE" == "darwin"* ]] && [ -f "$HOME/miniconda3/bin/conda" ]; then
  # Add conda to PATH (lightweight, no execution)
  export PATH="$HOME/miniconda3/bin:$PATH"

  # Function to initialize Conda when needed
  lazy_load_conda() {
    # Remove the wrapper functions
    unset -f conda python pip python3 pip3 jupyter ipython mamba

    # Initialize Conda
    if [ -f "$HOME/miniconda3/bin/conda" ]; then
      __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
        eval "$__conda_setup"
      else
        [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ] && . "$HOME/miniconda3/etc/profile.d/conda.sh"
      fi
      unset __conda_setup
    fi
  }

  # Create wrapper functions for Conda/Python commands
  # These will trigger Conda initialization on first use
  conda() {
    lazy_load_conda
    conda "$@"
  }

  # Only wrap python/pip if they're conda's versions
  if [[ "$(which python 2>/dev/null)" == "$HOME/miniconda3"* ]]; then
    python() {
      lazy_load_conda
      python "$@"
    }

    python3() {
      lazy_load_conda
      python3 "$@"
    }
  fi

  if [[ "$(which pip 2>/dev/null)" == "$HOME/miniconda3"* ]]; then
    pip() {
      lazy_load_conda
      pip "$@"
    }

    pip3() {
      lazy_load_conda
      pip3 "$@"
    }
  fi

  # Jupyter and IPython are typically conda-specific
  jupyter() {
    lazy_load_conda
    jupyter "$@"
  }

  ipython() {
    lazy_load_conda
    ipython "$@"
  }

  # Mamba (if installed via conda)
  mamba() {
    lazy_load_conda
    mamba "$@"
  }
fi