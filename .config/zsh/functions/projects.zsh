#*
## Name: 
## Desc: 
## Inputs:
## Usage:
qgcd() {
    cd ~/Git/Quasar
    git clone $1
    local ldir=`ls -snew | head -1`
    echo $ldir
    cd $ldir
    pwd
    yarn
    qd
}
#*

gcnn() {
    cd ~/Git/Webdev/Nuxt
    git clone git@github.com:Thevetat/SignalAIBaseLayer.git "$*"
    cd "$*"
    rm -r -f .git
    git init
    pnpm i
}

#*
## Name: Git Clone Quasar Base
## Desc: Clones base quasar repo, cd's in, opens code, runs yarn, opens dev server
## Inputs: Name you want to call new folder
## Usage: gcqb playground
gcqb() {
    cd ~/Git/Quasar
    git clone --single-branch --branch electron git@gitlab.com:Paracelsus_Rose/vitebase.git "$*"
    cd "$*"
    rm -r -f .git
    git init
    yarn
    qd
}
#*

#*
## Change Docs
## Name: Git Clone Typescript Base
## Desc: Clones base quasar repo, cd's in, opens code, runs yarn, opens dev server
## Inputs: Name you want to call new folder
## Usage: gcqb playground
gctb() {
    cd ~/Git/Typescript
    git clone git@gitlab.com:sunshineunlimited/ts-base-reborn.git "$*"
    cd "$*"
    rm -r -f .git
    git init
    pnpm i
}
#*

#*
## Change Docs
## Name: Git Clone Typescript Base
## Desc: Clones base quasar repo, cd's in, opens code, runs yarn, opens dev server
## Inputs: Name you want to call new folder
## Usage: gcqb playground
gcnbub() {
    cd ~/Git/Go/tui/
    git clone git@github.com:Thevetat/new_bubble.git "$*"
    cd "$*"
    rm -r -f .git
    git init
}
#*

#*
## Change Docs
## Name: Git Clone Typescript Base
## Desc: Clones base quasar repo, cd's in, opens code, runs yarn, opens dev server
## Inputs: Name you want to call new folder
## Usage: gcqb playground
gcvb() {
    cd ~/Git/Vite
    git clone git@gitlab.com:sunshineunlimited/sunshine-base.git "$*"
    cd "$*"
    rm -r -f .git
    git init
    pnpm i
}
#*

#*
## Change Docs
## Name: Git Clone New Base
## Desc: Clones base quasar repo, cd's in, opens code, runs yarn, opens dev server
## Inputs: Name you want to call new folder
## Usage: gcqb playground
gcnb() {
    cd ~/Git/Vite
    git clone git@gitlab.com:sunshineunlimited/nbase.git "$*"
    cd "$*"
    rm -r -f .git
    git init
    pnpm i
}
#*

#*
## Change Docs
## Name: Git Clone Typescript Base
## Desc: Clones base quasar repo, cd's in, opens code, runs yarn, opens dev server
## Inputs: Name you want to call new folder
## Usage: gcqb playground
gceb() {
    cd ~/Git/Quasar
    git clone --single-branch --branch electron git@gitlab.com:Paracelsus_Rose/vitebase.git "$*"
    cd "$*"
    rm -r -f .git
    git init
    yarn
}
#*