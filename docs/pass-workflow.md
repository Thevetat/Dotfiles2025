# Pass + YubiKey Setup & Workflow

## Overview
Complete setup of `pass` (password manager) with YubiKey GPG keys for secure credential storage across macOS, Linux, and Windows.

---

## Dependencies Installed

### macOS (via Homebrew)
```bash
brew install ykman          # YubiKey Manager
brew install pinentry-mac   # PIN entry interface for macOS
# gpg was already installed
```

### Linux (for future reference)
```bash
sudo apt install gpg pass pcscd ykman  # Debian/Ubuntu
sudo dnf install gpg pass pcscd ykman  # Fedora
```

### Windows
- `gpg4win` - GPG for Windows
- `pass` via WSL or native port

---

## Initial Setup Process

### 1. Configure GPG Agent
Created `~/.gnupg/gpg-agent.conf`:
```
pinentry-program /opt/homebrew/bin/pinentry-mac
default-cache-ttl 64800
max-cache-ttl 64800
```
- Cache set to 18 hours (64800 seconds)
- Only enter PIN once per work session

Restart agent:
```bash
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

### 2. YubiKey PIN Setup
**Both YubiKeys configured with same PINs:**
```bash
ykman openpgp access change-pin         # User PIN (default: 123456)
ykman openpgp access change-admin-pin   # Admin PIN (default: 12345678)
```

**YubiKeys:**
- Primary: Serial [YUBIKEY-1-SERIAL]
- Backup: Serial [YUBIKEY-2-SERIAL]

### 3. Generate GPG Key
```bash
gpg --full-generate-key
```
- Type: RSA and RSA
- Size: 4096
- Expiration: 0 (no expiration)
- Name: [YOUR-NAME]
- Email: [YOUR-EMAIL]

**Key ID:** `[YOUR-GPG-KEY-ID]`

### 4. Backup Keys (Before Transfer)
```bash
mkdir -p ~/yubikey-gpg-backup
chmod 700 ~/yubikey-gpg-backup
gpg --export-secret-keys --armor [YOUR-GPG-KEY-ID] > ~/yubikey-gpg-backup/private-key.asc
gpg --export --armor [YOUR-GPG-KEY-ID] > ~/yubikey-gpg-backup/public-key.asc
```

### 5. Move Keys to First YubiKey
```bash
gpg --edit-key [YOUR-GPG-KEY-ID]
# Commands:
keytocard     # Move signing key -> choose (1) Signature key
key 1         # Select encryption subkey
keytocard     # Move encryption key -> choose (2) Encryption key
save
```

### 6. Clone Keys to Second YubiKey (Backup)
```bash
# Delete stubs
gpg --delete-secret-key [YOUR-GPG-KEY-ID]

# Re-import from backup
gpg --import ~/yubikey-gpg-backup/private-key.asc

# Repeat keytocard process with second YubiKey plugged in
gpg --edit-key [YOUR-GPG-KEY-ID]
# (same keytocard steps as above)
```

### 7. Delete Temporary Backup
```bash
rm -rf ~/yubikey-gpg-backup
```

### 8. Initialize Pass
```bash
pass init [YOUR-GPG-KEY-ID]
```

### 9. Verify Setup
```bash
pass generate test/example 20  # Create test password
pass test/example              # Retrieve it (requires YubiKey PIN)
pass test/example              # Second retrieval (no PIN, cached)
```

### 10. Setup Pass Completions

**macOS with Homebrew:**

Add Homebrew completions to `fpath` in `~/.zshrc` (before Prezto loads):
```bash
# Add Homebrew completions to fpath (must be before Prezto)
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
```

Rebuild completion cache:
```bash
rm -f ~/.zcompdump; compinit
exec zsh
```

**Test it works:**
```bash
pass <TAB>
# Should show: cp, edit, find, generate, git, grep, init, insert, ls, mv, rm, show

pass services/<TAB>
# Should autocomplete your password paths
```

**Linux:**

Completions are usually installed to `/usr/share/zsh/site-functions/` automatically.

If not working, add to `~/.zshrc`:
```bash
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -U compinit && compinit
```

---

## Password Store Structure

```
~/.password-store/
├── projects/
│   ├── project-name/
│   │   ├── github-client-id
│   │   ├── github-client-secret
│   │   ├── resend-api-key
│   │   └── other-service-keys
│   └── another-project/
│       └── ...
│
├── services/
│   ├── anthropic/
│   │   └── api-key
│   ├── openai/
│   │   └── api-key
│   ├── resend/
│   │   └── api-key
│   ├── github/
│   │   ├── personal-token
│   │   └── ssh-key (multiline)
│   ├── aws/
│   │   ├── access-key-id
│   │   ├── secret-access-key
│   │   └── account-id
│   └── stripe/
│       ├── test-sk
│       └── prod-sk
│
└── personal/
    ├── important-notes
    └── backup-codes
