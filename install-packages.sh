#!/bin/bash
echo "Choose device"
echo "1) Desktop (default)"
echo "2) Huawei Matebook"
read -r -p "Enter your choice [1-2]: " device_choice
device_choice=${device_choice:-1}
case $device_choice in
1)
    echo "Desktop"
    ;;
2)
    echo "Huawei Matebook"
    echo "Installing additional sound fix for Matebook..."
    sudo pacman -S --needed git base-devel
    git clone https://github.com/Smoren/huawei-ubuntu-sound-fix
    cd huawei-ubuntu-sound-fix || exit
    ./install.sh
    cd ..
    rm -rf huawei-ubuntu-sound-fix
    echo "Done installing sound fix"
    echo "Installing additional packages for Matebook..."
    sudo pacman -S --needed powertop
    ;;
*)
    echo "Invalid choice"
    exit 1
    ;;
esac
# Looking for yay
if ! command -v yay &>/dev/null; then
    echo "Let's install yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si
    cd ..
    rm -rf yay
fi
# Looking for flatpak
if ! command -v flatpak &>/dev/null; then
    echo "Installing flatpak..."
    sudo pacman -S flatpak
fi
# Add Flatpak remotes
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Package lists
PACMAN_PACKAGES=(
    "plasma"
    "qbittorrent"
    "telegram-desktop"
    "steam"
    "timeshift"
    "xorg-xhost"
    "lutris"
    "kio-gdrive"
    "github-cli"
    "obs-studio"
    "jdk17-openjdk"
    "npm"
    "solaar"
    "pinta"
    "gimp"
    "baobab"
    "obsidian"
    "pyenv"
    "podman"
    "podman-compose"
    "docker"
    "docker-compose"
    "firefox"
    "zerotier-one"
    "smartmontools"
)
AUR_PACKAGES=(
    "zoom"
    "viber"
    "anydesk-bin"
    "protonup-qt"
    "protontricks"
    "visual-studio-code-bin"
    "postman-bin"
    "haguichi"
    "freeoffice"
    "vesktop"
    "aws-cli-v2"
    "podman-desktop-bin"
)
FLATPAK_PACKAGES=(
    "com.usebottles.bottles"
)
# Install packages
install_packages() {
    echo "Installing pacman packages..."
    sudo pacman -Syu --needed "${PACMAN_PACKAGES[@]}"
    echo "Installing AUR packages..."
    yay -S --needed "${AUR_PACKAGES[@]}"
    echo "Installing flatpak packages..."
    for package in "${FLATPAK_PACKAGES[@]}"; do
        flatpak install flathub "$package" -y
    done
}

#Set github name and email
git config --global user.name "DrArzter"
git config --global user.email "chapegarostislav@gmail"

# Call the installation function
install_packages
echo "All packages have been installed!"