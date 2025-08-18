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