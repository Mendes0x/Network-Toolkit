#!/usr/bin/env bash

speed_test() {
    local choice answer
    clear 2>/dev/null || true
    printf '%s=== Speed test ===%s\n\n' "$BLUE" "$NC"
    printf '%s\n' '1. Quick download test with curl' '2. Full test with speedtest-cli' '3. Return to the main menu'
    read -r -p "Select an option [1-3]: " choice || return

    case "$choice" in
        1)
            printf '%s[*] Downloading a 10 MB test file...%s\n' "$YELLOW" "$NC"
            curl --fail --location --silent --show-error --output /dev/null \
                --write-out 'Downloaded %{size_download} bytes in %{time_total} seconds\n' \
                'https://speed.cloudflare.com/__down?bytes=10000000'
            ;;
        2)
            if ! command -v speedtest-cli >/dev/null 2>&1; then
                if "$IS_TERMUX"; then
                    printf '%s[!] Install Python and speedtest-cli with: pkg install python && python -m pip install speedtest-cli%s\n' "$YELLOW" "$NC"
                else
                    printf '%s[!] Install speedtest-cli with: sudo apt-get install speedtest-cli%s\n' "$YELLOW" "$NC"
                fi
                pause_for_menu
                return
            fi
            printf '%s[*] Running speedtest-cli...%s\n' "$YELLOW" "$NC"
            speedtest-cli
            ;;
        3) return 0 ;;
        *) printf '%s[!] Invalid option.%s\n' "$RED" "$NC" ;;
    esac
    pause_for_menu
}

speed_test
