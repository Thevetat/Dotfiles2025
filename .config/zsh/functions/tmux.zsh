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

# Create an editor, AI, and terminal development layout.
# Usage: tdl <ai-command> [second-ai-command]
tdl() {
    if (( $# < 1 || $# > 2 )); then
        echo "Usage: tdl <ai-command> [second-ai-command]"
        return 1
    fi
    if [[ -z "$TMUX" ]]; then
        echo "You must start tmux to use tdl."
        return 1
    fi

    local current_dir="$PWD"
    local editor_pane="$TMUX_PANE"
    local ai="$1"
    local ai2="${2:-}"
    local ai_pane

    tmux rename-window -t "$editor_pane" "${current_dir:t}"
    tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
    ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

    if [[ -n "$ai2" ]]; then
        local ai2_pane
        ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
        tmux send-keys -t "$ai2_pane" -l -- "$ai2"
        tmux send-keys -t "$ai2_pane" C-m
    fi

    tmux send-keys -t "$ai_pane" -l -- "$ai"
    tmux send-keys -t "$ai_pane" C-m
    tmux send-keys -t "$editor_pane" -l -- "${EDITOR:-nvim} ."
    tmux send-keys -t "$editor_pane" C-m
    tmux select-pane -t "$editor_pane"
}

# Create an editor, diff watcher, terminal, and OpenCode square layout.
# Usage: tds
tds() {
    if (( $# != 0 )); then
        echo "Usage: tds"
        return 1
    fi
    if [[ -z "$TMUX" ]]; then
        echo "You must start tmux to use tds."
        return 1
    fi

    local current_dir="$PWD"
    local editor_pane="$TMUX_PANE"
    local terminal_pane diff_pane opencode_pane

    tmux rename-window -t "$editor_pane" "${current_dir:t}"
    terminal_pane=$(tmux split-window -v -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
    diff_pane=$(tmux split-window -h -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
    opencode_pane=$(tmux split-window -h -p 50 -t "$terminal_pane" -c "$current_dir" -P -F '#{pane_id}')

    tmux send-keys -t "$editor_pane" -l -- "${EDITOR:-nvim} ."
    tmux send-keys -t "$editor_pane" C-m
    tmux send-keys -t "$diff_pane" -l -- "hunk diff --watch"
    tmux send-keys -t "$diff_pane" C-m
    tmux send-keys -t "$opencode_pane" -l -- "opencode"
    tmux send-keys -t "$opencode_pane" C-m
    tmux select-pane -t "$editor_pane"
}

# Create one tdl window for each immediate subdirectory.
# Usage: tdlm <ai-command> [second-ai-command]
tdlm() {
    if (( $# < 1 || $# > 2 )); then
        echo "Usage: tdlm <ai-command> [second-ai-command]"
        return 1
    fi
    if [[ -z "$TMUX" ]]; then
        echo "You must start tmux to use tdlm."
        return 1
    fi

    local ai="$1"
    local ai2="${2:-}"
    local base_dir="$PWD"
    local session_name="${base_dir:t}"
    local -a dirs
    dirs=("$base_dir"/*(/N))

    if (( ${#dirs} == 0 )); then
        echo "No subdirectories found in $base_dir"
        return 1
    fi

    tmux rename-session "${session_name//[.:]/-}"

    local first=1
    local dirpath pane_id command
    for dirpath in "${dirs[@]}"; do
        command="cd ${(q)dirpath} && tdl ${(q)ai}"
        [[ -n "$ai2" ]] && command+=" ${(q)ai2}"

        if (( first )); then
            pane_id="$TMUX_PANE"
            first=0
        else
            pane_id=$(tmux new-window -c "$dirpath" -P -F '#{pane_id}')
        fi

        tmux send-keys -t "$pane_id" -l -- "$command"
        tmux send-keys -t "$pane_id" C-m
    done
}

# Create a tiled layout and run the same command in every pane.
# Usage: tsl <pane-count> <command...>
tsl() {
    if (( $# < 2 )) || [[ "$1" != <-> ]] || (( $1 < 1 )); then
        echo "Usage: tsl <pane-count> <command...>"
        return 1
    fi
    if [[ -z "$TMUX" ]]; then
        echo "You must start tmux to use tsl."
        return 1
    fi

    local count="$1"
    shift
    local command="$*"
    local current_dir="$PWD"
    local new_pane
    local -a panes
    panes=("$TMUX_PANE")

    tmux rename-window -t "$TMUX_PANE" "${current_dir:t}"

    while (( ${#panes} < count )); do
        new_pane=$(tmux split-window -h -t "${panes[-1]}" -c "$current_dir" -P -F '#{pane_id}')
        panes+=("$new_pane")
        tmux select-layout -t "$TMUX_PANE" tiled
    done

    local pane
    for pane in "${panes[@]}"; do
        tmux send-keys -t "$pane" -l -- "$command"
        tmux send-keys -t "$pane" C-m
    done

    tmux select-pane -t "$TMUX_PANE"
}
