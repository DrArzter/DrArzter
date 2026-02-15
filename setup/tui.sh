#!/bin/bash
# ─────────────────────────────────────────────
# TUI checkbox menu
# ─────────────────────────────────────────────

_get_max_visible() {
    local lines
    lines=$(tput lines)
    local max=$((lines - 6))
    ((max < 5)) && max=5
    echo "$max"
}

_draw_menu() {
    local title="$1"
    local -n _items=$2
    local -n _states=$3
    local cursor=$4
    local offset=$5
    local total=${#_items[@]}
    local max_visible
    max_visible=$(_get_max_visible)

    tput clear
    echo -e "${BOLD}${CYAN}${title}${NC}"
    echo -e "${DIM}[↑/↓] move  [Space] toggle  [a] all  [n] none  [Enter] confirm${NC}"
    echo ""

    for ((i = offset; i < offset + max_visible && i < total; i++)); do
        if ((i == cursor)); then
            if [[ "${_states[$i]}" == "1" ]]; then
                echo -e " ${GREEN}▶ [x] ${_items[$i]}${NC}"
            else
                echo -e " ${RED}▶ [ ] ${_items[$i]}${NC}"
            fi
        else
            if [[ "${_states[$i]}" == "1" ]]; then
                echo -e "   ${GREEN}[x] ${_items[$i]}${NC}"
            else
                echo -e "   ${DIM}[ ] ${_items[$i]}${NC}"
            fi
        fi
    done

    if ((total > max_visible)); then
        local end=$((offset + max_visible))
        ((end > total)) && end=$total
        echo -e "\n${DIM}  ($((offset + 1))-${end} of ${total})${NC}"
    fi
}

# Usage: run_menu "Title" items_array states_array
run_menu() {
    local title="$1"
    local -n _mitems=$2
    local -n _mstates=$3
    local total=${#_mitems[@]}
    local cursor=0 offset=0
    local max_visible
    max_visible=$(_get_max_visible)

    tput civis
    trap 'tput cnorm; stty echo' EXIT

    while true; do
        _draw_menu "$title" _mitems _mstates "$cursor" "$offset"

        IFS= read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 rest
                case "$rest" in
                    '[A') ((cursor > 0)) && ((cursor--))
                          ((cursor < offset)) && offset=$cursor ;;
                    '[B') ((cursor < total - 1)) && ((cursor++))
                          ((cursor >= offset + max_visible)) && offset=$((cursor - max_visible + 1)) ;;
                esac ;;
            ' ')
                [[ "${_mstates[$cursor]}" == "1" ]] && _mstates[$cursor]="0" || _mstates[$cursor]="1" ;;
            a)
                for ((i = 0; i < total; i++)); do _mstates[$i]="1"; done ;;
            n)
                for ((i = 0; i < total; i++)); do _mstates[$i]="0"; done ;;
            '')
                break ;;
        esac
    done

    tput cnorm
}
