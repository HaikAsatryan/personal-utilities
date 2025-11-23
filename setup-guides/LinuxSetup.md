# Comprehensive Linux Setup Guide for Ubuntu 22+ LTS versions

## Introduction

This guide provides a full setup process for Ubuntu 22+ LTS, automating developer tools, environment configuration, and GNOME customizations.
It includes a one-time (safe to rerun) script (`ubuntu-setup.sh`) to install and configure everything with minimal manual steps.

---

## 1. Clean Installation and Preparation

Start with a clean installation of **Ubuntu 24.04 Desktop**.  
During installation, connect to Wi-Fi and select **Minimal Installation** if you prefer a lean system.

After the first boot:

1. Complete system updates through **Software Update** application.
2. Reboot once before proceeding.

---

## 2. Setup Script Configuration and Execution

### Edit Before Use

Before running the script, open it and adjust:

- Email address for SSH key generation and git.
- Add or remove software you prefer.

### Run Script

```bash
sudo chmod +x ubuntu-setup.sh
sudo ./ubuntu-setup.sh
```

> Note: Script is located in the same directory where this guide is.

The script will:

- Configure repositories (Microsoft, Docker, etc.)
- Install developer tools and GNOME utilities
- Handle common Docker setup issues automatically
- Clean up the system

---

## 3. Essential GNOME Customizations

Open **Extension Manager** → Browse tab → search and install:

| Extension                                        | Purpose                                          |
| ------------------------------------------------ | ------------------------------------------------ |
| **System Monitor**                               | Live CPU/RAM/network metrics                     |
| **Top Bar Organizer**                            | Reorder top bar widgets                          |
| **Dash to Dock**                                 | Enhanced dock behavior                           |
| **Wiggle**                                       | Highlight cursor                                 |
| **AppIndicator and KStatusNotifierItem Support** | Required for Docker Desktop and system tray apps |
| **Blur My Shell**                                | Adds blur effect for aesthetics                  |
| **Weather O’Clock**                              | Adds weather to top bar clock                    |
| **Caffeine**                                     | Prevents auto-sleep                              |
| **Coverflow Alt-Tab**                            | 3D window switcher                               |
| **Clipboard Indicator / Pano**                   | Clipboard history management                     |
| **Logo Menu**                                    | Replaces Activities with a clean menu            |
| **Color Picker**                                 | Useful for UI/UX work                            |

> ⚠️ Some extensions might not be updated immediately for your GNOME version.
Add to Desktop
WireGuard Indicator
Vitals (sys monitor alt)
Lock Keys

---

## 4. Software Overview

| Category         | Software                                                                                        | Source            |
| ---------------- | ----------------------------------------------------------------------------------------------- | ----------------- |
| Development      | .NET 9 SDK, VS Code, JetBrains Toolbox (manual), k6                                             | apt + manual      |
| Containers       | Docker Engine, Docker Desktop, Lens                                                             | apt + vendor .deb |
| Networking / VPN | WireGuard, OpenVPN                                                                              | apt               |
| Communication    | Telegram (Flatpak)                                                                              | apt + Flatpak     |
| Utilities        | Chrome, AnyDesk, TeamViewer, Bitwarden (Flatpak), Redis Insight (Flatpak), FileZilla, VLC, Wine | mixed             |
| UI Customization | GNOME Tweaks, Shell Extensions                                                                  | apt               |

---

## 5. Sign-In Checklist

After setup, sign in to the following for full functionality:

| Application           | Purpose                                     |
| --------------------- | ------------------------------------------- |
| **VS Code**           | Sync settings, extensions, and GitHub login |
| **Docker Desktop**    | Access Docker Hub & sync containers         |
| **Microsoft Teams**   | Organization or personal communication      |
| **Bitwarden**         | Password manager sync                       |
| **Telegram**          | Messaging                                   |
| **JetBrains Toolbox** | IDE updates and settings sync               |
| **Google Chrome**     | Browser sync (extensions, bookmarks)        |

---

## 6. Final Steps

- Reboot the system.
- Launch Extension Manager and enable your preferred extensions.

---

**✅ Your Ubuntu developer environment is now fully set up and pre-tuned for daily use.**
