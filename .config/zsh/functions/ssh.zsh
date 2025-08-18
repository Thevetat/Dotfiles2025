#*
## Name: ssh-kill
## Desc: Kill SSH master connection and optionally kill processes on a port
## Inputs: hostname - The SSH host to kill the connection for
##         port (optional) - Kill all processes using this port
## Usage: ssh-kill freefall
##        ssh-kill freefall 1337
ssh-kill() {
    if [ -z "$1" ]; then
        echo "Usage: ssh-kill <hostname> [port]"
        return 1
    fi
    
    local hostname="$1"
    local port="$2"
    
    # If port is specified, kill all processes using that port
    if [ -n "$port" ]; then
        echo "🔍 Killing processes using port $port..."
        # Find and kill processes listening on the specified port
        local pids=$(lsof -iTCP:$port -sTCP:LISTEN -t 2>/dev/null)
        if [ -n "$pids" ]; then
            echo "$pids" | xargs kill -9 2>/dev/null
            echo "✅ Killed processes on port $port"
        else
            echo "⚠️  No processes found on port $port"
        fi
    fi
    
    # Try to exit the master connection gracefully
    ssh -O exit "$hostname" 2>/dev/null && echo "✅ Killed SSH master for $hostname" || echo "⚠️  No active master for $hostname"
    
    # Remove any stale control sockets for this host
    local socket_pattern=$(echo "$hostname" | sed 's/[^a-zA-Z0-9]/_/g')
    rm -f ~/.ssh/cm/*"$socket_pattern"* 2>/dev/null
    rm -f ~/.ssh/cm/*$(ssh -G "$hostname" 2>/dev/null | grep "^controlpath" | cut -d' ' -f2 | xargs basename 2>/dev/null)* 2>/dev/null
}
#*

#*
## Name: ssh-reconnect
## Desc: Kill SSH master connection and immediately reconnect
## Inputs: hostname - The SSH host to reconnect to
## Usage: ssh-reconnect freefall
ssh-reconnect() {
    if [ -z "$1" ]; then
        echo "Usage: ssh-reconnect <hostname>"
        return 1
    fi
    
    ssh-kill "$1"
    echo "🔄 Reconnecting to $1..."
    ssh "$1"
}
#*

#*
## Name: ssh-forward
## Desc: Ensure SSH port forwarding is active for a host
## Inputs: hostname - The SSH host to establish forwarding for
## Usage: ssh-forward freefall
ssh-forward() {
    if [ -z "$1" ]; then
        echo "Usage: ssh-forward <hostname>"
        return 1
    fi
    
    # Check if master exists
    if ssh -O check "$1" 2>/dev/null; then
        echo "⚠️  Master exists for $1, killing and reconnecting with forwarding..."
        ssh-kill "$1"
    fi
    
    # Start fresh connection with forwarding in background
    ssh -N -f "$1"
    echo "✅ Port forwarding established for $1"
}
#*