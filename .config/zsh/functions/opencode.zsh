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
  local ensure
  local body
  local session_id
  local ensured_session_id
  local repo_root
  local agent_handle
  local -a attach_args

  attach_args=()
  while (( $# > 0 )); do
    case "$1" in
      --session)
        session_id="$2"
        shift 2
        ;;
      --session=*)
        session_id="${1#--session=}"
        shift
        ;;
      *)
        attach_args+=("$1")
        shift
        ;;
    esac
  done

  health="$(command curl -fsS "$aed_url/health" 2>/dev/null)"
  if [[ -n "$health" ]] && command -v jq >/dev/null 2>&1; then
    base_url="$(print -r -- "$health" | command jq -r '.data.daemon.runtime.opencode.baseUrl // empty' 2>/dev/null)"
  fi

  if [[ -n "$base_url" ]] && command -v jq >/dev/null 2>&1; then
    agent_handle="${AETHERNET_AGENT_HANDLE:-primary-${USER:-operator}-${PWD:t}}"
    if [[ -n "$session_id" ]]; then
      body="$(command jq -n --arg repo "$PWD" --arg agent "$agent_handle" --arg session "$session_id" '{mode:"bind", repo_root:$repo, agent:$agent, runtime_session_id:$session}')"
    else
      body="$(command jq -n --arg repo "$PWD" --arg agent "$agent_handle" '{mode:"create", repo_root:$repo, agent:$agent}')"
    fi
    ensure="$(command curl -fsS -X POST "$aed_url/v1/runtime/opencode/ensure-session" -H 'content-type: application/json' --data "$body" 2>/dev/null)"
    if [[ -n "$ensure" ]]; then
      ensured_session_id="$(print -r -- "$ensure" | command jq -r '.data.runtimeSessionId // empty' 2>/dev/null)"
      repo_root="$(print -r -- "$ensure" | command jq -r '.data.repoRoot // empty' 2>/dev/null)"
      if [[ -n "$ensured_session_id" ]]; then
        command opencode attach "$base_url" --session "$ensured_session_id" --dir "${repo_root:-$PWD}" "${attach_args[@]}"
        return $?
      fi
    fi
  fi

  if [[ -n "$base_url" ]]; then
    if [[ -n "$session_id" ]]; then
      command opencode attach "$base_url" --session "$session_id" --dir "$PWD" "${attach_args[@]}"
    else
      command opencode attach "$base_url" --dir "$PWD" "${attach_args[@]}"
    fi
    return $?
  fi

  if [[ -n "$session_id" ]]; then
    command opencode --session "$session_id" "${attach_args[@]}"
  else
    command opencode "${attach_args[@]}"
  fi
}
