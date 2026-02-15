#!/bin/bash
# ─────────────────────────────────────────────
# Main installer — entry point
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/colors.sh"
source "$SCRIPT_DIR/packages.sh"
source "$SCRIPT_DIR/tui.sh"
source "$SCRIPT_DIR/fixes.sh"
source "$SCRIPT_DIR/post-setup.sh"

# Global failure log — all stages write here
FAILED=()

# ── Helper: init state arrays from a "key:value" list ──

init_states() {
    local -n _src=$1
    local -n _names=$2
    local -n _states=$3
    local default=${4:-1}

    _names=()
    _states=()
    for entry in "${_src[@]}"; do
        _names+=("${entry#*:}")
        _states+=("$default")
    done
}

# ── Init TUI states ──

pkg_states=()
for ((i = 0; i < ${#PACKAGES[@]}; i++)); do pkg_states+=("1"); done

fix_names=(); fix_states=()
init_states FIXES fix_names fix_states 0

post_names=(); post_states=()
init_states POST_TASKS post_names post_states 1
for ((i = 0; i < ${#post_names[@]}; i++)); do
    post_names[$i]="${post_names[$i]%%:*}"
done

# ── TUI ──

run_menu "Select packages to install" PACKAGES pkg_states

((${#FIXES[@]} > 0)) && \
    run_menu "Select fixes to apply" fix_names fix_states

((${#POST_TASKS[@]} > 0)) && \
    run_menu "Select post-setup tasks" post_names post_states

# ── Build selected lists ──

selected_pkgs=()
for ((i = 0; i < ${#PACKAGES[@]}; i++)); do
    [[ "${pkg_states[$i]}" == "1" ]] && selected_pkgs+=("${PACKAGES[$i]}")
done

selected_fixes=()
for ((i = 0; i < ${#FIXES[@]}; i++)); do
    [[ "${fix_states[$i]}" == "1" ]] && selected_fixes+=("${FIXES[$i]%%:*}")
done

selected_post=()
for ((i = 0; i < ${#POST_TASKS[@]}; i++)); do
    [[ "${post_states[$i]}" == "1" ]] && selected_post+=("${POST_TASKS[$i]}")
done

# ── Summary ──

tput clear
echo -e "${BOLD}${CYAN}Summary${NC}"
echo -e "${GREEN}Packages (${#selected_pkgs[@]}):${NC} ${selected_pkgs[*]}"
((${#selected_fixes[@]} > 0)) && echo -e "${YELLOW}Fixes:${NC} ${selected_fixes[*]}"
((${#selected_post[@]} > 0))  && echo -e "${CYAN}Post-setup (${#selected_post[@]})${NC}"
echo ""

read -r -p "Proceed? [Y/n] " confirm
[[ "${confirm:-Y}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ── Bootstrap: yay & flatpak ──

if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}Installing yay...${NC}"
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    (cd /tmp/yay-install && makepkg -si)
    rm -rf /tmp/yay-install
fi

if ! command -v flatpak &>/dev/null; then
    echo -e "${YELLOW}Installing flatpak...${NC}"
    sudo pacman -S flatpak
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ── Install packages ──

if ((${#selected_pkgs[@]} > 0)); then
    echo -e "\n${GREEN}Installing ${#selected_pkgs[@]} packages...${NC}"
    for pkg in "${selected_pkgs[@]}"; do
        if yay -S --needed --noconfirm --answerdiff=None --answerclean=None --removemakeddeps "$pkg"; then
            echo -e "${GREEN}  ✓ ${pkg}${NC}"
        else
            echo -e "${RED}  ✗ ${pkg}${NC}"
            FAILED+=("[pkg] ${pkg}")
        fi
    done
fi

# ── Fixes ──

if ((${#selected_fixes[@]} > 0)); then
    echo -e "\n${YELLOW}Applying fixes...${NC}"
    apply_fixes selected_fixes
fi

# ── Post-setup ──

if ((${#selected_post[@]} > 0)); then
    echo -e "\n${CYAN}Running post-setup...${NC}"
    run_post_setup selected_post
fi

# ── Report ──

echo ""
if ((${#FAILED[@]} > 0)); then
    echo -e "${RED}${BOLD}Failed (${#FAILED[@]}):${NC}"
    for item in "${FAILED[@]}"; do
        echo -e "${RED}  - ${item}${NC}"
    done
    echo ""
fi
echo -e "${GREEN}${BOLD}Done!${NC}"
