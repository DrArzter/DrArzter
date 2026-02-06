#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/packages.sh"
source "$SCRIPT_DIR/tui.sh"
source "$SCRIPT_DIR/fixes.sh"

# ── Init package states (all enabled) ──
pkg_states=()
for ((i = 0; i < ${#PACKAGES[@]}; i++)); do
    pkg_states+=("1")
done

# ── Init fix states (all disabled) ──
fix_names=()
fix_states=()
for fix in "${FIXES[@]}"; do
    fix_names+=("${fix#*:}")
    fix_states+=("0")
done

# ── TUI: select packages ──
run_menu "Select packages to install" PACKAGES pkg_states

# ── TUI: select fixes ──
if ((${#FIXES[@]} > 0)); then
    run_menu "Select fixes to apply" fix_names fix_states
fi

# ── Build selected lists ──
selected_pkgs=()
for ((i = 0; i < ${#PACKAGES[@]}; i++)); do
    if [[ "${pkg_states[$i]}" == "1" ]]; then
        selected_pkgs+=("${PACKAGES[$i]}")
    fi
done

selected_fixes=()
for ((i = 0; i < ${#FIXES[@]}; i++)); do
    if [[ "${fix_states[$i]}" == "1" ]]; then
        selected_fixes+=("${FIXES[$i]%%:*}")
    fi
done

# ── Summary ──
tput clear
echo -e "${BOLD}${CYAN}Summary${NC}"
echo -e "${GREEN}Packages (${#selected_pkgs[@]}):${NC} ${selected_pkgs[*]}"
if ((${#selected_fixes[@]} > 0)); then
    echo -e "${YELLOW}Fixes:${NC} ${selected_fixes[*]}"
fi
echo ""
read -r -p "Proceed? [Y/n] " confirm
confirm=${confirm:-Y}
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# ── Ensure yay ──
if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}Installing yay...${NC}"
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    (cd /tmp/yay-install && makepkg -si)
    rm -rf /tmp/yay-install
fi

# ── Ensure flatpak ──
if ! command -v flatpak &>/dev/null; then
    echo -e "${YELLOW}Installing flatpak...${NC}"
    sudo pacman -S flatpak
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ── Install selected packages ──
if ((${#selected_pkgs[@]} > 0)); then
    echo -e "${GREEN}Installing ${#selected_pkgs[@]} packages...${NC}"
    yay -Syu --needed "${selected_pkgs[@]}"
fi

# ── Apply selected fixes ──
apply_fixes selected_fixes

# ── Git config ──
git config --global user.name "DrArzter"
git config --global user.email "chapegarostislav@gmail.com"

echo -e "${GREEN}${BOLD}Done!${NC}"
