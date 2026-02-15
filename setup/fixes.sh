#!/bin/bash
# ─────────────────────────────────────────────
# Hardware/software fixes
# ─────────────────────────────────────────────

# format: "id:Description"
FIXES=(
    "huawei-sound-fix:Huawei Matebook sound fix (Smoren/huawei-ubuntu-sound-fix)"
)

apply_fixes() {
    local -n _fixes=$1

    for fix in "${_fixes[@]}"; do
        case "$fix" in
            huawei-sound-fix)
                echo -e "${CYAN}  Huawei Matebook sound fix...${NC}"
                if git clone https://github.com/Smoren/huawei-ubuntu-sound-fix /tmp/huawei-sound-fix &>/dev/null \
                    && (cd /tmp/huawei-sound-fix && chmod u+x ./install.sh && ./install.sh) &>/dev/null; then
                    echo -e "${GREEN}  ✓ Huawei sound fix${NC}"
                else
                    echo -e "${RED}  ✗ Huawei sound fix${NC}"
                    FAILED+=("[fix] Huawei sound fix")
                fi
                rm -rf /tmp/huawei-sound-fix
                ;;
        esac
    done
}
