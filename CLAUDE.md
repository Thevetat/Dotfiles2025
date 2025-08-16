# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is my home. Use the `~/tasks/` directory as a workspace for completing tasks or as a scratchpad for any work requested.

## Preferred Commands

Use rg instead of grep for searching files. It is faster and more reliable with more options.

## Dotfiles Management

This system uses a bare git repository for dotfiles management. Key commands:

- `dotfiles` - Git alias for managing dotfiles (equivalent to `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`)
- `dotfiles status` - Check status of tracked dotfiles
- `dotfiles add <file>` - Stage dotfiles for commit
- `dotfiles commit -m "message"` - Commit dotfiles changes
- `dotfiles push` - Push to remote repository
- `dfs` - Alias for `dotfiles status`
- `dfca` - Function for adding, committing, and pushing dotfiles in one command

The dotfiles repository tracks configuration files like:

- `.zshrc`, `.zsh_functions`, `.aliases` - Shell configuration
- `.config/` - Application configurations
- Other dotfiles in the home directory

When making changes to shell configurations or dotfiles, always commit them using the dotfiles commands.
