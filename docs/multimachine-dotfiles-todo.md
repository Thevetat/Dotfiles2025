# Multimachine Dotfiles Todo

## Safety Floor

- [x] Explicitly ignore local private files: `.env`, `.env.*`, `repos`, `.password-store/`, `.gnupg/`, `.cache/pass-secrets/`, and private SSH material.
- [x] Set each machine's local dotfiles repo to fast-forward-only pulls.
- [x] Update dotfiles helper commands to fetch first and refuse divergent histories.
- [x] Update `git-auto-pull` to fetch before ahead/behind checks and use `pull --ff-only`.
- [x] Keep agents from using `dotfiles add -A` or `dotfiles add .`.

## Startup Split

- [x] Keep `.zshenv` minimal: environment/path only, no aliases, no `.env`, no interactive shell setup.
- [x] Keep `.zprofile` for login-shell setup only.
- [x] Keep `.zshrc` / Prezto runcoms for interactive shell behavior.
- [x] Add explicit OS loaders for Darwin and Linux.
- [x] Add explicit host loaders for Air, Aether, and this machine.
- [x] Move private local overrides into ignored `~/.config/zsh/local/*.zsh`.

## Shared Shell Layer

- [x] Keep portable aliases/functions in shared tracked files.
- [x] Split `.aliases` into shared, OS-specific, host-specific, and local/private pieces.
- [x] Split NVM/rbenv/conda startup by OS and interaction mode.
- [x] Remove duplicate Codex wrapper definitions and keep one source of truth.
- [x] Decide whether `pass.zsh` and `project-env.zsh` stay public as generic tooling or move private/local.

## Public/Private Boundary

- [x] Keep real `.env`, `repos`, `.ssh`, `.password-store`, `.gnupg`, and pass caches local-only.
- [x] Keep `.env.example` and `repos.example` public placeholders only.
- [x] Move sensitive project paths, client targets, and private repo shortcuts out of public tracked files.
- [x] Review `docs/pass-workflow.md` for public-safe wording around temporary private key backups.
- [x] Move agent operating rules and private workflow docs to private `~/ai-tools`.

## macOS And GUI Layer

- [x] Split `.config/Brewfile` into shared CLI, macOS GUI, and host services.
- [ ] Move Deskflow LaunchAgents to local/private host setup.
- [ ] Move Karabiner device-specific config to host-specific or local/private setup.
- [x] Keep SketchyBar source scripts only where useful; untrack compiled helper binary.
- [x] Untrack stale backup files such as `.config/skhd/skhdrc.bak`.
- [ ] Decide whether yabai/skhd are shared macOS config or host-specific workstation config.

## Agent Skill

- [x] Create a private dotfiles skill in `~/ai-tools`.
- [x] Symlink/install that skill into Codex's skill path.
- [x] Include hard rules: inspect status first, pull fast-forward-only, never stage private files, commit/push dotfiles changes immediately.
- [x] Document machine roles and which files are public, host-specific, local-only, or private.
