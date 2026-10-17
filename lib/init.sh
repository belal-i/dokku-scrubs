set -eo pipefail

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
  fi
}

ensure_plugin() {
  local plugin="$1"
  local url="$2"

  if ! dokku plugin:list | grep "$plugin"; then
    dokku plugin:install "$url"
  else
    dokku plugin:update "$plugin" master
  fi
}

init_system() {
  local app="$1"

  export DEBIAN_FRONTEND=noninteractive
  apt-get update

  apt-get install -y jq

  init_fail2ban "$app"
  # TODO: In the future, set up other system tools here.
}

init_fail2ban() {
  local app="$1"

  apt-get install -y fail2ban
  systemctl enable --now fail2ban

  local filter="${ETC_DIR}/filter.d/${app}.conf"
  local jail="${ETC_DIR}/jail.d/${app}.local"

  # Install global fail2ban jails.
  install -Dm644 \
    "$ETC_DIR/jail.d/dokku-scrubs.local" \
    /etc/fail2ban/jail.d/dokku-scrubs.local

  # Install app specific fail2ban filter, if it exists.
  if [[ -f "$filter" ]]; then
    install -Dm644 \
      "$filter" \
      "/etc/fail2ban/filter.d/${app}.conf"
  fi

  # Install app specific fail2ban jail, if it exists.
  if [[ -f "$jail" ]]; then
    install -Dm644 \
      "$jail" \
      "/etc/fail2ban/jail.d/${app}.local"
  fi
}

init_dokku() {
  local dokku_tag="$1"
  local database="$2"
  local global_domain="$3"
  local install_dokku_from_source="$4"

  log "Installing Dokku"
  log "  Dokku tag: $dokku_tag"
  log "  Database : $database"

  if [[ ${install_dokku_from_source} -eq ${FLAGS_TRUE} ]]; then
    # using a branch results in installing from source
    wget -NP . https://dokku.com/install/master/bootstrap.sh;
    sudo DOKKU_BRANCH=master bash bootstrap.sh
  else
    wget -NP . "https://dokku.com/install/${dokku_tag}/bootstrap.sh"
    DOKKU_TAG="$dokku_tag" bash bootstrap.sh
  fi

  # Dokku has one global domain per server.
  # All apps managed by dokku-scrubs share this base domain.
  dokku domains:set-global "$global_domain"

  # Install needed plugins.
  ensure_plugin "$database" "https://github.com/dokku/dokku-${database}.git"
  ensure_plugin "letsencrypt" "https://github.com/dokku/dokku-letsencrypt.git"
}
