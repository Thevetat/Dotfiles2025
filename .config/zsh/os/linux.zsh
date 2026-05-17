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

alias nvid='sudo system76-power graphics nvidia'
alias hybrid='sudo system76-power graphics hybrid'
alias integrated='sudo system76-power graphics integrated'
alias i3conf='nvim ~/.config/regolith2/i3/config'
alias i3Xres='nvim ~/.config/regolith2/Xresources'
alias wpr='feh --no-fehbg --bg-fill "$HOME/Pictures/wallpapers/laser.jpg"'
alias n.='nautilus .'
alias nocam='sudo modprobe -r uvcvideo'
if [[ -n "$SSH_CONNECTION" ]] && command -v osc52-copy >/dev/null 2>&1; then
  alias clipboard-copy='osc52-copy'
  alias pbcopy='osc52-copy'
else
  alias clipboard-copy='xclip -selection clipboard'
  alias pbcopy='xclip -selection clipboard'
fi

alias clipboard-paste='xclip -selection clipboard -o'
alias pbpaste='xclip -selection clipboard -o'
