# Comprehensive Linux Setup Guide for Ubuntu 24.04 and Fedora 40

## Introduction
This guide details post-installation setup and customization for Linux, specifically targeting Ubuntu 24.04 and Fedora 40, with Gnome 46 as the desktop environment.

## System Updates and Basic Tool Installation

**Ubuntu**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt-get install gdebi -y
sudo apt install glances htop ubuntu-restricted-extras fish -y
chsh -s /usr/bin/fish
```

**Fedora**
```bash
sudo dnf upgrade --refresh
sudo dnf install glances htop fish -y
chsh -s /usr/bin/fish
```
*Note: After installing `fish`, a system reboot is recommended before proceeding.*


## Essential Gnome Customizations

**Ubuntu**
```bash
sudo apt update
sudo apt install gnome-tweaks gnome-shell-extension-manager -y
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
sudo add-apt-repository ppa:touchegg/stable
sudo apt install touchegg gnome-weather -y
```

**Fedora**
```bash
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' //not woooooooooooooooooooooooorking
```

### Manual Installation and Configuration of Gnome Extensions

*Extensions like Pano and TopBar are not compatible with GNOME 46 yet.*


- **System Monitor:** Primary monitoring tool (Astra Monitor is a popular alternative).
- **Pano - Clipboard manager:** Clipboard manager, use Super+V to paste, similar to Windows (Clipboard Indicator is another alternative).
- **Apps Menu and Places Status Indicator:** For easy access to apps and places.
- **Top Bar Organizer:** Customize the order of top bar elements.
- **Dash to Dock:** Enhance your dock (Ubuntu comes with a default dock).
- **Wiggle:** Easily locate your mouse cursor.
- **AppIndicator and KStatusNotifierItem Support:** Essential for Docker Desktop functionality.
- **Blur My Shell:** Adds beautiful blur effects.
- **Weather O'clock:** Integrates weather into the clock (requires gnome-weather).
- **Desktop Icons NG (DING):** Makes desktop icons functional (not needed in Ubuntu).
- **Burn My Windows:** Adds animations to window actions.
- **Caffeine:** Prevents the system from sleeping with a toggle button.
- **Coverflow Alt-Tab:** Beautifies the alt-tab interface.
- **WireGuard VPN Extension:** Optional, for WireGuard VPN users.
- **No Overview at Startup:** Optionally disables the overview on startup.
- **Color Picker:** Useful tool for designers and frontend developers.
- **X11 Gestures:** Enhances touchpad shortcuts (requires Touchegg; not needed in Fedora).

## SSH Configuration

**Ubuntu**

```bash
sudo apt install openssh-client openssh-server -y
```

**Fedora**

```bash
sudo dnf install openssh-clients openssh-server -y
```

**Both**

 ```bash
systemctl enable ssh
systemctl start ssh
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

## Docker Installation
Follow official installation guides:

- Install docker - https://docs.docker.com/engine/install/ubuntu/
- Install docker-compose - https://docs.docker.com/compose/install/linux/#install-using-the-repository
- Install docker desktop - https://docs.docker.com/desktop/install/ubuntu/

Docker might bring severel problems after installation. Below will describe some problems and provide the solutions:

### Common Docker Issues and Fixes

**Credentials Error:**

```bash
nano ~/.docker/config.json
# Remove the "credsStore" line
```
**Docker Daemon Connection Issue:**

```bash
echo "export DOCKER_HOST=unix:///var/run/docker.sock" >> ~/.bashrc
source ~/.bashrc
```

## Manually Installed Applications

- .Net Sdk
- JetBrains Toolbox (from the official site)
- Notepad++
- Bitwarden
- VsCode
- Postman
- LibreOffice
- Vlc
- Telegram
- Whatsapp
- Google chrome
- Slack
- Teams
