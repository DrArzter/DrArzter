#!/bin/bash
# ─────────────────────────────────────────────
# Desktop style — save the live look into the repo, or put it back
# ─────────────────────────────────────────────
#
# Usage: setup/style.sh save|apply [--dry-run]
#
#   save       Copy the live configuration into style/ in this repository
#   apply      Copy style/ onto this machine and re-select the themes
#   --dry-run  Print every change, touch nothing
#
# Install the packages first: apply only selects themes, it cannot fetch them.
#
# Copies, never symlinks. KDE writes its config as "temp file + rename", which
# replaces a symlink with a regular file and silently detaches it from the repo.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STYLE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/style"
FIREFOX_CSS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/FirefoxCSS"

# shellcheck source=colors.sh
. "$SCRIPT_DIR/colors.sh"

FAILED=()
MODE=""
DRY_RUN=0

# Under ~/.config
CONFIG_ITEMS=(
    # The applied global theme lives here, not in kdeglobals. Without it a
    # restored machine comes up with the default colours and icons.
    "kdedefaults"
    "kdeglobals"
    "plasmarc"
    "plasmashellrc"
    # Panels, widgets and their settings.
    "plasma-org.kde.plasma.desktop-appletsrc"
    "kwinrc"
    "kwinrulesrc"
    "kglobalshortcutsrc"
    "kcminputrc"
    "kscreenlockerrc"
    "ksplashrc"
    "dolphinrc"
    "konsolerc"
    "katerc"
    "Kvantum"
    "gtk-3.0/settings.ini"
)

# Under $HOME
HOME_ITEMS=(
    ".gtkrc-2.0"
    ".local/share/konsole"
)

# Themes to re-select on apply, in this order. The global theme rewrites the
# colour scheme and the widget style, so the saved files are restored after it.
LOOK_AND_FEEL="com.github.vinceliuice.Orchis-dark"
KVANTUM_THEME="Orchis-solidDark"
GTK_THEME="Orchis-Dark"

usage() {
    sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' | grep -v '^─'
    exit "${1:-0}"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        save | apply) MODE="$1" ;;
        --dry-run) DRY_RUN=1 ;;
        -h | --help) usage 0 ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}" >&2
            usage 1
            ;;
    esac
    shift
done

[ -n "$MODE" ] || usage 1

ok() { echo -e "${GREEN}  ✓ $*${NC}"; }
skip() { echo -e "${DIM}  - $*${NC}"; }
note() { echo -e "${CYAN}$*${NC}"; }

fail() {
    echo -e "${RED}  ✗ $*${NC}"
    FAILED+=("[style] $*")
}

# run <description> <command...>
run() {
    local what=$1
    shift

    if [ "$DRY_RUN" = 1 ]; then
        echo -e "${DIM}  would run: $*${NC}"
        return 0
    fi

    if "$@" >/dev/null 2>&1; then
        ok "$what"
    else
        fail "$what"
    fi
}

# copy <source> <destination>: a directory replaces its counterpart whole, so a
# widget removed from the panel does not survive in the restored copy.
copy() {
    local source=$1
    local target=$2

    if [ ! -e "$source" ]; then
        skip "${source/#$HOME/\~} (not present)"
        return 0
    fi

    if [ "$DRY_RUN" = 1 ]; then
        echo -e "${DIM}  would copy: ${source/#$HOME/\~} -> ${target/#$HOME/\~}${NC}"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    rm -rf "${target:?}"

    if cp -a "$source" "$target"; then
        ok "${source/#$HOME/\~}"
    else
        fail "${source/#$HOME/\~}"
    fi
}

# plasmashell writes plasma-org.kde.plasma.desktop-appletsrc when it exits.
# Saving it from a running session captures the previous logout, not the
# panels currently on screen.
stop_shell() {
    if [ "$DRY_RUN" = 1 ]; then
        echo -e "${DIM}  would run: kquitapp6 plasmashell${NC}"
        return 0
    fi

    if kquitapp6 plasmashell >/dev/null 2>&1; then
        sleep 2
        ok "plasmashell stopped"
    else
        skip "plasmashell was not running"
    fi
}

start_shell() {
    if [ "$DRY_RUN" = 1 ]; then
        echo -e "${DIM}  would run: kstart plasmashell${NC}"
        return 0
    fi

    (kstart plasmashell >/dev/null 2>&1 &)
    ok "plasmashell started"
}

