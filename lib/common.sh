log() {
  echo "==> $*"
}

apt_get() {
  log "Running apt-get $*"
  apt-get \
    -o DPkg::Lock::Timeout=300 \
    "$@"
}

wait_for_apt() {
  log "Waiting for the package manager lock..."

  apt-get \
    -o DPkg::Lock::Timeout=300 \
    update
}
