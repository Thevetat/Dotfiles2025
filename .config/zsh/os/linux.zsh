export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
  . "$NVM_DIR/bash_completion"
fi

if [[ -n $SSH_CONNECTION ]]; then
  unsetopt CORRECT
  unsetopt CORRECT_ALL

  if [ -t 0 ]; then
    stty -ixon 2>/dev/null
  fi

  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export TERM_PROGRAM="${TERM_PROGRAM:-tmux}"

  if [ -z "$TMUX" ] && [ -t 0 ] && [ -t 1 ]; then
    if command -v tmux >/dev/null 2>&1; then
      exec tmux -u new -A -s main
    fi
  fi
fi
