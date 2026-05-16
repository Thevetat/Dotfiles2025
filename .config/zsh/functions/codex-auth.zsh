codex-auth() {
  local target="$1"
  local auth_dir="${CODEX_HOME:-$HOME/.codex}"
  local active="$auth_dir/auth.json"
  local aether_auth="$auth_dir/auth.aether.json"
  local macbook_auth="$auth_dir/auth.Thevetats-MacBook-Pro.json"
  local selected_auth

  case "$target" in
    aether)
      selected_auth="$aether_auth"
      ;;
    macbook|mac|thevetat)
      selected_auth="$macbook_auth"
      target="macbook"
      ;;
    status)
      if [ ! -f "$active" ]; then
        echo "Codex auth is missing: $active"
        return 1
      fi

      if [ -f "$aether_auth" ] && cmp -s "$active" "$aether_auth"; then
        echo "aether"
        return 0
      fi

      if [ -f "$macbook_auth" ] && cmp -s "$active" "$macbook_auth"; then
        echo "macbook"
        return 0
      fi

      echo "unknown"
      return 1
      ;;
    *)
      echo "Usage: codex-auth <aether|macbook|status>"
      return 1
      ;;
  esac

  if [ ! -f "$selected_auth" ]; then
    echo "Codex auth is missing: $selected_auth"
    return 1
  fi

  command cp -p "$selected_auth" "$active" || return 1
  command chmod 600 "$active" || return 1
  echo "Codex auth switched to $target"
}

alias codauth='codex-auth'
alias codaether='codex-auth aether'
alias codmac='codex-auth macbook'
