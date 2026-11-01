#!/usr/bin/env bash

valid_port_list() {
    local part start end number
    local -a parts
    [[ "$1" =~ ^[0-9,-]+$ ]] || return 1
    IFS=',' read -r -a parts <<< "$1"
    for part in "${parts[@]}"; do
        if [[ "$part" =~ ^([0-9]{1,5})-([0-9]{1,5})$ ]]; then
            start="${BASH_REMATCH[1]}"
            end="${BASH_REMATCH[2]}"
            ((10#${start} >= 1 && 10#${end} <= 65535 && 10#${start} <= 10#${end})) || return 1
        elif [[ "$part" =~ ^[0-9]{1,5}$ ]]; then
            number="$part"
            ((10#${number} >= 1 && 10#${number} <= 65535)) || return 1
        else
            return 1
        fi
    done
}

port_scanner() {
    local choice target ports
    while true; do
        clear 2>/dev/null || true
        printf '%s=== Port scanner ===%s\n\n' "$BLUE" "$NC"
        printf '%s\n' '1. Quick scan (common ports)' '2. Scan all TCP ports' '3. Scan a custom port list or range' '4. Return to the main menu'
        read -r -p "Select an option [1-4]: " choice || return

        case "$choice" in
            1|2|3)
                read -r -p "Enter an IP address or hostname you are authorized to scan: " target || return
                if [[ -z "$target" || "$target" == -* ]]; then
                    printf '%s[!] Enter a valid IP address or hostname.%s\n' "$RED" "$NC"
                    pause_for_menu
                    continue
                fi
                case "$choice" in
                    1)
                        printf '%s[*] Scanning common ports on %s...%s\n' "$YELLOW" "$target" "$NC"
                        nmap -F -- "$target"
                        ;;
                    2)
                        printf '%s[*] Scanning all TCP ports on %s. This may take a while...%s\n' "$YELLOW" "$target" "$NC"
                        nmap -p- -- "$target"
                        ;;
                    3)
                        read -r -p "Enter ports (for example: 80,443,1000-2000): " ports || return
                        if ! valid_port_list "$ports"; then
                            printf '%s[!] Use ports from 1 to 65535, separated by commas; ranges must be ascending.%s\n' "$RED" "$NC"
                            pause_for_menu
                            continue
                        fi
                        printf '%s[*] Scanning ports %s on %s...%s\n' "$YELLOW" "$ports" "$target" "$NC"
                        nmap -p "$ports" -- "$target"
                        ;;
                esac
                pause_for_menu
                ;;
            4) return 0 ;;
            *) printf '%s[!] Invalid option.%s\n' "$RED" "$NC"; pause_for_menu ;;
        esac
    done
}

port_scanner
