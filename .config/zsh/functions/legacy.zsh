shopliftdev() {
    PORT=3000 HOST=https://7524-104-128-161-112.ngrok.io/ dotnet run watch
}

switchnvim() {
    mv ~/.config/nvim ~/.config/nvim_old
    mv ~/.config/nvimA ~/.config/nvim
    mv ~/.config/nvim_old ~/.config/nvimA

    mv ~/.local/share/nvim ~/.local/share/nvim_old
    mv ~/.local/share/nvimA ~/.local/share/nvim
    mv ~/.local/share/nvim_old ~/.local/share/nvimA
}

genDepPics() {
    dep_full="./dep_docs/full/pics"
    dep_collapsed="./dep_docs/collapsed/pics"

    rm -r -f $dep_full
    rm -r -f $dep_collapsed
}

ubcomp() {
  cd src/core/components/base
  git pull
  git add .
  git commit -m "update bcomp"
  git push
  cd ../../../../
}

fd2() {
    curl -fsSL https://d2lang.com/install.sh | sh -s -- --uninstall
    rm -r -f $HOME/.local/bin/d2
    rm -r -f $HOME/.local/lib/d2
    rm -r -f $HOME/Git/External/d2/
    curl -fsSL https://d2lang.com/install.sh | sh -s -- --tala
    rm -r -f $HOME/.local/bin/d2
    rm -r -f $HOME/.local/lib/d2
    gcd git@github.com:terrastruct/d2
    ./ci/release/build.sh --install
    d2 -v
    d2 layout tala
}

d2r() {
    D2_LAYOUT=tala d2 --watch --sketch "$*".d2 "$*".svg
}

rcd2() {
    rm -r -f ci/release/build/$1
    d2c
}

dlsc() {
   scdl -l "$*" --addtofile --onlymp3 --no-playlist-folder --extract-artist -c
}

nd() {
    netlify unlink
    netlify sites:delete "$*" --force
}