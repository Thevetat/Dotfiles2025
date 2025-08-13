# Git Auto-Pull

Automatically pulls git repositories to keep them synchronized across multiple machines.

## Overview

This tool periodically checks and pulls updates for configured git repositories. It's designed for developers working across multiple machines who want to keep their repos in sync automatically.

## Features

- Automatically pulls multiple git repositories
- Supports both regular repos and bare repos (like dotfiles)
- Skips repos with uncommitted changes or unpushed commits
- Runs every 5 minutes via systemd timer
- Detailed logging of all operations
- Can scan directories recursively for repos

## Installation

### 1. Script Setup

The script is already in place at `~/scripts/git-auto-pull/git-auto-pull.sh`

#### Quick Setup with Alias

If you have the dotfiles repo, the `gsync` alias is already available. To add it manually:

```bash
# Add alias to your shell config
echo "alias gsync='~/scripts/git-auto-pull/git-auto-pull.sh'" >> ~/.zshrc

# Or if using bash
echo "alias gsync='~/scripts/git-auto-pull/git-auto-pull.sh'" >> ~/.bashrc

# Reload your shell
source ~/.zshrc  # or source ~/.bashrc
```

Now you can run `gsync` anytime to manually sync your repos!

### 2. Configure Repositories

Edit `~/repos` to list the repositories you want to keep synchronized:

```bash
# Example ~/repos file
# One path per line, comments start with #

# Scan all repos in a directory
~/Git

# Individual repo
~/ai-tools

# Bare repo (dotfiles)
dotfiles
```

### 3. SystemD Service Setup

Create the systemd service file at `~/.config/systemd/user/git-auto-pull.service`:

```ini
[Unit]
Description=Git Auto-Pull Service
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/thevetat/scripts/git-auto-pull/git-auto-pull.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### 4. SystemD Timer Setup

Create the timer file at `~/.config/systemd/user/git-auto-pull.timer`:

```ini
[Unit]
Description=Git Auto-Pull Timer (every 5 minutes)
Requires=git-auto-pull.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

### 5. Enable and Start

#### Linux (systemd)

```bash
# Reload systemd configuration
systemctl --user daemon-reload

# Enable the timer to start on boot
systemctl --user enable git-auto-pull.timer

# Start the timer now
systemctl --user start git-auto-pull.timer
```

#### macOS (launchd)

For automatic scheduling on macOS, create a LaunchAgent at `~/Library/LaunchAgents/com.user.git-auto-pull.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.git-auto-pull</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>$HOME/scripts/git-auto-pull/git-auto-pull.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer> <!-- 300 seconds = 5 minutes -->
    <key>StandardOutPath</key>
    <string>/tmp/git-auto-pull.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/git-auto-pull.error.log</string>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

Then load it:

```bash
# Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.user.git-auto-pull.plist

# Start it immediately
launchctl start com.user.git-auto-pull

# Check status
launchctl list | grep git-auto-pull
```

#### Alternative: Use cron (Both Linux and macOS)

Add to your crontab for a simple cross-platform solution:

```bash
# Edit crontab
crontab -e

# Add this line for every 5 minutes
*/5 * * * * ~/scripts/git-auto-pull/git-auto-pull.sh >> ~/.local/share/git-auto-pull.log 2>&1
```

## Usage

### Manual Run

```bash
# Run using the alias (if configured)
gsync

# Or run the script directly
~/scripts/git-auto-pull/git-auto-pull.sh

# Or trigger via systemd (Linux only)
systemctl --user start git-auto-pull.service
```

### Check Status

#### Linux (systemd)

```bash
# Check timer status
systemctl --user status git-auto-pull.timer

# Check last service run
systemctl --user status git-auto-pull.service

# List timer schedule
systemctl --user list-timers git-auto-pull.timer
```

#### macOS (launchd)

```bash
# Check if running
launchctl list | grep git-auto-pull

# View recent logs
tail -f /tmp/git-auto-pull.log
tail -f /tmp/git-auto-pull.error.log
```

### View Logs

```bash
# View script log file (all platforms)
tail -f ~/.local/share/git-auto-pull.log

# Linux: View systemd logs
journalctl --user -u git-auto-pull.service -f

# macOS: View launchd logs
tail -f /tmp/git-auto-pull.log
```

### Managing the Service

#### Linux (systemd)

```bash
# Stop auto-pulling
systemctl --user stop git-auto-pull.timer

# Disable auto-pulling on boot
systemctl --user disable git-auto-pull.timer

# Restart after configuration changes
systemctl --user restart git-auto-pull.timer
```

#### macOS (launchd)

```bash
# Stop the service
launchctl stop com.user.git-auto-pull

# Unload (disable) the service
launchctl unload ~/Library/LaunchAgents/com.user.git-auto-pull.plist

# Reload after changes
launchctl unload ~/Library/LaunchAgents/com.user.git-auto-pull.plist
launchctl load ~/Library/LaunchAgents/com.user.git-auto-pull.plist
```

## Configuration

### Adding/Removing Repositories

Simply edit `~/repos` and add or remove paths. The changes will take effect on the next run.

### Changing Timer Interval

Edit `~/.config/systemd/user/git-auto-pull.timer` and modify the `OnUnitActiveSec` value:
- `5min` - Every 5 minutes (current)
- `15min` - Every 15 minutes
- `1h` - Every hour
- `6h` - Every 6 hours

After changing, reload and restart:
```bash
systemctl --user daemon-reload
systemctl --user restart git-auto-pull.timer
```

## How It Works

1. Reads repository paths from `~/repos`
2. For each path:
   - If it's a directory, scans for git repos (up to 3 levels deep)
   - If it's "dotfiles", uses the special bare repo alias
   - If it's a git repo, attempts to pull
3. Before pulling, checks:
   - No uncommitted changes
   - No unpushed commits
   - Actually behind remote
4. Logs all operations to `~/.local/share/git-auto-pull.log`

## Troubleshooting

### Service Not Running

```bash
# Check if timer is active
systemctl --user is-active git-auto-pull.timer

# Check for errors
journalctl --user -u git-auto-pull.service -e
```

### Repos Not Updating

Check the log file for warnings:
```bash
grep "⚠️" ~/.local/share/git-auto-pull.log
```

Common issues:
- Uncommitted changes in repo
- Unpushed commits
- No upstream configured for branch
- Authentication issues (for private repos)

### Authentication for Private Repos

For private repos, ensure you have:
- SSH keys configured for password-less access
- Or use credential helpers for HTTPS repos

## Log Icons

- 📂 Scanning directory
- 📥 Pulling updates
- ✅ Successfully updated
- ✓ Already up to date
- ⚠️ Skipped (with reason)
- ❌ Failed operation
- 🔧 Dotfiles operation
- ℹ️ Information