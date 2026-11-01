#!/usr/bin/env bash

ping_tool() {
    local target
    clear 2>/dev/null || true
    printf '%s=== Ping test ===%s\n\n' "$BLUE" "$NC"
    read -r -p "Enter an IP address or hostname: " target || return

    if [[ -z "$target" || "$target" == -* ]]; then
        printf '%s[!] Enter a valid IP address or hostname.%s\n' "$RED" "$NC"
    else
        printf '%s[*] Sending four ping packets to %s...%s\n' "$YELLOW" "$target" "$NC"
        ping -c 4 "$target"
    fi
    pause_for_menu
}

ping_tool
