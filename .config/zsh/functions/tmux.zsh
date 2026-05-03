tm(){
    if [ -n "$1" ]; then
        TERM=tmux-256color tmux -u attach -t "$1" 2>/dev/null || TERM=tmux-256color tmux -u new -s "$1"
    else
        TERM=tmux-256color tmux -u attach || TERM=tmux-256color tmux -u new -s main
    fi
}

#*
## Name: tswap
## Desc: Create new tmux session and switch to it from within current session
## Inputs: session_name
## Usage: tswap newsession
tswap() {
    if [ -z "$1" ]; then
        echo "Usage: tswap <session_name>"
        return 1
    fi
    
    tmux new-session -d -s "$1" \; switch-client -t "$1"
}
#*

#*
## Name: tmrn
## Desc: Rename current tmux session
## Inputs: new_name - The new name for the current tmux session
## Usage: tmrn mynewname
tmrn() {
    if [ -z "$1" ]; then
        echo "Usage: tmrn <new_name>"
        return 1
    fi
    
    # Check if we're in a tmux session
    if [ -z "$TMUX" ]; then
        echo "Error: Not in a tmux session"
        return 1
    fi
    
    tmux rename-session "$1"
    echo "Session renamed to: $1"
}
#*

#*
## Name: tk
## Desc: Kill tmux session and remove it from resurrect saved state
## Inputs: session_name - The name of the tmux session to kill permanently
## Usage: tk main
tmuxkill() {
    if [ -z "$1" ]; then
        echo "Usage: tk <session_name>"
        return 1
    fi
    
    # Kill the session
    tmux kill-session -t "$1" 2>/dev/null && echo "✅ Killed session: $1" || echo "⚠️ Session not found: $1"
    
    # Remove from tmux-resurrect saved state
    local resurrect_dir="$HOME/.local/share/tmux/resurrect"
    if [ -d "$resurrect_dir" ]; then
        # Remove session from the last saved state
        local last_file=$(ls -t "$resurrect_dir"/tmux_resurrect_*.txt 2>/dev/null | head -1)
        if [ -f "$last_file" ]; then
            # Create backup
            cp "$last_file" "${last_file}.bak"
            # Remove lines related to this session
            grep -v "^pane[[:space:]]$1" "$last_file" | \
            grep -v "^window[[:space:]]$1" | \
            grep -v "^state[[:space:]]$1" > "${last_file}.tmp"
            mv "${last_file}.tmp" "$last_file"
            echo "✅ Removed $1 from resurrect saved state"
        fi
    fi
}
#*

