#!/bin/sh
# Base44 preview entrypoint for the Flutter web client.
#
# Flutter has no static-server dev mode that watches files, so this script
# builds build/web, serves it on 0.0.0.0:3000 with python's http.server, and
# rebuilds whenever lib/, web/ or pubspec.yaml change. A rebuild replaces the
# files in place; reload the browser (Base44: reload_preview) to pick it up.
set -e

APP_DIR=/app/farm_app
cd "$APP_DIR"

flutter config --no-analytics >/dev/null 2>&1 || true

build() {
  echo "[base44] resolving dependencies"
  flutter pub get
  echo "[base44] building Flutter web bundle"
  if flutter build web --no-pub --no-web-resources-cdn >/tmp/flutter_build.log 2>&1; then
    echo "[base44] build complete"
  else
    echo "[base44] build FAILED"
    tail -n 40 /tmp/flutter_build.log
    return 1
  fi
}

build || true

mkdir -p build/web
python3 -m http.server 3000 --bind 0.0.0.0 --directory build/web >/tmp/httpd.log 2>&1 &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null' EXIT INT TERM
echo "[base44] serving http://0.0.0.0:3000"

# Cheap content fingerprint of everything that affects the bundle.
snapshot() {
  find lib web pubspec.yaml -type f \( -name '*.dart' -o -name '*.yaml' -o -name '*.html' -o -name '*.json' -o -name '*.css' -o -name '*.png' \) \
    -exec md5sum {} + 2>/dev/null | sort | md5sum
}

LAST=$(snapshot)
while true; do
  sleep 3
  NOW=$(snapshot)
  if [ "$NOW" != "$LAST" ]; then
    sleep 2
    LAST=$(snapshot)
    build || true
  fi
done
