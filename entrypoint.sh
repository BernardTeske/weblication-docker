#!/usr/bin/env bash
set -e

DOCROOT="/var/www/html"

# Schreibrechte sicherstellen (wichtig für Weblication)
chown -R www-data:www-data "$DOCROOT"

# Wenn webroot leer ist: Setup ZIP wie von dir gewohnt holen und entpacken
if [ -z "$(ls -A "$DOCROOT")" ]; then
  echo "Docroot leer – lade Weblication wSetup.zip..."
  tmpzip="/tmp/wSetup.zip"
  curl -fsSL -o "$tmpzip" "https://help-send.weblication.de/dev/downloads/wSetup.zip"
  unzip -o "$tmpzip" -d "$DOCROOT"
  rm -f "$DOCROOT"/*.txt "$tmpzip"
  chown -R www-data:www-data "$DOCROOT"
  echo "wSetup entpackt."
fi

exec "$@"
