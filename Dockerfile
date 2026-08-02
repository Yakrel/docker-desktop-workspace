# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OBSIDIAN_VERSION
ARG TASKS_VERSION
LABEL build_version="Desktop Workspace version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Yakrel"

# title
ENV TITLE="Desktop Workspace"

RUN \
  echo "**** setup repo ****" && \
  curl -fsSLo \
    /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
  echo \
    "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list && \
  echo "**** hold wayland packages to prevent ABI drift ****" && \
  WAYLAND_PKGS=$(dpkg -l | grep -E '^ii' | grep -E "labwc|wayland|wlr" | awk '{print $2}' | tr '\n' ' ') && \
  if [ -n "$WAYLAND_PKGS" ]; then apt-mark hold $WAYLAND_PKGS; fi && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    brave-origin && \
  echo "**** install Obsidian dependencies ****" && \
  apt-get install -y --no-install-recommends \
    git \
    dbus-x11 \
    gnome-keyring \
    libgtk-3-bin \
    libatk1.0 \
    libatk-bridge2.0 \
    libnss3 \
    libsecret-1-0 \
    adwaita-icon-theme \
    tint2 \
    jq \
    libwebkit2gtk-4.1-0 && \
  echo "**** install Tasks.org ****" && \
  TASKS_RELEASE_API="https://api.github.com/repos/tasks/tasks/releases/latest" && \
  if [ -n "${TASKS_VERSION:-}" ]; then \
    TASKS_RELEASE_API="https://api.github.com/repos/tasks/tasks/releases/tags/${TASKS_VERSION}"; \
  fi && \
  TASKS_DEB_URL=$(curl -fsSL "$TASKS_RELEASE_API" | jq -er 'first(.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url)') && \
  curl -fsSLo /tmp/tasks.deb "$TASKS_DEB_URL" && \
  apt-get install -y /tmp/tasks.deb && \
  sed -i 's|Exec=/usr/lib/tasksorg-llc/tasks-org/bin/tasks-org|Exec=env LIBGL_ALWAYS_SOFTWARE=1 /usr/lib/tasksorg-llc/tasks-org/bin/tasks-org|' /usr/share/applications/org.tasks.desktop && \
  rm /tmp/tasks.deb && \
  echo "**** install Obsidian ****" && \
  if [ -z ${OBSIDIAN_VERSION+x} ]; then \
    OBSIDIAN_VERSION=$(curl -sX GET "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest"| awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  curl -o \
    /tmp/obsidian.app -L \
    "https://github.com/obsidianmd/obsidian-releases/releases/download/${OBSIDIAN_VERSION}/Obsidian-$(echo ${OBSIDIAN_VERSION} | sed 's/v//g').AppImage" && \
  chmod +x /tmp/obsidian.app && \
  ./obsidian.app --appimage-extract && \
  mv squashfs-root /opt/obsidian && \
  mkdir -p /usr/share/icons/hicolor/48x48/apps && \
  echo "**** copy obsidian icon ****" && \
  cp /opt/obsidian/obsidian.png /usr/share/icons/hicolor/48x48/apps/obsidian.png && \
  echo "**** copy selkies icon ****" && \
  cp /usr/share/icons/hicolor/256x256/apps/brave-origin.png /usr/share/selkies/www/icon.png && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
