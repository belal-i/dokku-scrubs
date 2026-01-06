create_app() {
  local app="$1"
  dokku apps:create "$app" || true
}

deploy_app() {
  local app="$1"
  local domain="$2"
  # TODO: Idempotency! Right now, it keeps creating new containers.
  dokku git:from-image "$app" "${APP_IMAGE[$app]}"
  dokku domains:add "$app" "$domain"
  dokku domains:remove "$app" "${app}.${domain}"
}
