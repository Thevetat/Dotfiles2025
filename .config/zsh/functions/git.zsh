#*
## Name: 
## Desc: 
## Inputs:
## Usage:
function gcaa () {(
    git add . && git commit -m "$*" && git push
    )}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
og() {(
    set -e
    git remote -v | grep push
    remote=${1:-origin}
    echo "Using remote $remote"
    URL=$(git config remote.$remote.url | sed "s/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/")
    echo "Opening $URL..."
    open $URL
)}
#*

gcd() {
    cd ~/Git/External
    if [ -z $1 ]
    then
        echo "Error: No repository URL provided"
        return 1
    fi

    repo_name=$(echo $1 | sed -E 's#(https://(github|gitlab)\.com/)([^/]+/[^/]+)/?#\3#' | cut -d '/' -f 2)

    git clone $1

    if [ $? -eq 0 ]
    then
        cd "$repo_name"
        echo "Successfully cloned and entered repository: $repo_name"
    else
        echo "Error: Repository not cloned"
        return 1
    fi
    ls -a 
}

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
gpar() {
    find . -type d -name .git -exec git --git-dir={} --work-tree=$PWD/{}/.. pull origin master
}
#*

gsubi() {
    git submodule update --init --recursive
}

gsuba() {
    git submodule add git@github.com:Thevetat/ComponentSubmodule.git base_components
}

gsubar() {
    git submodule add git@github.com:Thevetat/BaseReactSubmod.git ./src/base_submod
}

gsubp() {
z base_components
git add .
git commit -m "Updated Component Submodule"
git push
z ../
}

gsubu() {
z base_components
git pull
z ../
}

cng() {
    git init --initial-branch=main
    git remote add origin $1
    git add .
    git commit -m "Initial commit"
    git push -u origin main
}

pnr() {
    git init --initial-branch=main
    git remote add origin "$*"
    git add .
    git commit -m "Initial commit"
    git push --set-upstream origin main
}

gres() {
    if [ $# -lt 2 ]; then
        echo "Usage: gres <commit-hash> <commit-message>"
        return 1
    fi

    local commit_hash="$1"
    shift
    local commit_message="$*"

    git reset --soft "$commit_hash" && \
    git commit -m "$commit_message" && \
    git push --force-with-lease
}

#*
## Name: gstats
## Desc: Display comprehensive git statistics for the current repository
## Inputs: None
## Usage: gstats
gstats() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    local user_name=$(git config user.name)
    local repo_name=$(basename -s .git $(git config --get remote.origin.url))
    
    echo "📊 Git Statistics for: $repo_name"
    echo "================================="
    echo ""
    
    echo "👤 YOUR PERSONAL STATS:"
    echo "-----------------------"
    
    # Your total lines
    local your_stats=$(git log --author="$user_name" --pretty=tformat: --numstat | awk '{add += $1; subs += $2; loc += $1 - $2} END {printf "Added: %s, Removed: %s, Net: %s", add, subs, loc}')
    echo "  📝 All Time Lines: $your_stats"
    
    # Your commit count
    local your_commits=$(git log --author="$user_name" --oneline | wc -l | tr -d ' ')
    echo "  🔢 Total Commits: $your_commits"
    
    # Your recent activity (last month)
    local recent_stats=$(git log --author="$user_name" --pretty=tformat: --numstat --since="1 month ago" | awk '{add += $1; subs += $2; loc += $1 - $2} END {printf "Added: %s, Removed: %s, Net: %s", add, subs, loc}')
    echo "  📅 Last Month: $recent_stats"
    
    # Your recent commits (last month)
    local recent_commits=$(git log --author="$user_name" --oneline --since="1 month ago" | wc -l | tr -d ' ')
    echo "  📅 Last Month Commits: $recent_commits"
    
    echo ""
    echo "📊 FULL REPOSITORY STATS:"
    echo "------------------------"
    
    # Total repository stats
    local total_commits=$(git rev-list --all --count)
    echo "  🔢 Total Repository Commits: $total_commits"
    
    # Repository age
    local first_commit=$(git log --reverse --pretty=format:"%ad" --date=short | head -1)
    local last_commit=$(git log -1 --pretty=format:"%ad" --date=short)
    echo "  📅 Repository Age: $first_commit to $last_commit"
    
    # Active contributors (with commits)
    local contributor_count=$(git log --all --pretty=format:"%an" | sort | uniq | wc -l | tr -d ' ')
    echo "  👥 Active Contributors: $contributor_count"
    
    echo ""
    echo "🏆 Top Contributors (by commits):"
    echo "---------------------------------"
    
    # All contributors by commit count
    git log --all --pretty=format:"%an" | sort | uniq -c | sort -nr | head -10 | while read count author; do
        if [ "$author" = "$user_name" ]; then
            echo "  🌟 $count $author (YOU)"
        else
            echo "     $count $author"
        fi
    done
    
    echo ""
    echo "📈 Recent Activity (last 10 commits):"
    echo "------------------------------------"
    git log --oneline --date=short --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) %C(green)%an%C(reset) %s" -10
}
#*

#*
## Name: gfuck
## Desc: Fix git issues using OpenCode AI by analyzing recent terminal history
## Inputs: None (uses fc -ln to get recent commands)
## Usage: gfuck (run after a git command fails)
gfuck() {
    local recent_history=$(fc -ln -50 | tail -50)

    local prompt="I just ran some git commands and encountered an error. Here's my recent terminal history:

\`\`\`
$recent_history
\`\`\`

Please analyze what went wrong and fix it. Focus on the most recent git-related error. Common issues include:
- Push rejected (need to pull first)
- Merge conflicts
- Authentication issues
- Branch issues

Fix the issue by running the appropriate git commands."

    opencode run -m anthropic/claude-sonnet-4-5-20250929 "$prompt"
}
#*