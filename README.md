# Dotfiles 2025

A bare Git repository for managing dotfiles across different machines.

## What is this?

This repository uses the "Git Bare Repository" method for tracking dotfiles. Unlike a regular dotfiles repository, this approach doesn't require symlinks or copying files. It allows you to directly track files in your home directory while keeping the Git metadata separate.

## Files Tracked

- Shell configuration (`.aliases`, `.zsh_functions`)
- ZPrezto configurations (`.zprezto/runcoms/*`)
- Window manager configs (Yabai, SKHD)
- Terminal and editor settings
- Various other dotfiles and configurations

## Setup on a New Machine

### Initial Setup

```bash
# Clone the bare repository
git clone --bare https://github.com/Thevetat/Dotfiles2025.git $HOME/.dotfiles

# Create an alias for easier management
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Add the alias to your shell config
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc
echo "alias dfs='dotfiles status'" >> $HOME/.zshrc

# Hide untracked files
dotfiles config --local status.showUntrackedFiles no

# Checkout the actual files
dotfiles checkout
```

> ⚠️ **Warning**: If you already have some of these configuration files, the checkout might fail. Back up any existing files before proceeding or use the method below.

### Handling Existing Files

If you have existing configuration files that would be overwritten, you'll see an error. Here's how to handle it:

```bash
# Save existing dotfiles to a backup directory
mkdir -p .dotfiles-backup
dotfiles checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}

# Now checkout should work
dotfiles checkout
```

## Usage

Once set up, you can manage your dotfiles like a normal Git repository:

```bash
# See status of your dotfiles
dotfiles status
# or using the shorthand
dfs

# Add a file to be tracked
dotfiles add .vimrc

# Commit changes
dotfiles commit -m "Add vimrc"

# Push to remote
dotfiles push

# Pull from remote
dotfiles pull
```

## Adding New Dotfiles

To add a new configuration file to be tracked:

```bash
dotfiles add /path/to/your/dotfile
dotfiles commit -m "Add new dotfile"
dotfiles push
```

## Handling Symlinks

Some dotfiles may be symlinks (especially with ZPrezto). Git should track them correctly, but if you have issues, you might need to track both the symlink and its target.

## Tips and Tricks

### Showing All Untracked Files

If you need to see all untracked files in your home directory:

```bash
dotfiles status -u
```

### Viewing Tracked Files

To list all files being tracked:

```bash
dotfiles ls-files
```

### Creating a Fresh Repository

If you need to start over:

```bash
# Remove existing repository
rm -rf $HOME/.dotfiles

# Initialize a new one
git init --bare $HOME/.dotfiles
dotfiles config --local status.showUntrackedFiles no
```

## Troubleshooting

### File Not Being Tracked

If a file isn't being tracked properly:

```bash
# Try adding with force
dotfiles add -f /path/to/file

# Check if it's being ignored
dotfiles check-ignore -v /path/to/file
```

### Conflict on Checkout

If you get conflicts when checking out:

```bash
# Back up the file
mv /path/to/file /path/to/file.backup

# Then checkout
dotfiles checkout -- /path/to/file
```

## License

This dotfiles repository is for personal use but feel free to fork and adapt for your own needs.
