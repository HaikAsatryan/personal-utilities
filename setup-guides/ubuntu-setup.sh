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
KEYRINGS=/etc/apt/keyrings
TARGET_USER=${SUDO_USER:-$USER}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting system setup for Ubuntu $CODENAME..."

# --- base
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common unzip flatpak gnome-software-plugin-flatpak git
sudo install -d -m 0755 "$KEYRINGS"
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y

# --- ssh + git (user-scoped)
sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.ssh"
if [ ! -s "$TARGET_HOME/.ssh/id_ed25519" ]; then
  sudo -u "$TARGET_USER" ssh-keygen -t ed25519 -C "$EMAIL" -f "$TARGET_HOME/.ssh/id_ed25519" -N "" -q
fi
sudo chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.ssh"
sudo chmod 700 "$TARGET_HOME/.ssh"
sudo chmod 600 "$TARGET_HOME/.ssh/id_ed25519" 2>/dev/null || true
sudo chmod 644 "$TARGET_HOME/.ssh/id_ed25519.pub" 2>/dev/null || true

sudo -u "$TARGET_USER" git config --global user.name  "$GIT_NAME"
sudo -u "$TARGET_USER" git config --global user.email "$EMAIL"
sudo -u "$TARGET_USER" git config --global init.defaultBranch main

# --- repos (idempotent)

# Microsoft: hard reset to a single keyring path (/usr/share/keyrings)
sudo find /etc/apt/sources.list.d -maxdepth 1 -type f \
  \( -iname '*code*.list' -o -iname '*microsoft*.list' -o -iname '*microsoft*.sources' \) -print -delete || true
sudo rm -f /etc/apt/keyrings/microsoft.gpg /usr/share/keyrings/microsoft.gpg

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
 | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
 | sudo tee /etc/apt/sources.list.d/vscode.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$MS_CODENAME-prod $MS_CODENAME main" \
 | sudo tee /etc/apt/sources.list.d/microsoft-prod.list

# remove any legacy duplicates
sudo sed -i '/packages\.microsoft\.com\/repos\/code/d' /etc/apt/sources.list || true
sudo rm -f /etc/apt/sources.list.d/vscode.sources /etc/apt/sources.list.d/code.sources /etc/apt/sources.list.d/*microsoft*.sources

# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
 | gpg --dearmor | sudo tee "$KEYRINGS/docker.gpg" >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRINGS/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" \
 | sudo tee /etc/apt/sources.list.d/docker.list

# k6
curl -fsSL https://dl.k6.io/key.gpg \
 | gpg --dearmor | sudo tee "$KEYRINGS/k6-archive-keyring.gpg" >/dev/null
echo "deb [signed-by=$KEYRINGS/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" \
 | sudo tee /etc/apt/sources.list.d/k6.list

# AnyDesk
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
 | gpg --dearmor | sudo tee "$KEYRINGS/anydesk.gpg" >/dev/null
echo "deb [signed-by=$KEYRINGS/anydesk.gpg] http://deb.anydesk.com/ all main" \
 | sudo tee /etc/apt/sources.list.d/anydesk.list

# migrate *.list -> *.sources where applicable (safe on reruns)
sudo apt -y modernize-sources || true
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

# --- Docker Desktop (requires KVM)
sudo apt-get install -y uidmap dbus-user-session qemu-system libvirt-daemon-system libvirt-clients bridge-utils
sudo usermod -aG kvm,libvirt "$TARGET_USER"

if lscpu | grep -qi intel; then
  sudo modprobe kvm || true
  sudo modprobe kvm_intel || true
else
  sudo modprobe kvm || true
  sudo modprobe kvm_amd || true
fi

if [ ! -e /dev/kvm ]; then
  echo "❌ Docker Desktop requires /dev/kvm. Enable VT-x/AMD-V or nested virtualization and rerun."
  exit 1
fi

cd /tmp
wget -q https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo apt-get update
sudo apt-get install -y ./docker-desktop-amd64.deb

# --- enable services (engine if present; desktop for the user)
sudo usermod -aG docker "$TARGET_USER"
if systemctl list-unit-files | grep -q '^docker\.service'; then
  sudo systemctl enable --now docker
fi
loginctl enable-linger "$TARGET_USER"
runuser -l "$TARGET_USER" -c 'systemctl --user enable docker-desktop.service || true'
runuser -l "$TARGET_USER" -c 'systemctl --user start  docker-desktop.service  || true'

# optional: clear legacy credsStore if present
if [ -f "$TARGET_HOME/.docker/config.json" ] && grep -q '"credsStore"' "$TARGET_HOME/.docker/config.json" 2>/dev/null; then
  sed -i '/"credsStore"/d' "$TARGET_HOME/.docker/config.json"
fi

# --- cleanup
sudo apt-get autoremove -y
sudo apt-get clean