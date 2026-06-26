#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:99}"
export SCREEN_WIDTH="${SCREEN_WIDTH:-1280}"
export SCREEN_HEIGHT="${SCREEN_HEIGHT:-720}"
export SCREEN_DEPTH="${SCREEN_DEPTH:-24}"
export CHROME_HOME="${CHROME_HOME:-/home/chrome}"
export CHROME_PROFILE_DIR="${CHROME_PROFILE_DIR:-${CHROME_HOME}/profile}"
export CHROME_CACHE_DIR="${CHROME_CACHE_DIR:-${CHROME_HOME}/cache}"

if [ -z "${VNC_PASSWORD:-}" ]; then
  echo "VNC_PASSWORD is required" >&2
  exit 1
fi

mkdir -p "${CHROME_PROFILE_DIR}" "${CHROME_CACHE_DIR}"
chown -R chrome:chrome "${CHROME_HOME}"
mkdir -p "${CHROME_HOME}/.vnc"
if [ ! -s "${CHROME_HOME}/.vnc/passwd" ]; then
  x11vnc -storepasswd "${VNC_PASSWORD}" "${CHROME_HOME}/.vnc/passwd" >/dev/null
fi
chown -R chrome:chrome "${CHROME_HOME}/.vnc"
chmod 600 "${CHROME_HOME}/.vnc/passwd"

MEM_TOTAL_KB="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
MEM_TOTAL_MB="$((MEM_TOTAL_KB / 1024))"

WINDOW_SIZE="${SCREEN_WIDTH},${SCREEN_HEIGHT}"

CHROME_FLAGS=(
  --no-default-browser-check
  --no-first-run
  --disable-default-apps
  --disable-background-networking
  --disable-background-timer-throttling
  --disable-backgrounding-occluded-windows
  --disable-breakpad
  --disable-component-extensions-with-background-pages
  --disable-crash-reporter
  --disable-dev-shm-usage
  --disable-features=Translate,BackForwardCache,MediaRouter,OptimizationHints,AutofillServerCommunication,CertificateTransparencyComponentUpdater
  --disable-gpu
  --disable-hang-monitor
  --disable-ipc-flooding-protection
  --disable-renderer-backgrounding
  --disable-session-crashed-bubble
  --disable-sync
  --disable-software-rasterizer
  --disk-cache-dir="${CHROME_CACHE_DIR}"
  --disk-cache-size=134217728
  --enable-low-end-device-mode
  --force-color-profile=srgb
  --memory-pressure-off
  --no-sandbox
  --password-store=basic
  --process-per-site
  --renderer-process-limit=2
  --user-data-dir="${CHROME_PROFILE_DIR}"
  --window-size="${WINDOW_SIZE}"
)

if [ "${MEM_TOTAL_MB}" -le 2048 ]; then
  CHROME_FLAGS+=(
    --disable-extensions
    --disable-site-isolation-trials
    --js-flags=--max-old-space-size=192
  )
fi

if [ -n "${CHROME_EXTRA_FLAGS:-}" ]; then
  # Intentional word splitting for user-supplied Chromium flags.
  # shellcheck disable=SC2206
  EXTRA_FLAGS=( ${CHROME_EXTRA_FLAGS} )
  CHROME_FLAGS+=("${EXTRA_FLAGS[@]}")
fi

exec /usr/bin/chromium "${CHROME_FLAGS[@]}" about:blank