```

---

## Common Pass Commands

### Basic Operations
```bash
pass                              # List all passwords
pass insert services/resend/api-key  # Add single-line password
pass insert -m services/github/ssh-key  # Add multi-line (like SSH keys)
pass generate services/stripe/test-sk 32  # Generate random 32-char password
pass services/resend/api-key      # Show password
pass -c services/resend/api-key   # Copy to clipboard (30s timeout)
pass edit services/resend/api-key # Edit password
pass rm services/resend/api-key   # Delete password
pass mv old/path new/path         # Move/rename password
```

### Search
```bash
pass grep "resend"                # Search for pattern
pass find resend                  # Find by name
```

### Git Integration (Optional)
```bash
pass git init                     # Initialize git repo in password store
pass git remote add origin <url>  # Add remote
pass git push                     # Push encrypted passwords to git
```

---

## Direnv + Pass Workflow

### Install direnv
```bash
brew install direnv
```

### Add to `.zshrc`
```bash
eval "$(direnv hook zsh)"
```

### Per-Project Setup

**Example: `~/projects/my-app/.envrc`**
```bash
# Pull credentials from pass
export GITHUB_CLIENT_ID=$(pass projects/my-app/github-client-id)
export GITHUB_CLIENT_SECRET=$(pass projects/my-app/github-client-secret)
export RESEND_API_KEY=$(pass services/resend/api-key)
export ANTHROPIC_API_KEY=$(pass services/anthropic/api-key)
export OPENAI_API_KEY=$(pass services/openai/api-key)

# Can also set project-specific configs
export NODE_ENV=development
export PORT=3000
```

### Usage
```bash
cd ~/projects/my-app
# direnv: loading ~/projects/my-app/.envrc
# direnv: export +GITHUB_CLIENT_ID +GITHUB_CLIENT_SECRET +RESEND_API_KEY ...

echo $RESEND_API_KEY
# Shows your key

cd ~
# direnv: unloading

echo $RESEND_API_KEY
# Empty - variables cleared
```

### Allow New/Modified .envrc
```bash
direnv allow .  # Must run once per new/modified .envrc
```

### Benefits
- Secrets never in files (pulled from pass)
- Can safely commit `.envrc` to git (no actual secrets)
- Automatic loading/unloading per directory
- YubiKey PIN cached for 18 hours
- Clean environment isolation

---

## Cross-Platform Usage

### Moving to a New Machine

**1. Export public key on current machine:**
```bash
gpg --export --armor [YOUR-GPG-KEY-ID] > ~/yubikey-public.asc
```

**2. On new machine:**
```bash
# Install dependencies (gpg, pass, etc)
# Import public key
gpg --import yubikey-public.asc

# Plug in YubiKey
gpg --card-status  # Verify YubiKey detected

# Initialize pass with same key ID
pass init [YOUR-GPG-KEY-ID]
```

**3. Sync password store:**
- Option A: Use `pass git` to sync via git repo
- Option B: Copy `~/.password-store/` directory

### Linux-Specific Setup
```bash
# Enable smart card daemon
sudo systemctl enable pcscd
sudo systemctl start pcscd

# Configure gpg-agent (Linux path)
echo "pinentry-program /usr/bin/pinentry-gtk-2" >> ~/.gnupg/gpg-agent.conf
echo "default-cache-ttl 64800" >> ~/.gnupg/gpg-agent.conf
echo "max-cache-ttl 64800" >> ~/.gnupg/gpg-agent.conf
```

---

## Security Notes

- **Private keys NEVER leave YubiKey** - they're locked in hardware
- **PIN required** once per 18-hour session
- **Both YubiKeys identical** - either works, one is backup
- **3 wrong PIN attempts** = locked (requires Admin PIN to reset)
- **8 wrong Admin PIN attempts** = YubiKey permanently locked
- **Password store encrypted** with GPG key on YubiKey
- **No secrets in .envrc** - they're pulled from pass at runtime

---

## Troubleshooting

### YubiKey not detected
```bash
ykman list                    # Check detection
gpg --card-status             # Check GPG can see card
gpgconf --kill gpg-agent      # Restart agent
```

### PIN not caching
```bash
# Verify cache settings
cat ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

### Wrong card error
```bash
# Remove YubiKey stubs and re-detect
gpg-connect-agent "scd serialno" "learn --force" /bye
```

### Pass can't decrypt
- Ensure YubiKey is plugged in
- Check card status: `gpg --card-status`
- Verify key: `gpg --list-secret-keys`

---

## SSH Authentication with YubiKey

### Complete Setup for SSH + Git

