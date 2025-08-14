#!/bin/bash

# Git Auto-Pull Script
# Automatically pulls repositories listed in ~/repos file

LOG_FILE="$HOME/.local/share/git-auto-pull.log"
REPOS_FILE="$HOME/repos"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

pull_regular_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    
    cd "$repo_path" || return 1
    
    # Check if repo has uncommitted changes
    if ! git diff-index --quiet HEAD 2>/dev/null; then
        log_message "⚠️  $repo_name has uncommitted changes - skipping"
        return 2
    fi
    
    # Check if repo has unpushed commits
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$branch" ]; then
        log_message "⚠️  $repo_name: cannot determine current branch - skipping"
        return 3
    fi
    
    local upstream=$(git rev-parse --abbrev-ref "$branch@{upstream}" 2>/dev/null)
    if [ -z "$upstream" ]; then
        log_message "ℹ️  $repo_name: no upstream configured for $branch - skipping"
        return 0
    fi
    
    local unpushed=$(git log "$upstream".."$branch" --oneline 2>/dev/null | wc -l)
    
    if [ "$unpushed" -gt 0 ]; then
        log_message "⚠️  $repo_name has $unpushed unpushed commits on $branch - skipping"
        return 3
    fi
    
    # Fetch and check for updates
    git fetch --quiet 2>/dev/null
    local behind=$(git rev-list HEAD.."$upstream" --count 2>/dev/null)
    
    if [ "$behind" -gt 0 ]; then
        log_message "📥 Pulling $repo_name ($behind commits behind)"
        if git pull --quiet 2>/dev/null; then
            log_message "✅ Successfully updated $repo_name"
            return 0
        else
            log_message "❌ Failed to pull $repo_name"
            return 1
        fi
    else
        log_message "✓ $repo_name is up to date"
        return 0
    fi
}

pull_dotfiles() {
    log_message "🔧 Checking dotfiles (bare repo)"
    
    # Use the dotfiles alias
    local dotfiles_cmd="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
    
    # Check for uncommitted changes
    if ! $dotfiles_cmd diff-index --quiet HEAD 2>/dev/null; then
        log_message "⚠️  Dotfiles have uncommitted changes - skipping"
        return 2
    fi
    
    # Get current branch
    local branch=$($dotfiles_cmd rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -z "$branch" ]; then
        log_message "⚠️  Dotfiles: cannot determine current branch - skipping"
        return 3
    fi
    
    # Check for unpushed commits
    local unpushed=$($dotfiles_cmd log origin/"$branch".."$branch" --oneline 2>/dev/null | wc -l)
    if [ "$unpushed" -gt 0 ]; then
        log_message "⚠️  Dotfiles have $unpushed unpushed commits - skipping"
        return 3
    fi
    
    # Fetch and check for updates
    $dotfiles_cmd fetch --quiet 2>/dev/null
    local behind=$($dotfiles_cmd rev-list HEAD..origin/"$branch" --count 2>/dev/null)
    
    if [ "$behind" -gt 0 ]; then
        log_message "📥 Pulling dotfiles ($behind commits behind)"
        if $dotfiles_cmd pull --quiet 2>/dev/null; then
            log_message "✅ Successfully updated dotfiles"
            return 0
        else
            log_message "❌ Failed to pull dotfiles"
            return 1
        fi
    else
        log_message "✓ Dotfiles are up to date"
        return 0
    fi
}

process_path() {
    local path="$1"
    
    # Expand tilde to home directory
    path="${path/#\~/$HOME}"
    
    # Check if it's a directory
    if [ -d "$path" ]; then
        # Check if it's a git repo itself
        if [ -d "$path/.git" ]; then
            pull_regular_repo "$path"
        else
            # Scan for git repos inside the directory
            log_message "📂 Scanning directory: $path"
            while IFS= read -r repo; do
                if [ -d "$repo/.git" ]; then
                    pull_regular_repo "$repo"
                fi
            done < <(find "$path" -maxdepth 3 -type d -name ".git" 2>/dev/null | sed 's/\/.git$//' | sort)
        fi
    else
        log_message "⚠️  Path not found: $path"
    fi
}

main() {
    log_message "========== Starting Git Auto-Pull =========="
    
    # Check if repos file exists
    if [ ! -f "$REPOS_FILE" ]; then
        log_message "❌ Repository list file not found: $REPOS_FILE"
        log_message "Create this file and add repository paths (one per line)"
        exit 1
    fi
    
    local total_processed=0
    
    # Read repos file line by line (handles files without trailing newline)
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        line=$(echo "$line" | xargs)
        
        if [ "$line" = "dotfiles" ]; then
            # Special handling for dotfiles
            pull_dotfiles
            ((total_processed++))
        else
            # Process regular path
            process_path "$line"
            ((total_processed++))
        fi
    done < "$REPOS_FILE"
    
    log_message "========== Completed processing $total_processed entries =========="
}

# Run main function
main