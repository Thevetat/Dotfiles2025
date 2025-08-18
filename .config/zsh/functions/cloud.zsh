#*
## Name: sso
## Desc: AWS SSO login with optional remote cache sync
## Inputs: [optional] hostname to sync SSO cache to
## Usage: sso (local login only) or sso myserver (login and sync to remote)
sso() {
    if [ -z "$1" ]; then
        # No argument: just do normal SSO login
        command aws sso login --sso-session=theres-time-now
    else
        # Argument provided: SSO login then sync cache to remote server
        echo "🔐 Logging into AWS SSO..."
        command aws sso login --sso-session=theres-time-now
        
        if [ $? -eq 0 ]; then
            echo "📦 Syncing SSO cache to $1..."
            
            # Create the .aws/sso/cache directory on remote if it doesn't exist
            ssh "$1" "mkdir -p ~/.aws/sso/cache"
            
            if [ $? -ne 0 ]; then
                echo "❌ Failed to create directory on $1"
                return 1
            fi
            
            # Copy the SSO cache files to the remote server
            for cache_file in ~/.aws/sso/cache/*.json; do
                if [ -f "$cache_file" ]; then
                    scp "$cache_file" "$1":~/.aws/sso/cache/
                fi
            done
            
            if [ $? -eq 0 ]; then
                echo "✅ SSO cache synced to $1"
                
                # Also copy AWS config if it doesn't exist
                ssh "$1" "test -f ~/.aws/config"
                if [ $? -ne 0 ]; then
                    echo "📝 Copying AWS config to $1..."
                    scp ~/.aws/config "$1":~/.aws/
                fi
            else
                echo "❌ Failed to sync SSO cache to $1"
                return 1
            fi
        else
            echo "❌ SSO login failed"
            return 1
        fi
    fi
}
#*