dfca() {
    dotfiles add -u && dotfiles commit -m "$*" && dotfiles push 
}

dfmod() {
  if [ $# -lt 1 ]; then
    echo "Usage: dfmod \"Your commit message\""
    return 1
  fi
  
  message="$1"
  
  # Get list of modified files from git status
  modified_files=$(dotfiles status --porcelain | grep '^ M' | cut -c4-)
  
  if [ -z "$modified_files" ]; then
    echo "No modified files found."
    return 1
  fi
  
  # Add all modified files
  echo "$modified_files" | while read -r file; do
    dotfiles add "$file"
  done
  
  dotfiles commit -m "$message"
  dotfiles push
  echo "Modified files committed and pushed to remote."
}

#*
## Name: dfs
## Desc: Show dotfiles status for tracked files only
## Inputs: None
## Usage: dfs
dfs() {
    echo "🔍 Dotfiles Status"
    echo "==================="
    
    # Show status of tracked files only
    local status_output=$(dotfiles status --short 2>/dev/null)
    
    if [[ -z "$status_output" ]]; then
        echo "✅ All tracked dotfiles are up to date!"
    else
        echo -e "\n📋 Changed files:"
        echo "$status_output"
        
        # Count changes
        local modified_count=$(echo "$status_output" | grep -c '^ M' || true)
        local staged_count=$(echo "$status_output" | grep -c '^M' || true)
        local untracked_count=$(echo "$status_output" | grep -c '^??' || true)
        
        echo -e "\n📊 Summary:"
        [[ $modified_count -gt 0 ]] && echo "  • Modified: $modified_count files"
        [[ $staged_count -gt 0 ]] && echo "  • Staged: $staged_count files"
        [[ $untracked_count -gt 0 ]] && echo "  • Untracked: $untracked_count files"
    fi
    
    # Show last commit info
    echo -e "\n📝 Last commit:"
    dotfiles log -1 --oneline
}
#*