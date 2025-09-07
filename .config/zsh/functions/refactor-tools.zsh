loc-check() {
    # Inline ignore list - add patterns here to exclude specific files/dirs
    local -a ignore_patterns=(
        "*.test.ts"
        "*.test.tsx"
        "*.spec.ts"
        "*.spec.tsx"
        "*.stories.tsx"
        "*.stories.ts"
        "*.d.ts"
        "routeTree.gen.ts"
        "**/node_modules/**"
        "**/dist/**"
        "**/build/**"
        "**/coverage/**"
        ".next/**"
        "public/**"
    )
    
    # Build ignore args for rg
    local ignore_args=""
    for pattern in "${ignore_patterns[@]}"; do
        ignore_args="$ignore_args -g '!$pattern'"
    done
    
    # Detect clipboard command based on OS
    local clip_cmd
    if [[ "$OSTYPE" == "darwin"* ]]; then
        clip_cmd="pbcopy"
    elif command -v xclip >/dev/null 2>&1; then
        clip_cmd="xclip -selection clipboard"
    elif command -v xsel >/dev/null 2>&1; then
        clip_cmd="xsel --clipboard --input"
    else
        echo "⚠️  Warning: No clipboard command found (pbcopy/xclip/xsel)"
        clip_cmd="cat > /dev/null"  # Fallback that does nothing
    fi
    
    echo "🔍 Finding TypeScript/TSX files with >300 lines..."
    echo ""
    
    # Use eval to properly expand the ignore args
    local files_data=$(eval "rg --files --type-add 'tsx:*.tsx' --type-add 'ts:*.ts' -t ts -t tsx $ignore_args" | while read -r file; do
        local lines=$(wc -l < "$file" 2>/dev/null || echo 0)
        if [[ $lines -gt 300 ]]; then
            echo "$file:$lines"
        fi
    done | sort -t: -k2 -rn)
    
    if [[ -z "$files_data" ]]; then
        echo "✅ No files found with >300 lines!"
        return 0
    fi
    
    # Group by directory and format output
    local output=""
    local current_dir=""
    local file_count=0
    
    while IFS= read -r line; do
        local file="${line%:*}"
        local lines="${line##*:}"
        local dir=$(dirname "$file")
        
        if [[ "$dir" != "$current_dir" ]]; then
            if [[ -n "$current_dir" ]]; then
                output+="\n"
            fi
            output+="📁 $dir/\n"
            current_dir="$dir"
        fi
        
        output+="  $(basename "$file"):$lines\n"
        ((file_count++))
    done <<< "$files_data"
    
    # Print to terminal
    echo -e "$output"
    echo ""
    echo "📊 Total files over 300 lines: $file_count"
    
    # Copy raw file list to clipboard
    echo "$files_data" | eval "$clip_cmd"
    echo "📋 File list copied to clipboard!"
}

# Alias for convenience
alias locc="loc-check"
alias loccheck="loc-check"