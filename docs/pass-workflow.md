# Pass + YubiKey Setup & Workflow

## Overview

Complete setup of `pass` (password manager) with YubiKey GPG keys for secure credential storage across macOS, Linux, and Windows.

---

## Dependencies Installed

### macOS (via Homebrew)

```bash
brew install ykman          # YubiKey Manager
brew install pinentry-mac   # PIN entry interface for macOS
brew install direnv         # Auto-load credentials per directory
brew tap amar1729/formulae
brew install browserpass pass-import  # Browser integration & password import
# gpg and pass were already installed
```

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

Add Homebrew completions to `fpath` in `~/.zshrc` (before Prezto):

```bash
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
```

Then rebuild cache:

```bash
rm -f ~/.zcompdump; compinit; exec zsh
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
├── web/
│   ├── github.com
│   ├── twitter.com
│   ├── stripe.com
│   ├── amazon.com
│   └── example.com
│
└── personal/
    ├── important-notes
    └── backup-codes
```

---

## Dev/Prod Organization

### When to Use Dev/Prod Separation

**Flat structure** for same credentials across environments:

```
projects/simple-project/
├── api-key
└── database-url
```

**Dev/prod structure** when credentials differ (OAuth apps, databases, Sentry, etc):

```
projects/my-app/
├── dev/
│   ├── github-client-id
│   ├── github-client-secret
│   ├── database-url
│   └── better-auth-secret
└── prod/
    ├── github-client-id           # Different OAuth app
    ├── github-client-secret
    ├── database-url               # Different database
    └── better-auth-secret         # Different secret
```

### Projects vs Services

**`projects/`** - Project-specific credentials that vary between projects (OAuth apps, project APIs)
**`services/`** - Shared credentials used across projects (Resend, Anthropic, OpenAI, personal tokens)

```
projects/my-app/dev/...
projects/my-app/prod/...
services/resend/api-key        # Shared across all projects
services/anthropic/api-key
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

### Git Integration

Git integration enables encrypted backup to GitHub, sync across machines, and version history.

#### Initial Setup

```bash
# 1. Initialize git
pass git init

# 2. Create private GitHub repo
gh repo create password-store --private

# 3. Add remote and push
pass git remote add origin git@github.com:[your-username]/pass.git
pass git push -u origin main
```

#### Daily Workflow

Pass automatically commits on insert/edit/rm/mv operations. Just push when ready:

```bash
pass git push
```

#### Syncing to New Machine

```bash
# Install dependencies, import GPG public key, plug in YubiKey
git clone git@github.com:[your-username]/pass.git ~/.password-store
pass  # Verify it works
```

---

## Browser Integration

### Installing Browserpass

```bash
brew tap amar1729/formulae
brew install browserpass pass-import
```

### Configure for Arc/Chrome

```bash
PREFIX='/opt/homebrew/opt/browserpass' make hosts-chrome-user -f '/opt/homebrew/opt/browserpass/lib/browserpass/Makefile'
```

For other browsers, replace `chrome` with: `chromium`, `brave`, `vivaldi`, or `firefox`

### Install Browser Extension

1. Open Chrome Web Store
2. Search for "Browserpass"
3. Install the extension
4. Extension will automatically connect to pass

### Using Browserpass

Store passwords by domain name for auto-fill:

```bash
pass insert web/github.com
pass insert web/stripe.com
pass insert web/amazon.com
```

When you visit github.com, browserpass auto-detects and offers to fill your credentials. Press `Ctrl+Shift+L` (or click extension icon) to auto-fill.

### Importing from Arc/Chrome

Export passwords from Arc/Chrome:
- Go to `chrome://settings/passwords`
- Click ⋮ → Export passwords → Save as CSV

Import to pass:

```bash
pass import csv arc-passwords.csv --out web/
```

**Recommendation:** Import manually to organize better, skip unused accounts, and update weak passwords.

---

