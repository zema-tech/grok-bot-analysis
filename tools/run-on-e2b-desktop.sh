#!/usr/bin/env bash
# Grok Bot 0.72.0 — prepare + launch on an E2B Desktop (or any Ubuntu with GUI) sandbox.
# Run this INSIDE the cloud desktop sandbox (not on the user's local PC).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEB="grok-bot_0.72.0_amd64.deb"
EXPECTED_SHA="f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd"
APP_DIR="/opt/Grok Bot"
BIN="$APP_DIR/grok-bot"

echo "==> [1/6] Verify / reassemble .deb"
if [[ -f "$DEB" ]]; then
  ACTUAL=$(sha256sum "$DEB" | awk '{print $1}')
  if [[ "$ACTUAL" != "$EXPECTED_SHA" ]]; then
    echo "Existing $DEB hash mismatch — rebuilding from parts/"
    bash tools/reassemble.sh
  else
    echo "OK: $DEB already valid"
  fi
else
  bash tools/reassemble.sh
fi

echo "==> [2/6] Install system deps (GTK / Electron runtime)"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq \
  libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils \
  libatspi2.0-0 libuuid1 libsecret-1-0 libasound2t64 libasound2 \
  libgbm1 libxkbcommon0 libdrm2 libappindicator3-1 \
  xvfb x11-utils 2>/dev/null || \
sudo apt-get install -y -qq \
  libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils \
  libatspi2.0-0 libuuid1 libsecret-1-0 libasound2 \
  libgbm1 libxkbcommon0 libdrm2 xvfb x11-utils

echo "==> [3/6] Extract package (no full dpkg install — avoids system pollution)"
EXTRACT="$ROOT/extracted"
rm -rf "$EXTRACT"
mkdir -p "$EXTRACT"
dpkg-deb -x "$DEB" "$EXTRACT"
dpkg-deb -e "$DEB" "$EXTRACT/DEBIAN"

echo "==> [4/6] Optional: install to /opt (needs sudo)"
if [[ "${INSTALL_SYSTEM:-0}" == "1" ]]; then
  sudo mkdir -p /opt
  sudo cp -a "$EXTRACT/opt/Grok Bot" /opt/
  sudo cp -a "$EXTRACT/usr/share/applications/grok-bot.desktop" /usr/share/applications/ 2>/dev/null || true
  echo "Installed under $APP_DIR"
else
  APP_DIR="$EXTRACT/opt/Grok Bot"
  BIN="$APP_DIR/grok-bot"
  echo "Running from extract path: $BIN"
fi

chmod +x "$BIN" "$APP_DIR/chrome-sandbox" 2>/dev/null || true
# Electron often needs no-sandbox in containers / microVMs
export ELECTRON_DISABLE_SANDBOX=1
export ELECTRON_OZONE_PLATFORM_HINT=auto

echo "==> [5/6] Display check"
if [[ -z "${DISPLAY:-}" ]]; then
  echo "No DISPLAY — starting Xvfb :99"
  Xvfb :99 -screen 0 1280x800x24 &
  sleep 1
  export DISPLAY=:99
fi
echo "DISPLAY=$DISPLAY"

echo "==> [6/6] Launch Grok Bot"
echo "Binary: $BIN"
echo "Args: --no-sandbox --disable-gpu-sandbox"
# Background if HEADLESS_LAUNCH=1
if [[ "${HEADLESS_LAUNCH:-0}" == "1" ]]; then
  nohup "$BIN" --no-sandbox --disable-gpu-sandbox >"$ROOT/grok-bot.log" 2>&1 &
  echo "PID $!  log: $ROOT/grok-bot.log"
  sleep 2
  ps -p $! -o pid,cmd || true
else
  exec "$BIN" --no-sandbox --disable-gpu-sandbox "$@"
fi
