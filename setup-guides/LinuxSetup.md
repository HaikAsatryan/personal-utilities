# Comprehensive Linux Setup Guide for Ubuntu 25.04

## Introduction

This guide provides a full setup process for Ubuntu 25.04 (GNOME 48), automating developer tools, environment configuration, and GNOME customizations.
It includes a one-time script (`ubuntu-setup.sh`) to install and configure everything with minimal manual steps.

---

## 1. Clean Installation and Preparation

Start with a clean installation of **Ubuntu 25.04 Desktop**.  
During installation, connect to Wi-Fi and select **Minimal Installation** if you prefer a lean system.

After the first boot:

1. Complete system updates through **Settings → About → Check for Updates**.
2. Reboot once before proceeding.

---

## 2. Setup Script Configuration and Execution

### Edit Before Use

Before running the script, open it and adjust:

- Email address for SSH key generation.
- Add or remove software you prefer.
- Review Flatpak apps section.

### Run Script

```bash
sudo chmod +x ubuntu-setup.sh
sudo ./ubuntu-setup.sh
```

The script will:

- Configure repositories (Microsoft, Docker, Grafana, etc.)
- Install developer tools and GNOME utilities
- Handle common Docker setup issues automatically
- Clean up the system

---

## 3. Script Reference

```bash
#!/usr/bin/env bash
set -e

EMAIL="haik.asatryan.95@gmail.com"
CODENAME=$(lsb_release -cs)

echo "🚀 Starting system setup for Ubuntu $CODENAME..."

# Enable additional repositories and update
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common unzip flatpak gnome-software-plugin-flatpak

# Generate SSH key
mkdir -p ~/.ssh
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f ~/.ssh/id_rsa -N ""
fi
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Microsoft repository for .NET SDK and VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$CODENAME-prod $CODENAME main" | sudo tee /etc/apt/sources.list.d/microsoft.list

# Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Grafana repo for k6
curl -fsSL https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update

# Install core packages
sudo apt install -y   dotnet-sdk-9.0   code   docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin   wireguard openvpn   teams   anydesk teamviewer   gnome-tweaks gnome-shell-extension-manager gnome-shell-extensions   vlc filezilla   wine winetricks   k6

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo apt install -y /tmp/chrome.deb || sudo apt --fix-broken install -y

# Flatpak setup and installations
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub com.bitwarden.desktop
flatpak install -y flathub org.telegram.desktop
flatpak install -y flathub devtoys.app.DevToys
flatpak install -y flathub qishibo.AnotherRedisDesktopManager

# Docker Desktop
wget -O /tmp/docker-desktop.deb "https://desktop.docker.com/linux/main/amd64/docker-desktop-latest.deb"
sudo apt install -y /tmp/docker-desktop.deb || sudo apt --fix-broken install -y

# --- Docker problem fixes ---
# Fix permission and credentials issues (common)
sudo usermod -aG docker $USER
sudo systemctl enable docker --now
if grep -q '"credsStore"' ~/.docker/config.json 2>/dev/null; then
  sed -i '/"credsStore"/d' ~/.docker/config.json
fi
echo "export DOCKER_HOST=unix:///var/run/docker.sock" >> ~/.bashrc
source ~/.bashrc

# Post cleanup
sudo apt autoremove -y && sudo apt clean

echo "✅ Setup complete. Reboot recommended."
```

---

## 4. Essential GNOME Customizations

Install **Tweaks** and **Extension Manager** (done by script, but verify):

```bash
sudo apt install gnome-tweaks gnome-shell-extension-manager -y
```

Then open **Extension Manager** → Browse tab → search and install:

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

> ⚠️ Some extensions might not be updated immediately for GNOME 48.

---

## 5. Software Overview

| Category         | Software                                                                                                                           | Source            |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| Development      | .NET 9 SDK, VS Code, JetBrains Toolbox (manual), k6                                                                                | apt + manual      |
| Containers       | Docker Engine, Docker Desktop, Lens                                                                                                | apt + vendor .deb |
| Networking / VPN | WireGuard, OpenVPN                                                                                                                 | apt               |
| Communication    | Teams, Telegram (Flatpak)                                                                                                          | apt + Flatpak     |
| Utilities        | Chrome, AnyDesk, TeamViewer, Bitwarden (Flatpak), Another Redis Desktop Manager (Flatpak), DevToys (Flatpak), FileZilla, VLC, Wine | mixed             |
| UI Customization | GNOME Tweaks, Shell Extensions                                                                                                     | apt               |

---

## 6. Sign-In Checklist

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

## 7. Final Steps

- Reboot the system.
- Launch Extension Manager and enable your preferred extensions.

---

**✅ Your Ubuntu developer environment is now fully set up and pre-tuned for daily use.**