**Benefits:**
- Use YubiKey for SSH authentication (servers, GitHub, GitLab, Gitea)
- Same 18-hour PIN cache as pass
- `git pull`/`git push`/`ssh` work seamlessly after PIN entered once
- No traditional SSH keys needed
- Works across all machines (plug in YubiKey, works immediately)

---

### 1. Enable SSH Support in gpg-agent

**macOS:** Edit `~/.gnupg/gpg-agent.conf`:
```bash
pinentry-program /opt/homebrew/bin/pinentry-mac
default-cache-ttl 64800
max-cache-ttl 64800
enable-ssh-support
```

**Linux:** Edit `~/.gnupg/gpg-agent.conf`:
```bash
pinentry-program /usr/bin/pinentry-gtk-2
default-cache-ttl 64800
max-cache-ttl 64800
enable-ssh-support
```

Restart agent:
```bash
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

---

### 2. Configure Shell to Use gpg-agent for SSH

**Add to `~/.zshrc` (or `~/.bashrc` on Linux):**
```bash
# Use gpg-agent for SSH authentication
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

# Optional: Start gpg-agent if not running
gpgconf --launch gpg-agent
```

**Reload shell:**
```bash
source ~/.zshrc
```

---

### 3. Extract SSH Public Key from YubiKey

```bash
gpg --export-ssh-key [YOUR-GPG-KEY-ID]
```

**Output example:**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... openpgp:0xCCCAD687
```

Copy this entire line - you'll need it for GitHub/GitLab/Gitea.

**Optional: Save to file for easy access:**
```bash
gpg --export-ssh-key [YOUR-GPG-KEY-ID] > ~/.ssh/yubikey.pub
```

---

### 4. Add SSH Key to Git Hosting Platforms

#### GitHub
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Title: `YubiKey - [KEY-SHORT]` (or any name)
4. Key type: Authentication Key
5. Paste your SSH public key
6. Click "Add SSH key"

**Test:**
```bash
ssh -T git@github.com
# First time: Enter YubiKey PIN
# Output: Hi [your-username]! You've successfully authenticated...
```

#### GitLab
1. Go to https://gitlab.com/-/profile/keys
2. Click "Add new key"
3. Key: Paste your SSH public key
4. Title: `YubiKey - [KEY-SHORT]`
5. Usage type: Authentication & Signing (select both)
6. Expiration: Leave blank or set future date
7. Click "Add key"

**Test:**
```bash
ssh -T git@gitlab.com
# First time: Enter YubiKey PIN
# Output: Welcome to GitLab, @[your-username]!
```

#### Gitea (Self-hosted)
1. Go to `https://your-gitea-instance/user/settings/keys`
2. SSH Keys section
3. Key Name: `YubiKey - [KEY-SHORT]`
4. Content: Paste your SSH public key
5. Click "Add Key"

**Test:**
```bash
ssh -T git@your-gitea-instance
# First time: Enter YubiKey PIN
# Output: Hi there, [your-username]! You've successfully authenticated...
```

---

### 5. Configure Git to Use YubiKey for Signing

**Global Git config:**
```bash
git config --global user.name "[YOUR-NAME]"
git config --global user.email "[YOUR-EMAIL]"
git config --global user.signingkey [YOUR-GPG-KEY-ID]
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global gpg.program gpg
```

**This enables:**
- Automatic commit signing with YubiKey
- Verified commits on GitHub/GitLab
- Git tags signed with YubiKey

---

### 6. Add GPG Public Key to Git Platforms (for Verified Commits)

**Export GPG public key:**
```bash
gpg --armor --export [YOUR-GPG-KEY-ID]
```

Copy the entire output (including `-----BEGIN PGP PUBLIC KEY BLOCK-----` and `-----END PGP PUBLIC KEY BLOCK-----`)

#### GitHub - Add GPG Key
1. Go to https://github.com/settings/keys
2. Click "New GPG key"
3. Paste your GPG public key
4. Click "Add GPG key"

#### GitLab - Add GPG Key
1. Go to https://gitlab.com/-/profile/gpg_keys
2. Paste your GPG public key
3. Click "Add key"

#### Gitea - Add GPG Key
1. Go to `https://your-gitea-instance/user/settings/keys`
2. GPG Keys section
3. Paste your GPG public key
4. Click "Add Key"

---

### 7. Test Complete Setup

**Test SSH authentication:**
```bash
ssh -T git@github.com
ssh -T git@gitlab.com
# Enter PIN once (first command of the day)
# Subsequent commands: no PIN needed
```

**Test git operations:**
```bash
cd ~/some-repo
git commit -m "Test signed commit"
# First commit of day: Enter PIN
# Subsequent commits: no PIN needed

git push
# No PIN needed (cached from earlier)
```

**Verify commit is signed on GitHub/GitLab:**
- Look for "Verified" badge next to your commit
- Green checkmark confirms YubiKey signature

