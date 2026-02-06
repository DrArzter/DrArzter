#!/bin/bash

draw_menu() {
    local title="$1"
    shift
    local -n _items=$1
    local -n _states=$2
    local cursor=$3
    local offset=$4
    local total=${#_items[@]}

    local term_lines
    term_lines=$(tput lines)
    local max_visible=$((term_lines - 6))
    ((max_visible < 5)) && max_visible=5

    tput clear
    echo -e "${BOLD}${CYAN}$title${NC}"
    echo -e "${DIM}[↑/↓] move  [Space] toggle  [a] all  [n] none  [Enter] confirm${NC}"
    echo ""

    for ((i = offset; i < offset + max_visible && i < total; i++)); do
        local label="${_items[$i]}"
        local state="${_states[$i]}"
        if ((i == cursor)); then
            if [[ "$state" == "1" ]]; then
                echo -e " ${GREEN}▶ [x] ${label}${NC}"
            else
                echo -e " ${RED}▶ [ ] ${label}${NC}"
            fi
        else
            if [[ "$state" == "1" ]]; then
                echo -e "   ${GREEN}[x] ${label}${NC}"
            else
                echo -e "   ${DIM}[ ] ${label}${NC}"
            fi
        fi
    done

    if ((total > max_visible)); then
        echo ""
        echo -e "${DIM}  (${offset+1}-$((offset+max_visible > total ? total : offset+max_visible)) of ${total})${NC}"
    fi
}

# Interactive checkbox menu. Sets result in _states array.
# Usage: run_menu "Title" items_array states_array
run_menu() {
    local title="$1"
    local -n _mitems=$2
    local -n _mstates=$3
    local total=${#_mitems[@]}
    local cursor=0
    local offset=0

    local term_lines
    term_lines=$(tput lines)
    local max_visible=$((term_lines - 6))
    ((max_visible < 5)) && max_visible=5

    tput civis
    trap 'tput cnorm; stty echo' EXIT

    while true; do
        draw_menu "$title" _mitems _mstates $cursor $offset

        IFS= read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 rest
                case "$rest" in
                    '[A') # Up
                        ((cursor > 0)) && ((cursor--))
                        if ((cursor < offset)); then
                            offset=$cursor
                        fi
                        ;;
                    '[B') # Down
                        ((cursor < total - 1)) && ((cursor++))
                        if ((cursor >= offset + max_visible)); then
                            offset=$((cursor - max_visible + 1))
                        fi
                        ;;
                esac
                ;;
            ' ') # Space — toggle
                if [[ "${_mstates[$cursor]}" == "1" ]]; then
                    _mstates[$cursor]="0"
                else
                    _mstates[$cursor]="1"
                fi
                ;;
            'a') # Select all
                for ((i = 0; i < total; i++)); do
                    _mstates[$i]="1"
                done
                ;;
            'n') # Deselect all
                for ((i = 0; i < total; i++)); do
                    _mstates[$i]="0"
                done
                ;;
            '') # Enter — confirm
                break
                ;;
        esac
    done

    tput cnorm
}
