# Comprehensive Windows Setup Guide for Windows 10/11

## Introduction

This guide provides detailed instructions for post-installation setup and customization tailored for Windows 10 and Windows 11 operating systems.

## Initial System Configuration and Updates

### System and Microsoft Store Updates

Begin by updating all system components and applications through Windows Update and the Microsoft Store. During this process, review and uninstall any pre-installed applications that are not needed.

### Windows Subsystem for Linux (WSL)

Install WSL2.

```pwsh
wsl --install
```

### Customizations

- **Wallpaper and Theme:** Personalize your desktop by setting a new wallpaper and selecting a theme that suits your taste.
- **Keyboard and Fonts:** Adjust keyboard settings and install any desired fonts.
- **Configure OneDrive:** Set up and sync your files with OneDrive for cloud storage.
- **Link Your Phone:** Connect and configure your mobile device with Windows for seamless integration.
- **Folder Options:** Enable the visibility of hidden files and folders and extensions via File Explorer options.
- **Terminal Preferences:** Customize terminal to match your preferences.

_After making these changes, restart your computer to ensure all settings are applied correctly. Restarts might be needed several times_

### Generate SSH Key

```pwsh
ssh-keygen -b 4096 -t rsa -C "dell-xps-15"
```

## Applications Installation

### Introduction to Windows Package Manager (winget)

**Windows Package Manager (`winget`)** is a command-line tool that makes it easy to install, update, and manage applications on Windows. Here are some basic commands to get you started:

- **Search for Applications:** Before installing, you can search for applications in the `winget` repository:

```pwsh
winget search <ApplicationName>
```
- **General installation** (installs the best match found): Install application
```pwsh
winget install --id <ApplicationId> --source winget
```
- **Exact installation** (ensures you install precisely the intended application): Install application
```pwsh
winget install -e --id <ApplicationId>
```

- **Update Applications:** To update all your installed applications that have updates available:

```pwsh
winget upgrade --all
```

This tool helps streamline the installation and maintenance of software, ensuring you have the latest versions securely and efficiently.

### Applications Available via Winget

The following applications can typically be found in the `winget` repository. Use the `winget install` command with the appropriate ID:

```pwsh
winget install -e --id Microsoft.PowerShell
winget install -e --id Microsoft.PowerToys
winget install -e --id Google.Chrome
winget install -e --id Google.GoogleDrive
winget install -e --id PostgreSQL.pgAdmin
winget install -e --id Ookla.Speedtest.Desktop
winget install -e --id WireGuard.WireGuard
winget install -e --id Valve.Steam
winget install -e --id Mirantis.Lens
winget install -e --id Microsoft.DotNet.SDK.9
winget install -e --id Notepad++.Notepad++
winget install -e --id Microsoft.VisualStudioCode --scope machine
winget install -e --id Git.Git
winget install -e --id Python.Python.3.13
winget install -e --id Postman.Postman
winget install -e --id VideoLAN.VLC
winget install -e --id Telegram.TelegramDesktop
winget install -e --id SlackTechnologies.Slack
winget install -e --id Microsoft.Teams
winget install -e --id Discord.Discord
winget install -e --id AnyDeskSoftwareGmbH.AnyDesk
winget install -e --id TeamViewer.TeamViewer
winget install -e --id Logitech.
winget install -e --id qishibo.AnotherRedisDesktopManager
winget install -e --id PrimateLabs.Geekbench.6
winget install -e --id RustDesk.RustDesk  
winget install -e --id WinSCP.WinSCP
winget install -e --id DevToys-app.DevToys
winget install -e --id AltSnap.AltSnap
```

### Applications to Check Manually
Some applications might not be available via `winget` or you may prefer to download them directly to ensure you're getting the most up-to-date or specific version:

- WhatsApp (winget exists as well but had issues with it)
- Bitwarden (winget exists as well but had issues with it)
- JetBrains Toolbox (winget exists as well but had issues with it)
- Docker Desktop (winget exists as well but had issues with it)
- Microsoft To Do
- iVMS 4200 AC client
- EzStation
- Zona
- Dahua Toolbox
- NetSetMan (optional)
- Adobe products (optional)
- Adobe digital edition with converter (optional)
