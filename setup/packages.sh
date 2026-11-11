#!/bin/bash
# ─────────────────────────────────────────────
# Packages (yay handles both pacman and AUR)
# ─────────────────────────────────────────────

PACKAGES=(
    # Desktop
    "plasma"
    "firefox-developer-edition"
    "libreoffice-fresh"
    "obsidian"
    "pinta"
    "gimp"
    "baobab"
    "mission-center"
    "blanket"
    "kando-bin"

    # Communication
    "telegram-desktop"
    "vesktop"
    "discord"
    "zoom"
    "anydesk-bin"

    # Dev tools
    "visual-studio-code-bin"
    "openai-codex-desktop"
    "claude-desktop-bin"
    "postman-bin"
    "github-cli"
    "npm"
    "jdk21-openjdk"
    "pyenv"
    "pandoc"
    "azuredatastudio-bin"
    "librdkafka"
    "android-sdk-cmdline-tools-latest"

    # Containers
    "docker"
    "docker-compose"
    "docker-buildx"
    "lazydocker"
    "podman"
    "podman-compose"
    "podman-desktop"
    "podman-tui"

    # Gaming
    "steam"
    "protonup-qt"
    "protontricks"
    "onlinefix-linux-launcher-bin"

    # System
    "qbittorrent"
    "obs-studio"
    "solaar"
    "xorg-xhost"
    "zerotier-one"
    "smartmontools"
    "powertop"
    "upscayl-bin"
    "scrcpy"
    "haguichi"
    "unrar"
    "sshx"
    "ngrok"
    "lsfg-vk"
    "tailscale"
    "ktailctl"
    "filezilla"
    "python-pyqt6"
    "python-pyqt5"

    # Theming — everything setup/style.sh expects to be present
    "plasma6-themes-orchis-kde-git" # Plasma: global theme, Aurorae, Kvantum, SDDM, colour schemes
    "orchis-theme"                  # the same look for GTK3/GTK4
    "kvantum"                       # Qt style engine
    "kvantum-qt5"
    "tela-circle-icon-theme-all-git"
    "vimix-cursors-git" # orphaned in the AUR, still the only package for it
    "graphite-grub-theme-default-4k"
)
