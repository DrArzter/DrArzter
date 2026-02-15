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
