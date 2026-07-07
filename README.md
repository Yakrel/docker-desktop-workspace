# Docker Desktop Workspace

A minimalist, containerized desktop environment designed for web browsing and note-taking. Built on **Debian Trixie** and **Selkies-GStreamer** (WebRTC), accessible directly via a browser.

## 📦 Contents

This image is strictly scoped to the following applications:

- **Brave:** Primary browser, optimized for container usage.
- **Obsidian:** Knowledge base and note-taking tool.
- **Tasks.org:** Task management and todo-list application.
- **Window Manager:** Openbox (Minimalist).
- **Panel:** Tint2.

*Note: No file manager (e.g., Thunar) is installed by default.*

## 🐳 Container Registry
The image is hosted on GitHub Container Registry:
**`ghcr.io/yakrel/docker-desktop-workspace`**

## 🚀 Usage

### Docker Compose

```yaml
services:
  desktop-workspace:
    image: ghcr.io/yakrel/docker-desktop-workspace:latest
    container_name: desktop-workspace
    hostname: desktop-workspace
    security_opt:
      - seccomp:unconfined # Required for browser stability
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
      - TITLE=Desktop Workspace
      - KEYBOARD=tr # Optional: Keyboard layout (e.g., tr, us)
    volumes:
      - /path/to/local/config:/config # Persist Brave profile and Obsidian vaults
    ports:
      - "3001:3001" # HTTPS Web Interface
    shm_size: "2gb" # Recommended to prevent browser crashes
    restart: unless-stopped
```

### Docker CLI

```bash
docker run -d \
  --name=desktop-workspace \
  --hostname=desktop-workspace \
  --security-opt seccomp=unconfined \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Istanbul \
  -e KEYBOARD=tr \
  -p 3001:3001 \
  -v /path/to/local/config:/config \
  --shm-size="2gb" \
  --restart unless-stopped \
  ghcr.io/yakrel/docker-desktop-workspace:latest
```

## ⚙️ Configuration Details

| Parameter | Description |
| :--- | :--- |
| **Port** | `3001` (HTTPS) is the default entry point. |
| **Hostname** | Setting a static hostname (e.g. `desktop-workspace`) prevents Brave/Chromium profile lock issues (`SingletonLock`) on container restarts. |
| **Volumes** | `/config` stores user data (Brave profile, Obsidian vaults, etc.). |
| **Security** | `seccomp:unconfined` is explicitly required for the browser to run without sandbox issues. |
| **Shared Memory** | `--shm-size="2gb"` is highly recommended for modern web browsing sessions. |
| **KEYBOARD** | Optional: Keyboard layout configuration (e.g., `tr` for Turkish, `us` for US). |

## 🛠️ Build Info

- **Base Image:** `ghcr.io/linuxserver/baseimage-selkies:debiantrixie`
- **Architecture:** x86_64 (amd64)
- **Update Cycle:** Builds are triggered via GitHub Actions.
