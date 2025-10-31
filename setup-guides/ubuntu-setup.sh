#!/usr/bin/env bash
set -e

EMAIL="haik.asatryan.95@gmail.com"
CODENAME=$(lsb_release -cs)
MS_CODENAME="noble"

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
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$MS_CODENAME-prod $MS_CODENAME main" | sudo tee /etc/apt/sources.list.d/microsoft.list

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