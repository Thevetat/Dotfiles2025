# Omarchy Workstation Setup

The public dotfiles repository tracks declarative user choices. Omarchy's
packaged defaults, copied installer artifacts, runtime state, and credentials
remain untracked.

## Tracked

- `~/.config/hypr/bindings.lua`: Voxtype dictation and Proton Mail bindings.
- `~/.config/hypr/looknfeel.lua`: gaps, rounding, inactive dimming, and VRR.
- `~/.config/hypr/monitors.lua`: the workstation's DP-3 ultrawide mode.
- `~/.config/omarchy/shell.json`: bar layout, media/Tailscale widgets, and idle timers.
- `~/.config/omarchy/defaults/agent`: OpenCode as the default agent.
- `~/.config/ghostty/`: portable settings plus macOS and Omarchy overlays.
- `~/.config/environment.d/90-opencode.conf`: disable package-managed OpenCode self-updates.
- `~/.config/voxtype/config.toml`: Parakeet, OSD, and compositor-controlled dictation settings.
- The Omarchy environment block in `~/.config/zsh/os/linux.zsh`.
- `~/.local/bin/setup-ghostty`: select the tracked terminal overlay for each OS.
- `~/.local/bin/setup-omarchy`: package, service, repository, symlink, theme, font, and background setup.

The monitor rule is intentionally workstation-specific. It is harmless when
DP-3 is absent, but should be changed on an Omarchy machine with another output
name or geometry.

## Not Tracked

- Unmodified Hyprland files copied from `/usr/share/omarchy/config/hypr`.
- Stock hook samples and first-run hooks under `~/.config/omarchy/hooks`.
- Generated branding, the stock menu extension, and the empty `aether` theme directory.
- `~/.local/state/omarchy/current`, which contains active theme/background symlinks and rendered theme files.
- `~/.config/ghostty/local.conf`, selected locally by `setup-ghostty`.
- `~/.tmux/plugins` and `~/.zprezto`, which the bootstrap clones.
- Voxtype's backup config and copied user service; the package supplies the service unit.
- Secrets, API keys, SSH keys, package caches, and application runtime state.

## Restore

After installing the public dotfiles on macOS, select its Ghostty overlay with:

```bash
setup-ghostty
```

After installing Omarchy and the public dotfiles, run the full setup. It calls
`setup-ghostty` automatically:

```bash
bash ~/.local/bin/setup-omarchy
```

The script is idempotent, updates managed symlinks, and refuses to overwrite
existing real files or repositories. Access to the private `ai-tools`
repository requires the machine's GitHub SSH credentials.
