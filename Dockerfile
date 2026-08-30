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
ENV TITLE="Desktop Workspace" \
    PIXELFLUX_WAYLAND=true \
    SELKIES_DESKTOP=true \
    NO_GAMEPAD=true

RUN \
  echo "**** setup repo ****" && \
  curl -fsSLo \
    /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
  echo \
    "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list && \
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
    jq \
    squashfs-tools \
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
  OBSIDIAN_RELEASE_API="https://api.github.com/repos/obsidianmd/obsidian-releases/releases?per_page=20" && \
  if [ -n "${OBSIDIAN_VERSION:-}" ]; then \
    OBSIDIAN_RELEASE_API="https://api.github.com/repos/obsidianmd/obsidian-releases/releases/tags/${OBSIDIAN_VERSION}"; \
  fi && \
  OBSIDIAN_APPIMAGE_URL=$(curl -fsSL "$OBSIDIAN_RELEASE_API" | jq -er 'first((if type == "array" then .[] else . end).assets[] | select((.name | endswith(".AppImage")) and (.name | contains("arm64") | not)) | .browser_download_url)') && \
  curl -fsSLo /tmp/obsidian.app "$OBSIDIAN_APPIMAGE_URL" && \
  SQUASHFS_OFFSET=$(grep -aob 'hsqs' /tmp/obsidian.app | tail -n1 | cut -d: -f1) && \
  unsquashfs -o "$SQUASHFS_OFFSET" -d squashfs-root /tmp/obsidian.app && \
  mv squashfs-root /opt/obsidian && \
  mkdir -p /usr/share/icons/hicolor/48x48/apps && \
  echo "**** copy obsidian icon ****" && \
  cp /opt/obsidian/obsidian.png /usr/share/icons/hicolor/48x48/apps/obsidian.png && \
  echo "**** copy selkies icon ****" && \
  cp /opt/obsidian/obsidian.png /usr/share/selkies/www/icon.png && \
  echo "**** keep workspace launchers only ****" && \
  find /usr/share/applications -maxdepth 1 -type f -name '*.desktop' \
    ! -name 'brave-origin.desktop' \
    ! -name 'org.tasks.desktop' \
    -delete && \
  sed -i 's/^Categories=.*/Categories=Utility;/' \
    /usr/share/applications/brave-origin.desktop \
    /usr/share/applications/org.tasks.desktop && \
  echo "**** cleanup ****" && \
  printf \
    "Desktop Workspace version: ${VERSION}\nBuild-date: ${BUILD_DATE}\n" \
    > /build_version && \
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
