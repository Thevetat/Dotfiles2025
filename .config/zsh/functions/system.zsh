if (( ! $+functions[_copy_clipboard] )); then
  _copy_clipboard() {
    if [[ -n "$SSH_CONNECTION" ]] && command -v osc52-copy >/dev/null 2>&1; then
      osc52-copy
    elif command -v pbcopy >/dev/null 2>&1; then
      pbcopy
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
      xsel --clipboard --input
    elif command -v wl-copy >/dev/null 2>&1; then
      wl-copy
    elif command -v clip.exe >/dev/null 2>&1; then
      clip.exe
    else
      echo "Error: no clipboard command found (pbcopy/xclip/xsel/wl-copy/clip.exe)" >&2
      return 1
    fi
  }
fi

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
nr() {
  mkdir "$*"
  cd "$*"
}
#*  

#*
## Name: Find
## Desc: Find a file matching the input
## Inputs: Pattern you want to search for
## Usage: f .json
f() {
    find . | grep -i "$*"
}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
m() {
    mkdir "$*"
}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
newssh() {
    if [[ -z "$1" ]]; then
        echo "Usage: newssh <key-name>"
        return 1
    fi

    local key_path="$HOME/.ssh/$*"
    yes "y" | ssh-keygen -o -a 100 -t ed25519 -f "$key_path" -N ""
    _copy_clipboard < "${key_path}.pub"
}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
cf() {
    if [[ -z "$1" ]]; then
        echo "Usage: cf <file>"
        return 1
    fi

    _copy_clipboard < "$1"
}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
freshnvim() {
    mkdir ~/.config/.nvim_backup
    mkdir ~/.config/.nvim_backup/.local/share/nvim
    mkdir ~/.config/.nvim_backup/.cache/nvim
    cp -r -f ~/.config/nvim ~/.config/.nvim_backup/
    cp -r -f ~/.local/share/nvim ~/.config/.nvim_backup/.local/share/nvim
    cp -r -f ~/.cache/nvim ~/.config/.nvim_backup/.cache/nvim
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim 
    rm -rf ~/.cache/nvim
}
#*

cw() {
    cd "$(which "$*" | xargs -0 dirname)"
}

#*
## Name: Open CSV
## Desc: Open a CSV file in Numbers
## Inputs: CSV filename
## Usage: ocsv database_account_statement.csv
ocsv() {
    if [[ "$OSTYPE" != darwin* ]]; then
        echo "ocsv requires macOS Numbers"
        return 1
    fi

    open -a Numbers "$@"
}
#*

#*
## Name: Yazi (cd-on-quit)
## Desc: Launch yazi; on quit, cd shell into the last directory browsed. Use Q inside yazi to exit without cd-ing.
## Inputs: Optional starting path / yazi args
## Usage: y               # browse from $PWD
##        y ~/Git         # start in ~/Git
y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
#*
