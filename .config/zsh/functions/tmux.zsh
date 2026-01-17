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

#*
## Name: start-rolling
## Desc: Start Rolling Bones development environment with Rails server and Vite in tmux session
## Inputs: None
## Usage: start-rolling
start-rolling() {
    # Change to the Rails directory
    builtin cd ~/Git/RollingBones/rolling_bones_rails || {
        echo "❌ Cannot find Rolling Bones Rails directory"
        return 1
    }
    
    # Check if we're already in a tmux session
    if [ -n "$TMUX" ]; then
        # Get current session name
        current_session=$(tmux display-message -p '#S')
        
        # Inside tmux - check if 'main' session exists
        if tmux has-session -t main 2>/dev/null; then
            if [ "$current_session" = "main" ]; then
                echo "✅ Already in 'main' session!"
                
                # Check if both panes exist and have the right processes
                pane_count=$(tmux list-panes | wc -l | tr -d ' ')
                if [ "$pane_count" -lt 2 ]; then
                    echo "🔧 Setting up Rails server and Vite in split panes..."
                    
                    # Kill anything on port 3000 first and start Rails server in current pane
                    tmux send-keys 'lsof -ti:3000 | xargs kill -9 2>/dev/null || true' C-m
                    sleep 0.5
                    tmux send-keys 'bundle exec rails s' C-m
                    
                    # Split and start Vite
                    tmux split-window -h -c ~/Git/RollingBones/rolling_bones_rails 'bin/vite dev'
                    
                    # Return focus to first pane
                    tmux select-pane -L
                else
                    echo "📍 Both panes already exist. Use them to start Rails and Vite manually if needed."
                fi
            else
                echo "🔄 Switching to existing 'main' session..."
                tmux switch-client -t main
            fi
        else
            echo "🚀 Creating new 'main' session and switching to it..."
            
            # Kill anything on port 3000 first
            lsof -ti:3000 | xargs kill -9 2>/dev/null || true
            
            # Create new session in background with Rails server
            tmux new-session -d -s main -c ~/Git/RollingBones/rolling_bones_rails 'bundle exec rails s'
            
            # Split vertically and start Vite
            tmux split-window -h -t main -c ~/Git/RollingBones/rolling_bones_rails 'bin/vite dev'
            
            # Return focus to first pane
            tmux select-pane -t main:1.0
            
            # Switch to the new session
            tmux switch-client -t main
        fi
    else
        # Not in tmux - attach or create normally
        if tmux has-session -t main 2>/dev/null; then
            echo "🔗 Attaching to existing 'main' tmux session..."
            tmux attach-session -t main
        else
            echo "🚀 Creating new 'main' tmux session with Rails server and Vite..."
            
            # Kill anything on port 3000 first
            lsof -ti:3000 | xargs kill -9 2>/dev/null || true
            
            # Create new tmux session with Rails server
            tmux new-session -d -s main -c ~/Git/RollingBones/rolling_bones_rails 'bundle exec rails s'
            
            # Split vertically and start Vite
            tmux split-window -h -t main -c ~/Git/RollingBones/rolling_bones_rails 'bin/vite dev'
            
            # Return focus to first pane
            tmux select-pane -t main:1.0
            
            # Attach to the session
            tmux attach-session -t main
        fi
    fi
}
#*
