#*
## Name: start-play-mcp
## Desc: Start Playwright MCP server with HTTP transport on port 8931
## Usage: start-play-mcp
start-play-mcp() {
    local port=8931
    local mcp_command="bunx @playwright/mcp@latest --extension --port $port"
    
    # Check if something is already listening on the port
    if lsof -i :$port > /dev/null 2>&1; then
        # Check if it's our MCP server
        if ps aux | grep -q "[p]laywright/mcp.*--port $port"; then
            echo "✅ Playwright MCP server is already running on port $port"
            echo "   URL: http://localhost:$port/mcp"
            return 0
        else
            echo "⚠️  Port $port is in use by another process. Killing it..."
            # Kill whatever is using the port
            lsof -ti :$port | xargs kill -9 2>/dev/null
            sleep 1
        fi
    fi
    
    echo "🚀 Starting Playwright MCP server on port $port..."
    echo "   Command: $mcp_command"
    
    # Start the server in background
    eval "$mcp_command" > /tmp/playwright-mcp.log 2>&1 &
    local pid=$!
    
    # Wait a moment for server to start
    sleep 3
    
    # Verify it started successfully
    if lsof -i :$port > /dev/null 2>&1; then
        echo "✅ Playwright MCP server started successfully!"
        echo "   PID: $pid"
        echo "   URL: http://localhost:$port/mcp"
        echo ""
        echo "📝 Add this to your Claude config:"
        echo '   {
     "mcpServers": {
       "playwright": {
         "url": "http://localhost:'$port'/mcp"
       }
     }
   }'
    else
        echo "❌ Failed to start Playwright MCP server"
        echo "   Check /tmp/playwright-mcp.log for details"
        return 1
    fi
}
#*

#*
## Name: mcp-add
## Desc: Add MCP server from JSON configuration commonly found on GitHub
## Inputs: name - MCP server name
##         command - The command to run (e.g., "npx")
##         args - The arguments array (can be pasted directly from JSON)
## Usage: mcp-add playwright-extension npx '["@playwright/mcp@latest", "--extension"]'
##        mcp-add playwright-extension npx "@playwright/mcp@latest --extension"
mcp-add() {
    if [ $# -lt 3 ]; then
        echo "Usage: mcp-add <name> <command> <args>"
        echo ""
        echo "Examples:"
        echo '  mcp-add playwright-extension npx ["@playwright/mcp@latest", "--extension"]'
        echo '  mcp-add my-server node ["/path/to/server.js", "--flag"]'
        echo '  mcp-add simple-server npx "@simple/mcp@latest --verbose"'
        echo ""
        echo "You can paste the args array directly from GitHub JSON!"
        return 1
    fi
    
    local name="$1"
    local command="$2"
    shift 2
    local args_input="$*"
    
    # Check if args_input looks like a JSON array
    if [[ "$args_input" =~ ^\[.*\]$ ]]; then
        # Parse JSON array: remove brackets, quotes, commas, and extra whitespace
        local args=$(echo "$args_input" | \
            sed 's/^\[//; s/\]$//; s/,/ /g' | \
            sed 's/"//g' | \
            sed "s/'//g" | \
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
            sed 's/[[:space:]]\+/ /g')
    else
        # Use as-is if not JSON array format
        local args="$args_input"
    fi
    
    echo "🔧 Adding MCP server: $name"
    echo "   Command: $command"
    echo "   Args: $args"
    echo ""
    
    # Build the claude mcp add command
    # All GitHub JSON configs use stdio transport by default
    local full_command="claude mcp add $name -- $command $args"
    
    echo "📝 Running: $full_command"
    eval "$full_command"
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully added MCP server: $name"
        echo ""
        echo "📌 Note: Most MCP servers from GitHub use stdio transport (default)"
        echo "   If you need SSE transport, use: claude mcp add-sse"
    else
        echo "❌ Failed to add MCP server"
        return 1
    fi
}
#*