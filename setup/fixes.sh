#!/bin/bash

apply_fixes() {
    local -n _selected_fixes=$1

    for fix in "${_selected_fixes[@]}"; do
        case "$fix" in
            huawei-sound-fix)
                echo -e "${YELLOW}Applying Huawei Matebook sound fix...${NC}"
                git clone https://github.com/Smoren/huawei-ubuntu-sound-fix /tmp/huawei-sound-fix
                (cd /tmp/huawei-sound-fix && chmod u+x ./install.sh && ./install.sh)
                rm -rf /tmp/huawei-sound-fix
                ;;
        esac
    done
}
