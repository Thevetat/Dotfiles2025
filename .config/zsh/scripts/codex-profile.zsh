#!/usr/bin/env zsh

_codex_host_profile() {
  case "$OSTYPE" in
    darwin*) echo "thevetat" ;;
    linux-gnu*) echo "aether" ;;
  esac
}

_codex_args_have_profile() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      -p|--profile|--profile=*) return 0 ;;
    esac
  done
  return 1
}

_codex_run_with_host_profile() {
  local profile
  profile="$(_codex_host_profile)"

  if [[ -n "$profile" ]] && ! _codex_args_have_profile "$@"; then
    command codex --profile "$profile" "$@"
  else
    command codex "$@"
  fi
}

codex() {
  if (( $+functions[lazy_load_nvm] )); then
    lazy_load_nvm
  fi

  _codex_run_with_host_profile "$@"
}

co() {
  codex "$@"
}
