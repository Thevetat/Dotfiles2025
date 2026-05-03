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
yes "y" | ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/"$*" -N ""
cat ~/.ssh/"$*".pub | xsel --clipboard
}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
cf() {
    xsel -b < "$*"
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
    open -a Numbers "$*"
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