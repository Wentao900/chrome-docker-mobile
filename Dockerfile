FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24 \
    HTTP_PORT=6080 \
    VNC_PORT=5900 \
    CHROME_USER=chrome \
    CHROME_HOME=/home/chrome \
    CHROME_PROFILE_DIR=/home/chrome/profile \
    CHROME_CACHE_DIR=/home/chrome/cache \
    CHROME_EXTRA_FLAGS=""

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    xvfb \
    x11vnc \
    openbox \
    supervisor \
    novnc \
    websockify \
    xdg-utils \
    dbus-x11 \
    fonts-noto-cjk \
    fonts-liberation \
    ca-certificates \
    procps \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash "${CHROME_USER}" \
    && mkdir -p /var/log/supervisor /etc/chrome-docker \
    && mkdir -p "${CHROME_PROFILE_DIR}" "${CHROME_CACHE_DIR}" \
    && chown -R "${CHROME_USER}:${CHROME_USER}" "${CHROME_HOME}" /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts/start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080 5900

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${HTTP_PORT}/vnc.html" >/dev/null || exit 1

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
