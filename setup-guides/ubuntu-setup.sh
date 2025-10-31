#!/usr/bin/env bash
set -e

# --- vars
EMAIL="haik.asatryan.95@gmail.com"
GIT_NAME="Haik Asatryan"
CODENAME=$(lsb_release -cs)
MS_CODENAME="noble"; [[ "$CODENAME" =~ ^(noble|jammy)$ ]] && MS_CODENAME="$CODENAME"
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting system setup for Ubuntu $CODENAME..."

# --- base & updates
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common unzip flatpak gnome-software-plugin-flatpak git
sudo install -d -m 0755 /etc/apt/keyrings
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y

# --- ssh key (ed25519) & git
mkdir -p ~/.ssh
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""
  chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
fi
git config --global user.email "${EMAIL}"
git config --global user.name "${GIT_NAME}"
git config --global init.defaultBranch main

# --- repos: Microsoft (VS Code, .NET)
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
 | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
 | sudo tee /etc/apt/sources.list.d/vscode.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$MS_CODENAME-prod $MS_CODENAME main" \
 | sudo tee /etc/apt/sources.list.d/microsoft.list

# --- repos: Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
 | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" \
 | sudo tee /etc/apt/sources.list.d/docker.list

# --- repos: k6
curl -fsSL https://dl.k6.io/key.gpg \
 | gpg --dearmor | sudo tee /etc/apt/keyrings/k6-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" \
 | sudo tee /etc/apt/sources.list.d/k6.list

# --- repos: AnyDesk
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
 | gpg --dearmor | sudo tee /etc/apt/keyrings/anydesk.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" \
 | sudo tee /etc/apt/sources.list.d/anydesk.list

# --- refresh
sudo apt-get update

# --- core packages
sudo apt-get install -y \
  dotnet-sdk-9.0 code \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  wireguard openvpn \
  gnome-tweaks gnome-shell-extension-manager gnome-shell-extensions \
  vlc filezilla wine winetricks \
  k6 anydesk

# --- TeamViewer
wget -qO /tmp/teamviewer.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo apt-get install -y /tmp/teamviewer.deb || sudo apt-get -f install -y

# --- Google Chrome
wget -qO /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y /tmp/chrome.deb || sudo apt-get -f install -y

# --- Flatpak apps
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.bitwarden.desktop org.telegram.desktop devtoys.app.DevToys qishibo.AnotherRedisDesktopManager

# --- Docker Desktop
wget -qO /tmp/docker-desktop.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-latest.deb
sudo apt-get install -y /tmp/docker-desktop.deb || sudo apt-get -f install -y

# --- Docker post
sudo usermod -aG docker "$USER"
sudo systemctl enable docker --now
if grep -q '"credsStore"' ~/.docker/config.json 2>/dev/null; then
  sed -i '/"credsStore"/d' ~/.docker/config.json
fi

# --- cleanup
sudo apt-get autoremove -y
sudo apt-get clean

echo "✅ Setup complete. Reboot recommended."
