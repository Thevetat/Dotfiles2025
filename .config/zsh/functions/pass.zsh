# Pass secret management with caching
# Caches decrypted secrets for 8 hours to avoid YubiKey prompts

# Cache directory
PASS_CACHE_DIR="${HOME}/.cache/pass-secrets"
PASS_CACHE_TTL=$((8 * 60))  # 8 hours in minutes

if { [[ -n "$ZSH_VERSION" ]] && (( ! $+functions[_copy_clipboard] )); } || { [[ -z "$ZSH_VERSION" ]] && ! declare -F _copy_clipboard >/dev/null; }; then
  function _copy_clipboard() {
    if [[ -n "$SSH_CONNECTION" ]] && command -v osc52-copy >/dev/null 2>&1; then
      osc52-copy
    elif command -v pbcopy >/dev/null 2>&1; then
      pbcopy
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
      xsel --clipboard --input
    elif command -v wl-copy >/dev/null 2>&1; then
      wl-copy
    elif command -v clip.exe >/dev/null 2>&1; then
      clip.exe
    else
      echo "Error: no clipboard command found (pbcopy/xclip/xsel/wl-copy/clip.exe)" >&2
      return 1
    fi
  }
fi

function _pass_cache_key() {
  if command -v md5sum >/dev/null 2>&1; then
    printf '%s' "$1" | md5sum | awk '{print $1}'
  elif command -v md5 >/dev/null 2>&1; then
    printf '%s' "$1" | md5 -q 2>/dev/null || printf '%s' "$1" | md5 | awk '{print $NF}'
  elif command -v openssl >/dev/null 2>&1; then
    printf '%s' "$1" | openssl dgst -md5 -r | awk '{print $1}'
  else
    echo "Error: no MD5 command found (md5sum/md5/openssl)" >&2
    return 1
  fi
}

function _pass_file_mtime() {
  local file="$1"
  local mtime

  mtime=$(stat -c %Y "$file" 2>/dev/null) || mtime=$(stat -f %m "$file" 2>/dev/null) || mtime=0
  printf '%s' "$mtime"
}

# Retrieve secret with caching
# Usage: secret <pass-path>
# Example: secret projects/trash-mafia/dev/database-url
function secret() {
  local key="$1"

  if [[ -z "$key" ]]; then
    echo "Usage: secret <pass-path>" >&2
    return 1
  fi

  # Create cache directory if it doesn't exist
  mkdir -p "$PASS_CACHE_DIR" 2>/dev/null
  chmod 700 "$PASS_CACHE_DIR" 2>/dev/null

  # Generate cache filename from hash of the key
  local cache_key
  cache_key="$(_pass_cache_key "$key")" || return 1
  local cache_file="${PASS_CACHE_DIR}/${cache_key}"

  # Check if cache exists and is fresh (< 8 hours old)
  if [[ -f "$cache_file" ]]; then
    local cache_age=$(($(date +%s) - $(_pass_file_mtime "$cache_file")))
    local cache_ttl_seconds=$((PASS_CACHE_TTL * 60))

    if [[ $cache_age -lt $cache_ttl_seconds ]]; then
      # Cache is fresh, return it
      cat "$cache_file"
      return 0
    fi
  fi

  # Cache miss or expired - fetch from pass
  local value
  if ! value=$(pass "$key" 2>/dev/null); then
    echo "Error: Failed to retrieve secret from pass: $key" >&2
    return 1
  fi

  # Store in cache with restrictive permissions
  echo -n "$value" > "$cache_file"
  chmod 600 "$cache_file" 2>/dev/null

  # Return the value
  echo -n "$value"
}

# Clean expired cache files
# Usage: pass-cache-clean [hours]
# Example: pass-cache-clean 4  # Clean files older than 4 hours
function pass-cache-clean() {
  local max_age_hours=${1:-8}
  local max_age_minutes=$((max_age_hours * 60))

  if [[ -d "$PASS_CACHE_DIR" ]]; then
    find "$PASS_CACHE_DIR" -type f -mmin +${max_age_minutes} -delete 2>/dev/null
    echo "Cleaned cache files older than ${max_age_hours} hours"
  else
    echo "No cache directory found"
  fi
}

# List cached secrets (shows hashed filenames and age)
# Usage: pass-cache-list
function pass-cache-list() {
  if [[ ! -d "$PASS_CACHE_DIR" ]]; then
    echo "No cache directory found"
    return 0
  fi

  local count=0
  echo "Cached secrets in ${PASS_CACHE_DIR}:"
  echo "----------------------------------------"

  for cache_file in "$PASS_CACHE_DIR"/*; do
    if [[ -f "$cache_file" ]]; then
      local filename=$(basename "$cache_file")
      local age_seconds=$(($(date +%s) - $(_pass_file_mtime "$cache_file")))
      local age_minutes=$((age_seconds / 60))
      local age_hours=$((age_minutes / 60))

      if [[ $age_hours -gt 0 ]]; then
        echo "  ${filename} (${age_hours}h old)"
      else
        echo "  ${filename} (${age_minutes}m old)"
      fi

      count=$((count + 1))
    fi
  done

  if [[ $count -eq 0 ]]; then
    echo "  (no cached secrets)"
  else
    echo "----------------------------------------"
    echo "Total: ${count} cached secrets"
  fi
}

# Clear all cached secrets
# Usage: pass-cache-clear
function pass-cache-clear() {
  if [[ -d "$PASS_CACHE_DIR" ]]; then
    rm -rf "$PASS_CACHE_DIR"/*
    echo "Cleared all cached secrets"
  else
    echo "No cache directory found"
  fi
}


function npass() {
  if [[ -z "$1" ]]; then
    echo "Usage: npass <pass-entry-path> [bytes]" >&2
    return 1
  fi

  local entry="$1"
  local bytes="${2:-32}"   # default 32 bytes -> 43-char base64 string
  local secret="$(openssl rand -base64 "$bytes")"

  pass insert -fm "$entry" <<<"$secret" || return $?
  if printf '%s' "$secret" | _copy_clipboard; then
    echo "Stored secret at '$entry' (copied to clipboard):"
  else
    echo "Stored secret at '$entry' (clipboard unavailable):"
  fi
  echo "$secret"
}
