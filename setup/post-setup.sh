#!/bin/bash
# ─────────────────────────────────────────────
# Post-setup tasks
# ─────────────────────────────────────────────

# format: "id:Description:command"
POST_TASKS=(
    "git-config:Git config (name + email):git config --global user.name DrArzter && git config --global user.email chapegarostislav@gmail.com"
    "docker-enable:Enable Docker daemon:sudo systemctl enable --now docker.service"
    "docker-group:Add user to docker group:sudo usermod -aG docker $USER"
    "podman-socket:Enable Podman socket (user):systemctl --user enable --now podman.socket"
    "zerotier-enable:Enable ZeroTier daemon:sudo systemctl enable --now zerotier-one.service"
    "tailscale-enable:Enable Tailscale daemon:sudo systemctl enable --now tailscaled.service"
    "style-apply:Apply the saved desktop style:bash $SCRIPT_DIR/style.sh apply"
    "grub-theme:Graphite GRUB theme at 4K:sudo sed -i -e 's|^GRUB_THEME=.*|GRUB_THEME=/usr/share/grub/themes/graphite-default-4k/theme.txt|' -e 's|^GRUB_GFXMODE=.*|GRUB_GFXMODE=3840x2160,1920x1080,auto|' /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg"
)

run_post_setup() {
    local -n _tasks=$1

    for entry in "${_tasks[@]}"; do
        local desc="${entry#*:}"
        desc="${desc%%:*}"
        local cmd="${entry#*:}"
        cmd="${cmd#*:}"

        if eval "$cmd" &>/dev/null; then
            echo -e "${GREEN}  ✓ ${desc}${NC}"
        else
            echo -e "${RED}  ✗ ${desc}${NC}"
            FAILED+=("[post] ${desc}")
        fi
    done
}