save_style() {
    local item

    note "Stopping the shell so the panel layout is written out"
    stop_shell

    note "Saving into ${STYLE_DIR/#$HOME/\~}"
    for item in "${CONFIG_ITEMS[@]}"; do
        copy "$HOME/.config/$item" "$STYLE_DIR/config/$item"
    done

    for item in "${HOME_ITEMS[@]}"; do
        copy "$HOME/$item" "$STYLE_DIR/home/$item"
    done

    note "Restarting the shell"
    start_shell
}

# libadwaita ignores GTK themes; the assets have to sit in the app's own
# config directory for GTK4 programs to pick Orchis up.
link_gtk4() {
    local source="/usr/share/themes/$GTK_THEME/gtk-4.0"
    local target="$HOME/.config/gtk-4.0"
    local file

    if [ ! -d "$source" ]; then
        skip "GTK4 assets ($GTK_THEME is not installed)"
        return 0
    fi

    if [ "$DRY_RUN" = 1 ]; then
        echo -e "${DIM}  would link: $source/{gtk.css,gtk-dark.css,assets} -> ${target/#$HOME/\~}${NC}"
        return 0
    fi

    mkdir -p "$target"

    for file in gtk.css gtk-dark.css assets; do
        # An earlier theme can leave a real directory here, and ln refuses to
        # replace one.
        [ -e "$target/$file" ] && [ ! -L "$target/$file" ] && rm -rf "${target:?}/$file"
        ln -sfn "$source/$file" "$target/$file"
    done

    ok "GTK4 assets linked"
}

# Firefox names its profile directory at random and ignores userChrome.css
# unless a pref is set, so both have to be resolved when applying.
firefox_profiles() {
    local ini="$HOME/.mozilla/firefox/profiles.ini"

    [ -f "$ini" ] || return 0

    # Install sections carry the profile each installed Firefox opens; a bare
    # "Default=1" has no dot and is skipped.
    sed -n 's/^Default=\(.*\..*\)$/\1/p' "$ini" | sort -u
}

apply_firefox_css() {
    local profile
    local target

    if [ ! -d "$FIREFOX_CSS_DIR" ]; then
        skip "Firefox CSS (FirefoxCSS/ is missing)"
        return 0
    fi

    for profile in $(firefox_profiles); do
        target="$HOME/.mozilla/firefox/$profile"
        [ -d "$target" ] || continue

        copy "$FIREFOX_CSS_DIR/userChrome.css" "$target/chrome/userChrome.css"
        copy "$FIREFOX_CSS_DIR/userContent.css" "$target/chrome/userContent.css"

        if [ "$DRY_RUN" = 1 ]; then
            echo -e "${DIM}  would set: toolkit.legacyUserProfileCustomizations.stylesheets in ${profile}/user.js${NC}"
            continue
        fi

        if grep -qs legacyUserProfileCustomizations "$target/user.js"; then
            skip "${profile}/user.js (pref already set)"
        elif echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' \
            >>"$target/user.js"; then
            ok "${profile}/user.js"
        else
            fail "${profile}/user.js"
        fi
    done
}

apply_style() {
    local item

    note "Selecting themes"
    run "global theme ($LOOK_AND_FEEL)" plasma-apply-lookandfeel -a "$LOOK_AND_FEEL"
    run "Kvantum theme ($KVANTUM_THEME)" kvantummanager --set "$KVANTUM_THEME"
    link_gtk4

    note "Firefox chrome"
    apply_firefox_css

    # After the global theme, never before: applying it overwrites the colour
    # scheme and the widget style with the theme's own defaults.
    note "Restoring the saved configuration"
    for item in "${CONFIG_ITEMS[@]}"; do
        copy "$STYLE_DIR/config/$item" "$HOME/.config/$item"
    done

    for item in "${HOME_ITEMS[@]}"; do
        copy "$STYLE_DIR/home/$item" "$HOME/$item"
    done

    note "Restarting the shell"
    stop_shell
    start_shell
}

if [ "$DRY_RUN" = 1 ]; then
    echo -e "${YELLOW}${BOLD}Dry run — nothing will be changed${NC}\n"
fi

case "$MODE" in
    save) save_style ;;
    apply)
        if [ ! -d "$STYLE_DIR/config" ] && [ "$DRY_RUN" = 0 ]; then
            echo -e "${RED}Nothing saved yet: run 'setup/style.sh save' first${NC}" >&2
            exit 1
        fi
        apply_style
        ;;
esac

echo ""
if ((${#FAILED[@]} > 0)); then
    echo -e "${RED}${BOLD}Failed (${#FAILED[@]}):${NC}"
    for item in "${FAILED[@]}"; do
        echo -e "${RED}  - ${item}${NC}"
    done
    exit 1
fi

echo -e "${GREEN}${BOLD}Done!${NC}"
