# SETUP

Agent-readable runbook for bootstrapping a fresh machine. Linear, phase-ordered,
idempotent where possible. Stop markers (🛑) flag steps only a human can do.

> **For the agent reading this:** detect OS once, then run phases 0 → 11 in
> order. If a phase fails, stop and ask the user. If a `[mac]` / `[ubuntu]` /
> `[arch]` block does not match the host, skip it.

---

## OS detection

```sh
case "$(uname -s)" in
  Darwin) export OS=mac ;;
  Linux)
    if [ -f /etc/arch-release ]; then export OS=arch
    elif grep -qi ubuntu /etc/os-release 2>/dev/null; then export OS=ubuntu
    else export OS=linux-other
    fi ;;
esac
echo "Detected OS: $OS"
```

---

## Phase 0 — Prerequisites

`[mac]`
```sh
xcode-select --install || true   # noop if already installed
```

`[ubuntu]`
```sh
sudo apt update
sudo apt install -y build-essential curl git zsh unzip
```

`[arch]`
```sh
sudo pacman -Syu --needed --noconfirm base-devel curl git zsh unzip
```

---

## Phase 1 — Dotfiles (bare-git repo)

🛑 **STOP** — Ask user for the dotfiles repo URL if not already provided.
Variable below: `$DOTFILES_REPO`.

```sh
: "${DOTFILES_REPO:?Set DOTFILES_REPO to the user's dotfiles git URL}"

git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Backup any conflicting files, then check out
mkdir -p "$HOME/.dotfiles-backup"
dotfiles checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | while read -r f; do
  mkdir -p "$HOME/.dotfiles-backup/$(dirname "$f")"
  mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
done
dotfiles checkout
dotfiles config status.showUntrackedFiles no
```

After this, `~/.config/`, `~/.zshrc`, `~/.aliases`, etc. are populated.

---

## Phase 2 — Package manager

`[mac]` Homebrew:
```sh
[ ! -d /opt/homebrew ] && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

`[ubuntu]` apt + Linuxbrew (for tools apt lacks):
```sh
sudo apt install -y $(grep -v '^#' ~/.config/packages/ubuntu.txt | xargs)
[ ! -d /home/linuxbrew/.linuxbrew ] && \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

`[arch]` pacman + AUR helper:
```sh
sudo pacman -S --needed --noconfirm $(grep -v '^#' ~/.config/packages/arch.txt | xargs)

# Install yay (AUR helper) if absent
if ! command -v yay >/dev/null 2>&1; then
  (cd /tmp && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm)
fi
yay -S --needed --noconfirm $(grep -v '^#' ~/.config/packages/aur.txt | xargs)
```

---

## Phase 3 — Bundle install

`[mac]`
```sh
brew bundle install --file=~/.config/Brewfile
```

`[linux]` Brewfile is mac-only. Linux installs the CLI subset via Linuxbrew:
```sh
brew bundle install --file=~/.config/Brewfile.linux
```

---

## Phase 4 — Runtimes via mise

`mise` replaces `nvm`, `rbenv`, `pyenv`. Reads `~/.config/mise/config.toml`
(versioned in dotfiles).

```sh
mise trust ~/.config/mise/config.toml
mise install
```

Verify:
```sh
mise current
node --version && ruby --version && python --version && go version
```

---

## Phase 5 — Shell

```sh
# Default shell
chsh -s "$(command -v zsh)"

# zprezto
[ ! -d ~/.zprezto ] && \
  git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto

# tmux plugin manager
[ ! -d ~/.tmux/plugins/tpm ] && \
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

🛑 **STOP** — User must restart the shell (or open a new terminal) before
continuing. Inside tmux later: `prefix + I` to install tmux plugins via TPM.

---

## Phase 6 — Services

`[mac]`
```sh
brew services start postgresql@14
brew services start postgresql@17
brew services start redis
brew services start mongodb-community
brew services start tailscale
```

`[linux]`
```sh
sudo systemctl enable --now postgresql redis-server mongod tailscaled
```

> Note: postgres@14 and postgres@17 are pinned to specific projects;
> both must run.

---

## Phase 7 — macOS window manager (mac only)

Configs already on disk via dotfiles checkout (`~/.config/yabai`,
`~/.config/skhd`, `~/.config/sketchybar`, `~/.config/karabiner`).

```sh
brew services start yabai
brew services start skhd-zig
brew services start sketchybar
```

🛑 **STOP** — User must do these manually (one-time):
1. **Accessibility permissions:** System Settings → Privacy & Security →
   Accessibility → enable yabai, skhd, karabiner_grabber, karabiner_console_user_server.
2. **Karabiner:** open Karabiner-Elements once so it picks up
   `~/.config/karabiner/karabiner.json`.
3. **Raycast:** open, sign in, import settings if backed up.
4. **Optional — disable SIP** for full yabai features. See yabai wiki.

---

## Phase 8 — Linux window manager: Hyprland (arch only)

`[arch]`
```sh
sudo pacman -S --needed --noconfirm hyprland waybar hyprlock rofi-wayland \
  xdg-desktop-portal-hyprland qt5-wayland qt6-wayland polkit-kde-agent \
  pipewire wireplumber brightnessctl playerctl grim slurp wl-clipboard