---

### 8. Configure New Machines

When setting up a new machine:

**Step 1: Install dependencies and configure gpg-agent** (see sections above)

**Step 2: Import public key:**
```bash
gpg --import yubikey-public.asc
```

**Step 3: Set trust level:**
```bash
gpg --edit-key [YOUR-GPG-KEY-ID]
# Type: trust
# Choose: 5 (ultimate)
# Type: quit
```

**Step 4: Configure shell:**
```bash
echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.zshrc
source ~/.zshrc
```

**Step 5: Test:**
```bash
ssh -T git@github.com
# Enter PIN once
# Works immediately!
```

---

### Daily Workflow with SSH

**Morning:**
1. Plug in YubiKey
2. First `git push` or `ssh` command → Enter PIN once
3. Rest of day: all SSH/git operations work seamlessly
   - `git pull` - no PIN
   - `git push` - no PIN
   - `ssh server` - no PIN
   - `git commit` (signed) - no PIN

**Night:**
1. Unplug YubiKey
2. All SSH/git operations immediately secured
3. No access without physical YubiKey

**Switching machines:**
- Each machine has independent 18-hour PIN cache
- Enter PIN once per machine per day
- YubiKey works on any configured machine

---

### SSH Key Management

**List SSH keys recognized by gpg-agent:**
```bash
ssh-add -L
```

**Check SSH agent status:**
```bash
echo $SSH_AUTH_SOCK
# Should output: /path/to/gnupg/S.gpg-agent.ssh
```

**View YubiKey card status:**
```bash
gpg --card-status
```

**Kill and restart gpg-agent (if issues):**
```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

---

### Troubleshooting SSH

**SSH not using YubiKey:**
```bash
# Verify SSH_AUTH_SOCK is set
echo $SSH_AUTH_SOCK

# Should point to gpg-agent socket
# If not, add to ~/.zshrc and reload
```

**"sign_and_send_pubkey: signing failed" error:**
```bash
# YubiKey not detected or gpg-agent not running
gpg --card-status
gpgconf --kill gpg-agent && gpgconf --launch gpg-agent
```

**Git commits not signing:**
```bash
# Verify signing is enabled
git config --global commit.gpgsign
# Should output: true

# Test GPG
echo "test" | gpg --clearsign
# Should prompt for PIN and sign
```

**Different SSH key on different machines:**
- This is expected - each machine may show different key format
- Both point to same YubiKey GPG key
- Works identically across all machines

---

### Security Benefits

**Traditional SSH keys:**
- Private key stored on disk (can be stolen)
- Copied across machines (multiple copies)
- Protected only by file permissions
- Can be exfiltrated by malware

**YubiKey SSH:**
- ✅ Private key NEVER leaves YubiKey hardware
- ✅ Physical device required for authentication
- ✅ PIN required (cached 18 hours)
- ✅ Unplug YubiKey = instant lockout
- ✅ Works across unlimited machines
- ✅ No key files to manage/backup
- ✅ Impossible to steal private key (hardware-bound)

---

## Quick Reference

**Daily Usage:**
1. Plug in YubiKey
2. First operation (pass/ssh/git) → enter PIN once
3. Rest of 18-hour session → no PIN needed
   - `pass` commands work
   - `git push`/`git pull` work
   - `ssh` works
   - `cd` into projects auto-loads credentials
4. Unplug YubiKey at night → all operations immediately secured

**Adding new credentials:**
```bash
pass insert services/new-service/api-key
```

**Adding to project .envrc:**
```bash
echo 'export NEW_API_KEY=$(pass services/new-service/api-key)' >> .envrc
direnv allow .
```

**Quick SSH/Git commands:**
```bash
# Test GitHub SSH
ssh -T git@github.com

# Clone with SSH
git clone git@github.com:user/repo.git

# Push with signed commit
git commit -m "message" && git push
```

**Emergency (lost YubiKey):**
- Use backup YubiKey (identical setup)
- All credentials still accessible
- Works on any machine immediately

---

## Summary

- **Dependencies:** gpg, pass, ykman, pinentry-mac, direnv
- **YubiKeys:** 2x configured identically (Serial: [YUBIKEY-1-SERIAL], [YUBIKEY-2-SERIAL])
- **PIN Cache:** 18 hours (applies to pass, SSH, and git signing)
- **Key ID:** [YOUR-GPG-KEY-ID]
- **Structure:** projects/ + services/ + personal/
- **Workflow:** direnv + .envrc auto-loads from pass
- **SSH:** YubiKey authentication for GitHub/GitLab/Gitea/servers
- **Git Signing:** All commits/tags automatically signed with YubiKey
- **Cross-platform:** Works on macOS, Linux, Windows
