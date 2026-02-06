#!/bin/bash

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Package list (yay handles both pacman and AUR) ──
PACKAGES=(
    "plasma"
    "qbittorrent"
    "telegram-desktop"
    "steam"
    "xorg-xhost"
    "github-cli"
    "obs-studio"
    "npm"
    "solaar"
    "pinta"
    "gimp"
    "baobab"
    "obsidian"
    "pyenv"
    "podman"
    "podman-compose"
    "podman-desktop"
    "podman-tui"
    "docker"
    "docker-compose"
    "docker-buildx"
    "lazydocker"
    "firefox-developer-edition"
    "zerotier-one"
    "smartmontools"
    "mission-center"
    "libreoffice-fresh"
    "zoom"
    "anydesk-bin"
    "protonup-qt"
    "protontricks"
    "visual-studio-code-bin"
    "postman-bin"
    "haguichi"
    "vesktop"
    "kando-bin"
    "upscayl-bin"
    "lsfg-vk"
    "pandoc"
    "jdk21-openjdk"
    "sshx"
    "ngrok"
    "onlinefix-linux-launcher-bin"
    "unrar"
    "blanket"
    "opencode-bin"
    "claude-code"
    "scrcpy"
    "powertop"
)

# ── Fixes (format: "id:Description") ──
FIXES=(
    "huawei-sound-fix:Huawei Matebook sound fix (Smoren/huawei-ubuntu-sound-fix)"
)