```

Configs (stubs to flesh out): `~/.config/hypr/`, `~/.config/waybar/`,
`~/.config/hyprlock/`, `~/.config/rofi/`.

`[ubuntu]` Hyprland on Ubuntu requires PPAs or source build. Recommend Arch
for Hyprland. Skip this phase on Ubuntu.

🛑 **STOP** — Hyprland configs are not yet authored. User must flesh out
before relying on this phase.

---

## Phase 9 — App-specific first-launch

| App        | Action                                                                |
|------------|-----------------------------------------------------------------------|
| nvim       | First launch auto-installs LazyVim plugins. `:Lazy sync` to verify.   |
| tmux       | Inside tmux: `<prefix>I` (capital i) to install plugins via TPM.      |
| yazi       | Already configured. Run `y` from shell.                               |
| ghostty    | Auto-loads `~/.config/ghostty/config`. Open once.                     |
| raycast    | Open, grant permissions, sign in.                                     |
| karabiner  | Open once after permissions granted (see Phase 7).                    |
| 1Password  | Install via DMG (not in Brewfile — get from 1password.com), sign in. |

---

## Phase 10 — Secrets transfer (HUMAN ONLY — never script, never commit)

🛑 **STOP** — Walk user through transferring each row from old machine.
**These must NEVER be committed to dotfiles.**

| Path                                      | What                  | How                                              |
|-------------------------------------------|-----------------------|--------------------------------------------------|
| `~/.ssh/`                                 | SSH keys              | `scp -r` from old machine, `chmod 600` keys      |
| `~/.gnupg/`                               | GPG keys              | `gpg --export-secret-keys` → import on new       |
| `~/.password-store/`                      | `pass` store          | `git clone <private pass repo>`                  |
| `~/.aws/credentials`                      | AWS                   | manual paste / 1Password                         |
| `~/.env`                                  | shell env vars        | manual paste                                     |
| `~/.config/gh/hosts.yml`                  | gh auth               | `gh auth login`                                  |
| `~/.config/doppler/`                      | Doppler CLI           | `doppler login`                                  |
| `~/.heroku/`                              | Heroku                | `heroku login`                                   |
| `~/.codeium`, `~/.codex`, `~/.claude*`, `~/.gemini` | AI CLI auths | re-authenticate each                       |
| project-specific creds in `$HOME`         | per-project           | `scp` from old machine                           |
| YubiKey                                   | hardware              | physically plug in, run `ykman info`             |
| `~/.gitconfig`                            | already in dotfiles   | verify `user.email` / `user.signingkey`          |

---

## Phase 11 — Sanity check

```sh
echo "== CLI =="
for cmd in zsh tmux nvim yazi rg fd fzf jq gh git mise go pnpm psql redis-cli mongosh; do
  command -v "$cmd" >/dev/null && echo "✓ $cmd" || echo "✗ $cmd MISSING"
done

if [ "$OS" = "mac" ]; then
  echo "== mac WM =="
  for proc in yabai skhd sketchybar; do
    pgrep -x "$proc" >/dev/null && echo "✓ $proc running" || echo "✗ $proc not running"
  done
fi
```

---

## Files this runbook depends on

| Path                              | Status                                                         |
|-----------------------------------|----------------------------------------------------------------|
| `~/.config/Brewfile`              | ✅ written                                                      |
| `~/.config/mise/config.toml`      | ⏳ TODO — pin node/ruby/python/go versions                      |
| `~/.config/packages/ubuntu.txt`   | ⏳ TODO                                                         |
| `~/.config/packages/arch.txt`     | ⏳ TODO                                                         |
| `~/.config/packages/aur.txt`      | ⏳ TODO                                                         |
| `~/.config/Brewfile.linux`        | ⏳ TODO — CLI-only subset                                        |
| `~/.config/hypr/*`                | ⏳ TODO — Hyprland configs to author                            |

---

## Updating this setup from the current machine

```sh
# Refresh Brewfile from installed state
brew bundle dump --file=~/.config/Brewfile --force --formula --cask --tap

# Refresh mise lockfile if pinning specific versions
mise list --installed > /tmp/mise-snapshot.txt
```