## Direnv + Pass Workflow

### Setup

```bash
brew install direnv
# Add to .zshrc: eval "$(direnv hook zsh)"
```

### Secret Caching (8-Hour TTL)

To avoid 5-10 second YubiKey delays on every `cd`, use the `secret()` function instead of `pass`:

```bash
# Use secret() instead of pass
export DATABASE_URL=$(secret projects/my-app/dev/database-url)
export API_KEY=$(secret services/resend/api-key)
```

**How it works:**
- First access: Decrypts via YubiKey (~2-5 seconds) and caches result
- Subsequent access: Instant retrieval from cache
- Cache location: `~/.cache/pass-secrets/` (hashed filenames)
- Cache lifetime: 8 hours (auto-cleaned on shell startup)
- Shared cache: If multiple projects use the same secret, they share the cache

**Cache management commands:**
```bash
pass-cache-list    # Show cached secrets and their age
pass-cache-clean   # Clean expired cache files (8 hours default)
pass-cache-clean 4 # Clean files older than 4 hours
pass-cache-clear   # Delete all cached secrets immediately
```

### Per-Project .envrc

Create `.envrc` in project root with `secret` references (recommended) or `pass` for no caching:

```bash
# Simple project (with caching)
export GITHUB_CLIENT_ID=$(secret projects/my-app/github-client-id)
export RESEND_API_KEY=$(secret services/resend/api-key)
export NODE_ENV=development
```

Or with dev/prod structure:

```bash
# Dev environment (with caching)
export SENTRY_DSN=$(secret projects/myapp/dev/backend-sentry-dsn)
export GITHUB_CLIENT_ID=$(secret projects/myapp/dev/github-client-id)
export GITHUB_CLIENT_SECRET=$(secret projects/myapp/dev/github-client-secret)
export DATABASE_URL=$(secret projects/myapp/dev/database-url)
export RESEND_API_KEY=$(secret services/resend/api-key)
```

Safe to commit `.envrc` (contains no secrets, just pass paths).

### Usage

```bash
direnv allow .     # Allow new/modified .envrc
cd ~/projects/myapp
# First time: ~2-5 seconds (decrypts + caches)
# Subsequent times: instant! (reads from cache)
echo $GITHUB_CLIENT_ID  # Available
cd ~
# Auto-unloads
```

Benefits: Secrets never in files, automatic per-directory loading, can commit .envrc safely, cached for fast loading.

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

## SSH & Git with YubiKey (Optional)

YubiKey can also be used for SSH authentication and signed git commits. Add `enable-ssh-support` to gpg-agent.conf, configure git signing with `git config --global commit.gpgsign true`, and export your SSH public key with `gpg --export-ssh-key [YOUR-GPG-KEY-ID]` to add to GitHub/GitLab.

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
echo 'export NEW_API_KEY=$(secret services/new-service/api-key)' >> .envrc
direnv allow .
```

**Emergency (lost YubiKey):**

- Use backup YubiKey (identical setup)
- All credentials still accessible
- Works on any machine immediately

---

## Summary

- **Dependencies:** gpg, pass, ykman, pinentry-mac, direnv, browserpass, pass-import
- **YubiKeys:** 2x configured identically (Serial: [YUBIKEY-1-SERIAL], [YUBIKEY-2-SERIAL])
- **PIN Cache:** 18 hours (applies to pass, SSH, and git signing)
- **Key ID:** [YOUR-GPG-KEY-ID]
- **Structure:** projects/ + services/ + web/ + personal/
- **Workflow:** direnv + .envrc auto-loads from pass, browserpass auto-fills web logins
- **Browser:** Browserpass extension for Arc/Chrome auto-fill (Ctrl+Shift+L)
- **SSH:** YubiKey authentication for GitHub/GitLab/Gitea/servers
- **Git Signing:** All commits/tags automatically signed with YubiKey
- **Cross-platform:** Works on macOS, Linux, Windows
