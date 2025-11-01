#!/usr/bin/env bash
set -Eeuo pipefail

# status + traps
_ok=true
trap '_ok=false; echo "❌ Setup failed at line $LINENO"; exit 1' ERR
trap '$_ok && echo "✅ Setup complete. Reboot recommended."' EXIT

# --- vars
EMAIL="haik.asatryan.95@gmail.com"
GIT_NAME="Haik Asatryan"
CODENAME=$(lsb_release -cs)
MS_CODENAME="noble"; [[ "$CODENAME" =~ ^(noble|jammy)$ ]] && MS_CODENAME="$CODENAME"

# --- cleanup old keys + repos
KEYRINGS=/etc/apt/keyrings
sudo install -d -m 0755 "$KEYRINGS"
sudo rm -f /etc/apt/sources.list.d/vscode.list /etc/apt/sources.list.d/microsoft.list
sudo rm -f /usr/share/keyrings/microsoft.gpg

export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting system setup for Ubuntu $CODENAME..."

# --- base
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common unzip flatpak gnome-software-plugin-flatpak git
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y

# --- ssh + git
mkdir -p ~/.ssh
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""
  chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
fi
git config --global user.email "$EMAIL"
git config --global user.name "$GIT_NAME"
git config --global init.defaultBranch main

# --- repos (idempotent)

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee "$KEYRINGS/microsoft.gpg" >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRINGS/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRINGS/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$MS_CODENAME-prod $MS_CODENAME main" | sudo tee /etc/apt/sources.list.d/microsoft.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee "$KEYRINGS/docker.gpg" >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRINGS/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list

curl -fsSL https://dl.k6.io/key.gpg | gpg --dearmor | sudo tee "$KEYRINGS/k6-archive-keyring.gpg" >/dev/null
echo "deb [signed-by=$KEYRINGS/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list

curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | sudo tee "$KEYRINGS/anydesk.gpg" >/dev/null
echo "deb [signed-by=$KEYRINGS/anydesk.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list

sudo apt-get update

# --- core packages
sudo apt-get install -y \
  dotnet-sdk-9.0 code \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  wireguard openvpn \
  gnome-tweaks gnome-shell-extension-manager gnome-shell-extensions \
  vlc filezilla wine winetricks \
  k6 anydesk

# --- teamviewer (.deb; non-fatal)
if ! command -v teamviewer >/dev/null; then
  wget -qO /tmp/teamviewer.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
  if ! sudo apt-get install -y /tmp/teamviewer.deb; then sudo apt-get -f install -y || true; fi
fi

# --- chrome (.deb; non-fatal)
if ! command -v google-chrome >/dev/null; then
  wget -qO /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  if ! sudo apt-get install -y /tmp/chrome.deb; then sudo apt-get -f install -y || true; fi
fi

# --- flatpak apps
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --or-update flathub \
  com.bitwarden.desktop \
  org.telegram.desktop \
  com.redis.RedisInsight

# --- docker desktop (.deb; non-fatal)
if ! command -v docker-desktop >/dev/null; then
  wget -qO /tmp/docker-desktop.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-latest.deb
  if ! sudo apt-get install -y /tmp/docker-desktop.deb; then sudo apt-get -f install -y || true; fi
fi

# --- docker post
sudo usermod -aG docker "$USER"
sudo systemctl enable docker --now
if grep -q '"credsStore"' ~/.docker/config.json 2>/dev/null; then
  sed -i '/"credsStore"/d' ~/.docker/config.json
fi

# --- cleanup
sudo apt-get autoremove -y
sudo apt-get clean
