function _df-domain() {
  echo "gui/$(id -u)"
}

function _df-say() {
  printf 'deskflow: %s\n' "$*"
}

function _df-bootstrap-kickstart() {
  local domain="$1"
  local plist="$2"
  local label="$3"

  launchctl bootstrap "$domain" "$plist" 2>/dev/null || true
  launchctl kickstart -k "$domain/$label"
}

function _df-bootout() {
  local domain="$1"
  local plist="$2"

  launchctl bootout "$domain" "$plist" 2>/dev/null || true
}

function df-pro-on() {
  local domain
  domain="$(_df-domain)"

  _df-say "restarting Pro server"
  if _df-bootstrap-kickstart "$domain" "$HOME/Library/LaunchAgents/com.thevetat.deskflow-server.plist" "com.thevetat.deskflow-server"; then
    _df-say "Pro server is running"
  else
    _df-say "Pro server failed to start"
    return 1
  fi
}

function df-pro-off() {
  _df-say "stopping Pro server"
  _df-bootout "$(_df-domain)" "$HOME/Library/LaunchAgents/com.thevetat.deskflow-server.plist"
  _df-say "Pro server is stopped"
}

function df-air-on() {
  _df-say "restarting Air client over SSH"
  if ssh air 'launchctl bootstrap gui/$(id -u) "$HOME/Library/LaunchAgents/com.thevetat.deskflow-client.plist" 2>/dev/null || true; launchctl kickstart -k gui/$(id -u)/com.thevetat.deskflow-client'; then
    _df-say "Air client is running"
  else
    _df-say "Air client failed to start"
    return 1
  fi
}

function df-air-off() {
  _df-say "stopping Air client over SSH"
  if ssh air 'launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.thevetat.deskflow-client.plist" 2>/dev/null || true'; then
    _df-say "Air client is stopped"
  else
    _df-say "Air client failed to stop"
    return 1
  fi
}

function df-on() {
  _df-say "bringing Deskflow online"
  df-pro-on || return 1
  df-air-on || return 1
  _df-say "Deskflow is online"
}

function df-off() {
  local status=0

  _df-say "taking Deskflow offline"
  df-air-off || status=1
  df-pro-off || status=1
  if [[ "$status" -eq 0 ]]; then
    _df-say "Deskflow is offline"
  else
    _df-say "Deskflow stop finished with errors"
  fi
  return "$status"
}

function df-restart() {
  _df-say "restarting Deskflow"
  df-on
}

function df-status() {
  local domain
  domain="$(_df-domain)"

  _df-say "Pro server status"
  launchctl print "$domain/com.thevetat.deskflow-server" 2>/dev/null || true
  _df-say "Air client status"
  ssh air 'launchctl print gui/$(id -u)/com.thevetat.deskflow-client 2>/dev/null || true'
}
