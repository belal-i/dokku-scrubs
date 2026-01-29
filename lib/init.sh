set -eo pipefail

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
  fi
}

install_plugin() {
  local plugin="$1"
  local url="$2"
  if ! dokku plugin:list | grep "$plugin"; then
    dokku plugin:install "$url"
  else
    log "Plugin already installed: $plugin"
  fi
}

init_dokku() {
  local domain="$1"
  local dokku_tag="$2"
  local database="$3"

  log "Installing Dokku"
  log "  Domain: $domain"
  log "  Dokku tag: $dokku_tag"
  log "  Database : $database"

  wget -NP . "https://dokku.com/install/$dokku_tag/bootstrap.sh"
  DOKKU_TAG="$dokku_tag" bash bootstrap.sh

  # Domain
  dokku domains:set-global "$domain"

  # Install needed plugins.
  install_plugin "$database" "https://github.com/dokku/dokku-${database}.git"
  install_plugin "letsencrypt" "https://github.com/dokku/dokku-letsencrypt.git"
}
