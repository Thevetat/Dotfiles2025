oc() {
  if ! command -v opencode >/dev/null 2>&1; then
    print -u2 "oc: opencode not found"
    return 127
  fi

  case "$1" in
    attach|serve|auth|models|agent|config|help|--help|-h|--version|-v)
      command opencode "$@"
      return $?
      ;;
  esac

  local aed_url="${AETHERNET_AED_URL:-http://127.0.0.1:8788}"
  local health
  local base_url

  health="$(command curl -fsS "$aed_url/health" 2>/dev/null)"
  if [[ -n "$health" ]] && command -v jq >/dev/null 2>&1; then
    base_url="$(print -r -- "$health" | command jq -r '.data.daemon.runtime.opencode.baseUrl // empty' 2>/dev/null)"
  fi

  if [[ -n "$base_url" ]]; then
    command opencode attach "$base_url" --dir "$PWD" "$@"
    return $?
  fi

  command opencode "$@"
}
