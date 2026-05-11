function _df-domain() {
  echo "gui/$(id -u)"
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

  _df-bootstrap-kickstart "$domain" "$HOME/Library/LaunchAgents/com.thevetat.deskflow-server.plist" "com.thevetat.deskflow-server"
}

function df-pro-off() {
  _df-bootout "$(_df-domain)" "$HOME/Library/LaunchAgents/com.thevetat.deskflow-server.plist"
}

function df-air-on() {
  ssh air 'launchctl bootstrap gui/$(id -u) "$HOME/Library/LaunchAgents/com.thevetat.deskflow-client.plist" 2>/dev/null || true; launchctl kickstart -k gui/$(id -u)/com.thevetat.deskflow-client'
}

function df-air-off() {
  ssh air 'launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.thevetat.deskflow-client.plist" 2>/dev/null || true'
}

function df-on() {
  df-pro-on
  df-air-on
}

function df-off() {
  df-air-off
  df-pro-off
}

function df-restart() {
  df-on
}

function df-status() {
  local domain
  domain="$(_df-domain)"

  launchctl print "$domain/com.thevetat.deskflow-server" 2>/dev/null || true
  ssh air 'launchctl print gui/$(id -u)/com.thevetat.deskflow-client 2>/dev/null || true'
}
