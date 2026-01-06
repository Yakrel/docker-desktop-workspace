# Docker Desktop Workspace

A containerized Linux desktop environment accessible via a web browser. It provides a lightweight XFCE interface pre-configured with productivity tools.

## 📦 Features
- **Base:** Alpine Linux with XFCE Desktop
- **Access:** Web-based VNC (NoVNC) via port 3001
- **Tools Included:**
  - Google Chrome (Wrapped)
  - Obsidian (Note-taking)
  - Thunar File Manager
  - Tint2 Panel

## 🐳 Docker Hub
The image is published to: **[yakrel93/desktop-workspace](https://hub.docker.com/r/yakrel93/desktop-workspace)**

## 🔄 Build Policy
- **Schedule:** Builds run twice a week (Sunday & Wednesday at 02:00 UTC).
- **Retention:** Retains `latest` and the last **5** dated tags.

## 🚀 Usage

```yaml
services:
  desktop:
    image: yakrel93/desktop-workspace:latest
    ports:
      - "5800:3001"
    environment:
      - CUSTOM_USER=user
      - PASSWORD=password
    volumes:
      - /path/to/config:/config
```
