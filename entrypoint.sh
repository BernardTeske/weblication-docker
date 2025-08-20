#!/usr/bin/env bash
set -euo pipefail

DOCROOT="/var/www/html"
CACHE="/opt/weblication/wSetup.zip"
URL_DEFAULT="https://help-send.weblication.de/dev/downloads/wSetup.zip"
URL="${WSETUP_URL:-$URL_DEFAULT}"

ensure_permissions() {
  chown -R www-data:www-data "$DOCROOT" || true
}

install_wsetup() {
  echo "Installiere Weblication-Setup..."
  local tmp="/tmp/wSetup.zip"

  if [ -s "$CACHE" ]; then
    cp "$CACHE" "$tmp"
    echo "Verwende gecachte wSetup.zip."
  else
    echo "Lade wSetup.zip von $URL ..."
    curl -fsSL -o "$tmp" "$URL"
  fi

  unzip -o "$tmp" -d "$DOCROOT"
  rm -f "$DOCROOT"/*.txt "$tmp"
  ensure_permissions
  echo "Weblication-Setup entpackt."
}

ensure_permissions

# Wenn keine Index-Datei vorhanden → Setup installieren
if [ ! -f "$DOCROOT/index.php" ] && [ ! -f "$DOCROOT/index.html" ]; then
  install_wsetup
fi

exec "$@"
