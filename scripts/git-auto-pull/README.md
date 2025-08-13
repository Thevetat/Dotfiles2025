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

```bash
# Reload systemd configuration
systemctl --user daemon-reload

# Enable the timer to start on boot
systemctl --user enable git-auto-pull.timer

# Start the timer now
systemctl --user start git-auto-pull.timer
```

## Usage

### Check Status

```bash
# Check timer status
systemctl --user status git-auto-pull.timer

# Check last service run
systemctl --user status git-auto-pull.service

# List timer schedule
systemctl --user list-timers git-auto-pull.timer
```

### View Logs

```bash
# View systemd logs
journalctl --user -u git-auto-pull.service -f

# View script log file
tail -f ~/.local/share/git-auto-pull.log
```

### Manual Run

```bash
# Run the script manually
~/scripts/git-auto-pull/git-auto-pull.sh

# Or trigger via systemd
systemctl --user start git-auto-pull.service
```

### Managing the Service

```bash
# Stop auto-pulling
systemctl --user stop git-auto-pull.timer

# Disable auto-pulling on boot
systemctl --user disable git-auto-pull.timer

# Restart after configuration changes
systemctl --user restart git-auto-pull.timer
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