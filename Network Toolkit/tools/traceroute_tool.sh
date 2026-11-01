#!/usr/bin/env bash

traceroute_tool() {
    local target
    clear 2>/dev/null || true
    printf '%s=== Traceroute ===%s\n\n' "$BLUE" "$NC"
    read -r -p "Enter an IP address or hostname: " target || return

    if [[ -z "$target" || "$target" == -* ]]; then
        printf '%s[!] Enter a valid IP address or hostname.%s\n' "$RED" "$NC"
    else
        printf '%s[*] Tracing the route to %s...%s\n' "$YELLOW" "$target" "$NC"
        if "$IS_TERMUX"; then
            traceroute "$target"
        else
            traceroute -I "$target"
        fi
    fi
    pause_for_menu
}

traceroute_tool
